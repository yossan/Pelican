//
//  AppConfiguration.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2017/12/31.
//

import Foundation

class AppConfiguration {
    static let messageList: MessageListConfiguration = MessageListConfiguration()
}

struct MessageListConfiguration {
    let requestCount: Int = 20
    let maximumCount: Int = 20
}
