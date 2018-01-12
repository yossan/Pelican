//
//  MessageDetailFieldCell.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/07.
//

import UIKit

// Xib settings
private let DefaultMinimumCellHaight: CGFloat = 40.0
private let TitleLabelFont = UIFont(name: "HelveticaNeue", size: 17)!
private let ValueLabelFont = UIFont(name: "HelveticaNeue", size: 17)!
private let TitleLabelMaxWidth: CGFloat = 41.0
private let OtherVerticalSpacing: CGFloat = 20.0
private let OtherHorizontalSpacing: CGFloat = 20.0

class MessageDetailFieldCell: UITableViewCell {

    @IBOutlet var ibTitleLabel: UILabel!
    @IBOutlet var ibValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    class func cellHeight(withTitle title: String, value: String, cellWidth: CGFloat) -> CGFloat {
        let titleLabelSize = self.titleLableSize(withTitle: title)
        let valueLabelSize = self.sizeOfText(value, font: ValueLabelFont, options: .usesLineFragmentOrigin, maxWidth: cellWidth - OtherHorizontalSpacing - titleLabelSize.width)
        let cellHeight = valueLabelSize.height + OtherVerticalSpacing
        return max(cellHeight, DefaultMinimumCellHaight)
    }
    
    class func titleLableSize(withTitle title: String) -> CGSize {
        return self.sizeOfText(title, font: TitleLabelFont, options: [], maxWidth: TitleLabelMaxWidth)
    }
    
    class func sizeOfText(_ text: String, font: UIFont, options: NSStringDrawingOptions, maxWidth: CGFloat) -> CGSize {
        let text = text as NSString
        let labelSize = text.boundingRect(
            with: CGSize(width: maxWidth, height: 0),
            options: options,
            attributes: [.font : font],
            context: nil).size
        return labelSize
    }
}
