//
//  Message.swift
//  Pelican
//
//  Created by yoshi-kou on 2017/12/29.
//

import Foundation
import libetpan

public class Message: CustomStringConvertible {
    public var uid    : UInt32 = 0
    public var flags  : MessageFlag?
    public var header : MessageHeader?
    public var body   : MailPart?
    
    deinit {
        NSLog("\(type(of: self)).\(#function)")
    }
    
    public var description: String {
        let body = self.body != nil ? "\(self.body!)" : ""
        return "uid = \(uid), flags = \(flags), header = \(header), body = \(body)"
    }
}
