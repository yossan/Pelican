//
//  Optional+.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/12.
//

import Foundation

extension Optional where Wrapped == Int {
    static func >(lhs: Int?, rhs: Int) -> Bool {
        if let lhs = lhs {
            return lhs > rhs
        } else {
            return false
        }
    }
}
