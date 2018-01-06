//
//  MessageAttribute+parseMessageFlags.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/03.
//

import Foundation
import libetpan

extension MessageAttribute {
    static func parseMessageFlags(mailimap_msg_att_dynamic flags: UnsafeMutablePointer<mailimap_msg_att_dynamic>) -> MessageFlag {
        
        guard let flagsList = flags.pointee.att_list else {
            return .none
        }
        var results: MessageFlag = []
        for flagFetch in sequence(flagsList, of: mailimap_flag_fetch.self) {
            switch Int(flagFetch.pointee.fl_type) {
            case MAILIMAP_FLAG_FETCH_RECENT:
                results.formUnion(.recent)
            case MAILIMAP_FLAG_FETCH_OTHER:
                let flag = flagFetch.pointee.fl_flag!
                switch Int(flag.pointee.fl_type) {
                case MAILIMAP_FLAG_FLAGGED:
                    results.formUnion(.flagged)
                case MAILIMAP_FLAG_DELETED:
                    results.formUnion(.deleted)
                case MAILIMAP_FLAG_SEEN:
                    results.formUnion(.seen)
                case MAILIMAP_FLAG_DRAFT:
                    results.formUnion(.draft)
                case MAILIMAP_FLAG_KEYWORD:
                    let keyword = String(cString: flag.pointee.fl_data.fl_keyword!)
                    switch keyword {
                    case "$Forwarded": results.formUnion(.forwarded)
                    case "$MDNSent": results.formUnion(.MDNSent)
                    case "$SubmitPending": results.formUnion(.submitPending)
                    case "$Submitted": results.formUnion(.submitted)
                    default: break
                    }
                default: break
                }
            default: break
            }
        }
        return results
    }
}
