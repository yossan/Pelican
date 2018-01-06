//
//  Sequence+.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/05.
//

import Foundation

extension Sequence {
    var first: Element? {
        var hit: Element? = nil
        for element in self {
            hit = element
            break
        }
        return hit
    }
}
