//
//  File.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2017/12/27.
//

import Foundation
import libetpan

public struct MessageFlag: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let none             = MessageFlag(rawValue: 0)
    public static let seen             = MessageFlag(rawValue: 1 << 0)
    public static let answered         = MessageFlag(rawValue: 1 << 1)
    public static let flagged          = MessageFlag(rawValue: 1 << 2)
    public static let deleted          = MessageFlag(rawValue: 1 << 3)
    public static let draft            = MessageFlag(rawValue: 1 << 4)
    public static let MDNSent          = MessageFlag(rawValue: 1 << 5)
    public static let forwarded        = MessageFlag(rawValue: 1 << 6)
    public static let submitPending    = MessageFlag(rawValue: 1 << 7)
    public static let submitted        = MessageFlag(rawValue: 1 << 8)
    public static let recent          = MessageFlag(rawValue: 1 << 9)
    public static let all: MessageFlag = [ .seen, .answered, .flagged, .deleted, .draft, .MDNSent, .forwarded, .submitPending, .submitted ]
}

extension MessageFlag: CustomStringConvertible {
    public var description: String {
        var results: [String] = []
        if self.contains(.none) {
            results.append("none")
        }
        if self.contains(.seen) {
            results.append("seen")
        }
        if self.contains(.answered) {
            results.append("answered")
        }
        if self.contains(.flagged) {
            results.append("flagged")
        }
        if self.contains(.deleted) {
            results.append("deleted")
        }
        if self.contains(.draft) {
            results.append("draft")
        }
        if self.contains(.MDNSent) {
            results.append("MDNSent")
        }
        if self.contains(.forwarded) {
            results.append("forwarded")
        }
        if self.contains(.submitPending) {
            results.append("submitPending")
        }
        if self.contains(.submitted) {
            results.append("submitted")
        }
        if self.contains(.recent) {
            results.append("recent")
        }
        if self.contains(.all) {
            results.append("all")
        }
        
        return results.joined(separator: ",")
    }
}
