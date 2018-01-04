//
//  User.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2017/12/31.
//

import Foundation
import OAuthClient

class User: Codable {
    var email: String?
    var token: Token?
    
    static func new() -> User {
        return User()
    }
    
    var isNew: Bool {
        if email != nil && token != nil {
            return false
        }
        return true
    }
}
