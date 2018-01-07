//
//  MessageHeader+.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/07.
//

import Foundation
import Pelican

extension AddressMailBox {
    var preferedDisplayName: String {
        return self.displayName ?? self.email
    }
}
