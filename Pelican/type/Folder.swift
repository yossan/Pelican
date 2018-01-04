//
//  Folder.swift
//  Pelican
//
//  Created by yoshi-kou on 2017/12/29.
//

import Foundation
import libetpan

public class Folder {
    deinit {
        NSLog("\(type(of: self)).\(#function)")
    }
    
    public let name: String
    public let messagesCount: Int
//    public let allowFlags

    init(name: String, info: UnsafeMutablePointer<mailimap_selection_info>) {
        self.name = name
        self.messagesCount = info.pointee.sel_has_exists == 1 ? Int(info.pointee.sel_exists) : 0
        
        
        /*allowFlags
        for flagParam in sequence(info.pointee.sel_perm_flags, of: mailimap_flag_perm.self) {
            print("type", flagParam.pointee.fl_type) //MAILIMAP_FLAG_PERM_FLAG, MAILIMAP_FLAG_PERM_ALL
            guard let flag = flagParam.pointee.fl_flag else { continue }
            
            switch Int(flag.pointee.fl_type) {
            case MAILIMAP_FLAG_ANSWERED:
                print("flag.fl_type", "MAILIMAP_FLAG_ANSWERED")
            case MAILIMAP_FLAG_FLAGGED:
                 print("flag.fl_type", "MAILIMAP_FLAG_FLAGGED")
            case MAILIMAP_FLAG_DELETED:
                 print("flag.fl_type", "MAILIMAP_FLAG_DELETED")
            case MAILIMAP_FLAG_SEEN:
                 print("flag.fl_type", "MAILIMAP_FLAG_SEEN")
            case MAILIMAP_FLAG_DRAFT:
                 print("flag.fl_type", "MAILIMAP_FLAG_DRAFT")
            case MAILIMAP_FLAG_KEYWORD:
                 print("flag.fl_type", "MAILIMAP_FLAG_KEYWORD")
                let keyword = flag.pointee.fl_data.fl_keyword!
                 print("keyword", String(cString: keyword))
            case MAILIMAP_FLAG_EXTENSION:
                 print("flag.fl_type", "MAILIMAP_FLAG_EXTENSION")
                 let `extension` = flag.pointee.fl_data.fl_extension!
                 print("keyword", String(cString: `extension`))
            default: break
            }
        }
         */
    }
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
