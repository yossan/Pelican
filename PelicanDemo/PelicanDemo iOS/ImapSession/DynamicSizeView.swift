//
//  DynamicSizeView.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/11.
//

import UIKit

@objc
protocol DynamicSizeViewDelegate: NSObjectProtocol {
    @objc optional func intrinsicContentSizeForDynamicSizeView(_ view: DynamicSizeView) -> CGSize
}

class DynamicSizeView: UIView {
    @IBOutlet weak var delegate: DynamicSizeViewDelegate?
    
    override var intrinsicContentSize: CGSize {
        return self.delegate?.intrinsicContentSizeForDynamicSizeView?(self) ?? .zero
    }
}
