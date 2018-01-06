//
//  MessageDetailViewController.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/04.
//

import UIKit
import Pelican

extension MailPart {
    func findText(prefer type: TextType) -> MailPart? {
        
        if case let .multiPart(_, type, parts, _) = self, type == .alternative {
            // select prefer type
            
        } else if case let .singlePart(_, data) = self,
            case let .text (_, _, _) = data {
            // plain or html
            return self
        }
        return nil
    }
}

class MessageDetailViewController: UITableViewController {

    var message: Message! = nil
    var messageBody: MessageBody? = nil
    
    var sessionController: ImapSessionViewController {
        return self.parent?.parent as! ImapSessionViewController
    }
    
    func downloadPart(_ root: MailPart) {
        switch root {
        case let .multiPart(id, type, parts, _):
            switch type {
            case .related:
                parts.forEach({ (subPart) in
                    self.downloadPart(subPart)
                })
            case .alternative:
                let textPart = root.findText(prefer: .html)
                
            }
        case let .singlePart(id, data): break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.sessionController.command({ (imap) in
            
            let messageBody = try self.makeMessageBody()
            
            let textPart = {
                if let htmlPart = messageBody.findText(.html) {
                    return htmlPart
                } else {
                    return messageBody.texts[0]
                }
            }() as TextData
            
            try imap.fetchData(uid: UInt32(self.message.uid), partId: textPart.partId, completion: { (data) in
                
            })
            
        }) { (error) in
            switch error {
            case is MessageDetailError: break
            case is ImapSessionError:
                self.sessionController.handleImapError(error as? ImapSessionError)
            default: break
            }
        }
    }
    
    func makeMessageBody() throws -> MessageBody {
        guard let part =  self.message.body,
            let messageBody = MessageBody(root: part) else {
                throw MessageDetailError.notSupported
        }
        return messageBody
    }
    
    enum MessageDetailError: Error {
        case notSupported
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchContents() {
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
