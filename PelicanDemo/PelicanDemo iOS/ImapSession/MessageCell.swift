//
//  MessageCell.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/03.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet var ibSubjectLabel: UILabel!
    @IBOutlet var ibFromLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
