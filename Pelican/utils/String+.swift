//
//  String+.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2017/12/24.
//

import Foundation

extension UnsafeMutablePointer where Pointee == Int8 {
    var string: String {
        return String(cString: self)
    }
}
