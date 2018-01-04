//
//  AuthorizaionSession+State.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/01.
//

import Foundation
import OAuthClient

extension AuthorizationSession {
    enum State {
        case new
        case tokenExpiration (Token)
        case loginPossible (User)
    }
}
