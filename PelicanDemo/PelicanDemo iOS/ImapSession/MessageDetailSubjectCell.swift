//
//  MessageDetailSubjectCell.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/07.
//

import UIKit

class MessageDetailSubjectCell: UITableViewCell {

    @IBOutlet var ibSubjectLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func cellHeight(withSubject subject: String?, maxWidth: CGFloat) -> CGFloat {
        guard let subject = subject else {
            return 70.0
        }
        
        let text = subject as NSString
        
        let subjectLabelFont = UIFont(name: "Hiragino Maru Gothic ProN W4", size: 20)!
        return text.boundingRect(
            with: CGSize(width: maxWidth, height: 0),
            options: .usesLineFragmentOrigin,
            attributes: [.font : subjectLabelFont],
            context: nil).height
    }
}
