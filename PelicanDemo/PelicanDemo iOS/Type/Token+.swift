//
//  Token+.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2017/12/31.
//

import Foundation
import OAuthClient

extension Token {
    var isExpired: Bool {
        return self.expirationDate < Date() 
    }
}
