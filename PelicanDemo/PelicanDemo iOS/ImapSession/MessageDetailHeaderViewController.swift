//
//  MessageDetailHeaderViewController.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/09.
//

import UIKit
import Pelican

extension Optional where Wrapped == Int {
    static func >(lhs: Int?, rhs: Int) -> Bool {
        if let lhs = lhs {
            return lhs > rhs
        } else {
            return false
        }
    }
}

class MessageDetailHeaderViewController: UITableViewController {

    var header: MessageHeader!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var isDetailShowed: Bool = false
    var height: CGFloat {
        var indexPaths: [IndexPath] = [IndexPath(row: 0, section: Section.subject.rawValue)]
        if self.isDetailShowed == false {
            for i in 0..<self.detailRows.count {
                indexPaths.append(IndexPath(row: i, section: Section.detail.rawValue))
            }
        }
        return indexPaths.reduce(into: 0.0) { (accumulator, indexPath) in
            let cell = self.tableView.cellForRow(at: indexPath)
            accumulator += cell?.frame.size.height ?? 0.0
        }
    }
    
    struct DetailRow: RawRepresentable, OptionSet {
        static let from = DetailRow(rawValue: 1 << 0)
        static let to   = DetailRow(rawValue: 1 << 1)
        static let cc   = DetailRow(rawValue: 1 << 2)
        static let bcc  = DetailRow(rawValue: 1 << 3)
        static let date = DetailRow(rawValue: 1 << 4)
        
        let rawValue: Int
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    // MARK: - Table view data source
    
    enum Section: Int {
        case subject
        case detail
        init(_ section: Int) {
            switch section {
            case 0:
                self = .subject
            case 1:
                self = .detail
            default:
                fatalError()
            }
        }
    }
    
    lazy var detailRows: [DetailRow] = {
        var rows: [DetailRow] = [.from, .to, .date]
        if self.header.cc?.count > 0 {
            rows.append(.cc)
        }
        if self.header.bcc?.count > 0 {
            rows.append(.bcc)
        }
        
        rows.sort(by: { $0.rawValue < $1.rawValue })
        return rows
    }()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if self.isDetailShowed == false {
            return 1
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(section) {
        case .subject:
            return 1
        case .detail:
            return self.detailRows.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(indexPath.section) {
        case .subject:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageDetailSubjectCell", for: indexPath) as! MessageDetailSubjectCell
            cell.ibSubjectLabel.text = self.header.subject
            return cell
        case .detail:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageDetailFieldCell", for: indexPath) as! MessageDetailFieldCell
            
            let row = self.detailRows[indexPath.row]
            switch row {
            case .from:
                cell.ibTitleLabel.text = "from"
                cell.ibValueLabel.text = self.header.from.map { $0.preferedDisplayName }.joined(separator: ", ")
            case .to:
                cell.ibTitleLabel.text = "to"
                cell.ibValueLabel.text = self.header.to.map { $0.displayName }.joined(separator: ", ")
            case .cc:
                cell.ibTitleLabel.text = "cc"
                cell.ibValueLabel.text = self.header.cc!.map { $0.displayName }.joined(separator: ", ")
            case .bcc:
                cell.ibTitleLabel.text = "bcc"
                cell.ibValueLabel.text = self.header.bcc!.map { $0.displayName }.joined(separator: ", ")
            case .date:
                cell.ibTitleLabel.text = "date"
                let df = DateFormatter()
                df.calendar = Calendar(identifier: .gregorian)
                df.doesRelativeDateFormatting = true
                df.dateStyle = .short
                df.timeStyle = .short
                cell.ibValueLabel.text = df.string(from: self.header.date!)
            default:
                fatalError()
            }
            return cell
        }
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
