//
//  MessageHeader.swift
//  Pelican
//
//  Created by yoshi-kou on 2017/12/29.
//

import Foundation

public struct AddressMailBox: CustomStringConvertible {

    public let email:     String
    public var displayName: String?
    
    init(email: String, displayName: String?) {
        self.email = email
        self.displayName = displayName
    }
    
    public var description: String {
        if let displayName = displayName {
            return "email = \(email), displayName = \(displayName)"
        } else {
            return "email = \(email)"
        }
    }
}

public struct AddressGroup: CustomStringConvertible {
    public let displayName: String
    public let mailBoxes: [AddressMailBox]
    
    public var description: String {
        return "displayName = \(displayName) mailBoxes = \(mailBoxes)"
    }
}

public enum Address: CustomStringConvertible {
    /*
     struct mailimf_address {
     int ad_type;
     union {
     struct mailimf_mailbox * ad_mailbox; /* can be NULL */
     struct mailimf_group * ad_group;     /* can be NULL */
     } ad_data;
     };
     */
    case mailBox (AddressMailBox)
    case group (AddressGroup)
    
    public var description: String {
        switch self {
        case .mailBox(let mailBox):
            return ".mailBox (\(mailBox))"
        case .group(let group):
            return ".group(\(group))"
        }
    }
}

public struct MessageHeader: CustomStringConvertible {
    public var messageId : String?
    public var dateComponents : DateComponents?
    public var date      : Date?
    public var subject   : String = ""
    public var from      : [AddressMailBox] = []
    public var to        : [Address] = []
    public var cc        : [Address]?
    public var bcc       : [Address]?
    public var sender    : AddressMailBox?
    public var replyTo   : [Address]?
    public var inReplyTo : [String]?
    public var references : [String]?
    public var optionalField: [String: String]?
    public init() {}

    public var description: String {
        let p_messageId = messageId ?? ""
        let p_date = date != nil ? "\(date!)" : ""
        let p_cc = cc != nil ? "\(cc!)" : ""
        let p_bcc = bcc != nil ? "\(bcc!)" : ""
        let p_sender = sender != nil ? "\(sender!)" : ""
        let p_replyTo = replyTo != nil ? "\(replyTo!)" :  ""
        let p_inReplyTo = inReplyTo != nil ? "\(inReplyTo!)" : ""
        let p_references = references != nil ? "\(references!)" : ""
        let p_optionalField = optionalField != nil ? "\(optionalField!)" : ""
        return "messageId = \(p_messageId), date = \(p_date), subject = \(subject), from = \(from), cc = \(p_cc), bcc = \(p_bcc), sender = \(p_sender), replyTo = \(p_replyTo), inReplyTo = \(p_inReplyTo), references = \(p_references), optionalField = \(p_optionalField)"
    }
}

