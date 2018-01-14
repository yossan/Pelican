//
//  FolderListViewController.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2017/12/23.
//

import UIKit
import Pelican

class FolderListViewController: UITableViewController {
    
    var sessionController: ImapSessionViewController {
        return self.parent!.parent as! ImapSessionViewController
    }
    
    var namespace: NamespaceItem?
    var folders: [Folder] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sessionController.command({ [weak self] (imap) in
            guard let `self` = self else { return }
            self.folders = try imap.list(namespace: self.namespace)
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }) { [weak self] (error) in
            self?.sessionController.handleImapError(error as? ImapSessionError)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.folders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCellIdentifier", for: indexPath) as! FolderCell
        cell.ibNameLabel?.text = folders[indexPath.row].name
        return cell
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
    
    // MARK: - UITableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let messageViewController = segue.destination as? MessageListViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            
            let folder = self.folders[indexPath.row]
            messageViewController.selectedFolder = folder
        }
    }
    
}
