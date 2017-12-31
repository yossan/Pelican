//
//  MessageHeader.swift
//  Pelican
//
//  Created by yoshi-kou on 2017/12/29.
//

import Foundation

public struct MessageHeader {
    let messageId : String?
    let date      : Date
    let subject   : String?
    let from      : [Address]
    let to        : [Address]
    let cc        : [Address]
    let bcc       : [Address]
    let replyTo   : [Address]
    let inReplyTo : String?
}

public extension MessageHeader {
    struct Address {
        let email: String
        let personalName: String?
    }
}
