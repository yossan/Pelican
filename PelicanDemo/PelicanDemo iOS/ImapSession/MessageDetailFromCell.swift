//
//  MessageDetailFromCell.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/07.
//

import UIKit

class MessageDetailFromCell: UITableViewCell {

    @IBOutlet var ibFromLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    class func cellHeight() -> CGFloat {
        return 44.0
    }
}
