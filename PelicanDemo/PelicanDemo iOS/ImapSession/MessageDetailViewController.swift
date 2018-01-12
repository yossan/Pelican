//
//  MessageDetailViewController.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/04.
//

import UIKit
import Pelican
import WebKit

class MessageDetailViewController: UIViewController, UIScrollViewDelegate, WKNavigationDelegate, DynamicSizeViewDelegate {

    // MARK: - IBOutlet related properties
    
    @IBOutlet weak var webContentView: UIView!
    private var webView: WKWebView!
    private var loadingTextNavigation: WKNavigation? = nil
    
    @IBOutlet weak var headerContainerView: UIView!
    var headerFieldsController: MessageDetailHeaderViewController {
        return self.childViewControllers[0] as! MessageDetailHeaderViewController
    }
    
    // MARK: - Instance properties
    
    private var sessionController: ImapSessionViewController {
        return self.parent?.parent as! ImapSessionViewController
    }
    
    var message: Message!
    private var copiedMessageBody: MailPart!
    
    private var textPart: MailPart {
        return self.copiedMessageBody.textPart(prefer: .html)
    }
    
    private var inlineParts: [MailPart] {
        return self.copiedMessageBody.singleParts ({ $0.isInline == true &&  $0.bodyFields?.id != nil && $0.fileName != nil })
    }
    
    private var parts: [MailPart] {
        return self.copiedMessageBody.singleParts ({ ($0.isText == true && $0.id == textPart.id) || ($0.isInline == true && $0.bodyFields?.id != nil && $0.fileName != nil) })
    }
    
    private var directoryFile: File {
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
        guard self.copyMessageBody() else { return }
        
        self.setupUI()
        self.loadBody()
    }
    
    // MARK: - private methods
    private func setupUI() {
        self.headerFieldsController.header = self.message.header
//        self.headerContainerView.isUserInteractionEnabled = false
        
        self.webView = self.makeWebView()
        self.webContentView.addSubview(self.webView)
        self.webView.scrollView.addSubview(self.headerContainerView)
    }
    
    private func copyMessageBody() -> Bool {
        guard let body = self.message.body else { return false }
        self.copiedMessageBody = body
        
        if self.parts.contains(where: { $0.isText }) {
            return true
        }
        return false
    }
    
    private func loadBody() {
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
    
    private func hasDownloadedFiles() -> Bool {
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
    
    private func hasDownloadedFile(_ name: String) -> Bool {
        let file = self.directoryFile.add(file: name)
        return file.isExist
    }
    
    private func fileURL(by name: String) -> URL {
        let file = self.directoryFile.add(file: name)
        return file.url
    }
    
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
                    self.copiedMessageBody[part.id]? = part
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
    
    private func write(part: MailPart) -> Error? {
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
    
    private func makeWebViewLoad() {
        let bodyFields = self.textPart.bodyFields!
        let encoding = self.stringEncoding(from: bodyFields.charset)
        let textURL = self.fileURL(by: self.textPart.fileName!)
        if let data = try? Data(contentsOf: textURL),
            let html = String(data: data, encoding: encoding) {
            self.loadingTextNavigation = self.webView.loadHTMLString(html, baseURL: textURL)
        }
    }
    
    private func stringEncoding(from charset: String?) -> String.Encoding {
        guard let charset = charset else { return .ascii }
        return String.Encoding(charset: charset) ?? .ascii
    }
    
    private func makeWebView() -> WKWebView {
        let controller = WKUserContentController()
        controller.addUserScript(self.scriptForViewPort())
        controller.addUserScript(self.scriptForLoadingEmbededImg())
        let config = WKWebViewConfiguration()
        config.userContentController = controller
        
        let webView = WKWebView(frame: self.webContentView.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.autoresizingMask = [.flexibleTopMargin, .flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        return webView
    }
    
    private func scriptForViewPort() -> WKUserScript {
        let javascript =
        """
        let meta = document.createElement('meta');
        meta.setAttribute('name', 'viewport');
        meta.setAttribute('content', 'width=device-width');
        document.getElementsByTagName('head')[0].appendChild(meta);
        """
        return WKUserScript(source: javascript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
    
    private func scriptForLoadingEmbededImg() -> WKUserScript {
        let javascript =
        """
        function loadEmbededImg(inlines) {
            let imgs = document.getElementsByTagName("img");
            let re = /^cid:(\\w+)$/i;
            for (img of imgs) {
                let found = img.src.match(re);
                if (found.length === 2) {
                    let cid = found[1];
                    let name = inlines[cid];
                    img.src = `./${name}`;
                }
            }
        }
        """
        return WKUserScript(source: javascript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.webView.scrollView == scrollView {
            self.headerContainerView.frame.origin.y = (scrollView.contentOffset.y + self.headerContainerView.frame.size.height) * (-1)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if self.loadingTextNavigation == navigation {
            self.callLoadingEmbededImgIfNecessary()
        }
    }
    
    private func callLoadingEmbededImgIfNecessary() {
        let inlines = self.inlineParts
        if inlines.count > 0 {
            let accumulator: [String] = []
            let cidInfo = inlines.reduce(into: accumulator) { (accumulator ,part) in
                let cid = part.bodyFields!.id!.trimmingCharacters(in: .symbols)
                let name = part.bodyFields!.name!
                accumulator.append("\"\(cid)\":\"\(name)\"")
                }.joined(separator: ",")
            let js = "loadEmbededImg({\(cidInfo)})"
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
    
    //MARK: - DynamicSizeViewDelegate
    var previousTop: CGFloat? = nil
    func intrinsicContentSizeForDynamicSizeView(_ view: DynamicSizeView) -> CGSize {
        let headerHeight: CGFloat = self.headerFieldsController.height
        
        webView.scrollView.contentInset.top = headerHeight
        webView.scrollView.contentOffset.y = (headerHeight + 60 ) * (-1)
        print("offsety", webView.scrollView.contentOffset.y)
//        if let previousTop = previousTop {
//            webView.scrollView.contentOffset.y -= (headerHeight - previousTop)
//        }
//
//        previousTop = headerHeight
        
        return CGSize(width: self.view.frame.size.width, height:  headerHeight)
    }
}
