//
//  GmailConfiguration.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2017/12/31.
//

import Foundation

class GmailConfiguration {
    let host: String = "imap.gmail.com"
    let port: UInt16 = 993
    let deliminator: String = "/"
    
    let getUserURL = URL(string: "https://www.googleapis.com/gmail/v1/users/me/profile")!
}
