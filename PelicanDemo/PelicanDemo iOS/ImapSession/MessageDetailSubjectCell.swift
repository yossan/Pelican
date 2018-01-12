//
//  MessageDetailSubjectCell.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/07.
//

import UIKit

// MARK: - Xib settings
private let DefaultMinimumCellHeight: CGFloat = 76.0
private let SubjectFont: UIFont = UIFont(name: "HelveticaNeue-Bold", size: 20)!
private let OtherVerticalSpacing: CGFloat = 61.5

class MessageDetailSubjectCell: UITableViewCell {

    @IBOutlet var ibSubjectLabel: UILabel!
    @IBOutlet var ibSwitchButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func cellHeight(withSubject subject: String?, cellWidth: CGFloat) -> CGFloat {
        guard let subject = subject else {
            return DefaultMinimumCellHeight
        }
        
        let text = subject as NSString
        let labelHeight = text.boundingRect(
            with: CGSize(width: cellWidth, height: 0),
            options: .usesLineFragmentOrigin,
            attributes: [.font : SubjectFont],
            context: nil).height
        
        let cellHeight = labelHeight + OtherVerticalSpacing
        return max(cellHeight, DefaultMinimumCellHeight)
    }
}
