//
//  MessageDetailViewController.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/04.
//

import UIKit
import Pelican
import WebKit

class MessageDetailViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - IBOutlet related properties
//    @IBOutlet var headerViewController: MessageDetailHeaderViewController!
    @IBOutlet var webContentView: UIView!
    
    var webView: WKWebView!
    
    // MARK: - Instance properties

    var message: Message!
    
    var sessionController: ImapSessionViewController {
        return self.parent?.parent as! ImapSessionViewController
    }
    
    var textPart: MailPart {
        return self.message.body!.textPart(prefer: .html)
    }
    
    var parts: [MailPart] {
        return self.message.body!.singleParts ({ ($0.isText == true && $0.id == textPart.id) || ($0.isInline == true || $0.fileName != nil) })
    }
    
    var directoryFile: File {
        let directory = Paths.messages.add(file: "INBOX").add(file: "\(self.message.uid)")
        return directory
    }
    
    // MARK: - Instance Life Methods
    
    deinit {
//        self.removeWebviewDidChangeSizeObserve()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard self.checkBodyValidation() else { return }
        
        self.webView = self.makeWebView()
        self.webContentView.addSubview(self.webView)
        self.loadBody()
    }
    
    func checkBodyValidation() -> Bool {
        if self.message.body != nil &&
            self.parts.contains(where: { $0.isText }) {
            return true
        }
        return false
    }
    
    func loadBody() {
        if self.hasDownloadedFiles() {
            self.makeWebViewLoad()
        } else {
            self.downloadParts() { (error) in
                guard error == nil else {
                    print("download failure: \(error!)")
                    return
                }
                self.makeWebViewLoad()
            }
        }
    }
    
    func hasDownloadedFiles() -> Bool {
        var result = true
        for subPart in parts {
            guard self.hasDownloadedFile(subPart.fileName!) == false else {
                continue
            }
            result = false
            break
        }
        return result
    }
    
    func hasDownloadedFile(_ name: String) -> Bool {
        let file = self.directoryFile.add(file: name)
        return file.isExist
    }
    
    func fileURL(by name: String) -> URL {
        let file = self.directoryFile.add(file: name)
        return file.url
    }
    
    func makeWebViewLoad() {
        let bodyFields = self.textPart.bodyFields!
        let encoding = self.stringEncoding(from: bodyFields.charset)
        let textURL = self.fileURL(by: self.textPart.fileName!)
        if let data = try? Data(contentsOf: textURL),
            let html = String(data: data, encoding: encoding) {
            self.webView.loadHTMLString(html, baseURL: textURL)
        }
    }
    
    private func stringEncoding(from charset: String?) -> String.Encoding {
        guard let charset = charset else {
            return .ascii
        }
        switch charset.lowercased() {
        case "utf-8": return .utf8
        case "utf-16": return .utf16
        case "utf-16be": return .utf16BigEndian
        case "utf-16le": return .utf16LittleEndian
        case "utf-32": return .utf32
        case "utf-32be": return .utf32BigEndian
        case "utf-32le": return .utf32LittleEndian
        case "iso-2022-jp": return .iso2022JP
        case "euc-jp": return .japaneseEUC
        case "shift_jis": return .shiftJIS
        case "‎windows-1250": return .windowsCP1250
        case "‎windows-1251": return .windowsCP1251
        case "‎windows-1252": return .windowsCP1252
        case "‎windows-1253": return .windowsCP1253
        case "‎windows-1254": return .windowsCP1254
        case "big5":
            let cfEnc = CFStringEncodings.big5
            let nsEnc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
            
            return String.Encoding(rawValue: nsEnc)
        case "GB18030":
            let cfEnc = CFStringEncodings.GB_18030_2000
            let nsEnc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
            
            return String.Encoding(rawValue: nsEnc)
            
        default:
            return .ascii
        }
    }
    
    func makeWebView() -> WKWebView {
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController
        
        let webView = WKWebView(frame: self.webContentView.bounds, configuration: wkWebConfig)
        webView.autoresizingMask = [.flexibleTopMargin, .flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        return webView
    }
    
    // MARK - Private methods
  
    
    private func downloadParts(completion: @escaping (Error?)->()) {
        let uid = self.message.uid
        self.sessionController.command({ (imap) in
            for part in self.parts {
                guard self.hasDownloadedFile(part.fileName!) == false else {
                    continue
                }
            
                var part = part
                let r = imap.fetchData(uid: uid, partId: part.id, completion: { (data) in
                    part.data = data
                    self.message.body![part.id]? = part
                })
                
                if r.isSuccess == false &&
                    part.id == self.textPart.id {
                    throw r
                }
                
                if let error = self.write(part: part),
                    part.id == self.textPart.id {
                    throw error
                }
            }
            OperationQueue.main.addOperation {
                completion(nil)
            }
        }, catched: { (error) in
            OperationQueue.main.addOperation {
                completion(error)
            }
        })
    }
    
    func write(part: MailPart) -> Error? {
        do {
            let file = self.directoryFile.add(file: part.fileName!)
            if file.isExist == false {
                try file.create()
            }
            try part.decodedData!.write(to: file.url, options: .completeFileProtection)
            return nil
        } catch let error {
            return error
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
