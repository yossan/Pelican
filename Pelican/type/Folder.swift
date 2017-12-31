//
//  Folder.swift
//  Pelican
//
//  Created by yoshi-kou on 2017/12/29.
//

import Foundation

public struct Folder {
    let name: String
    let messagesCount: Int
    let flags: FolderFlag
}

public struct FolderFlag: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let None        = FolderFlag(rawValue: 0)
    public static let Marked      = FolderFlag(rawValue: 1 << 0)
    public static let Unmarked    = FolderFlag(rawValue: 1 << 1)
    public static let NoSelect    = FolderFlag(rawValue: 1 << 2)
    public static let NoInferiors = FolderFlag(rawValue: 1 << 3)
    public static let Inbox       = FolderFlag(rawValue: 1 << 4)
    public static let SentMail    = FolderFlag(rawValue: 1 << 5)
    public static let Starred     = FolderFlag(rawValue: 1 << 6)
    public static let AllMail     = FolderFlag(rawValue: 1 << 7)
    public static let Trash       = FolderFlag(rawValue: 1 << 8)
    public static let Drafts      = FolderFlag(rawValue: 1 << 9)
    public static let Spam        = FolderFlag(rawValue: 1 << 10)
    public static let Important   = FolderFlag(rawValue: 1 << 11)
    public static let Archive     = FolderFlag(rawValue: 1 << 12)
    public static let Folder: FolderFlag = [ .Inbox, .SentMail, .Starred, .AllMail, .Trash, .Drafts, .Spam, .Important, .Archive ]
}
