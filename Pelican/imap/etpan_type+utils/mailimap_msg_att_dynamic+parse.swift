//
//  mailimap_msg_att_dynamic+parse.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/06.
//

import Foundation
import libetpan

extension mailimap_msg_att_dynamic {
    enum DynamicMessageAttribute {
        case none
        case recent
        case flagged
        case deleted
        case seen
        case draft
        case keyword (String)
    }
    
    func parse(handler: (DynamicMessageAttribute)->()) {
        guard let flags = self.att_list else {
            handler(.none)
            return
        }
        
        for flag in sequence(flags, of: mailimap_flag_fetch.self) {
            switch Int(flag.pointee.fl_type) {
            case MAILIMAP_FLAG_FETCH_RECENT:
                handler(.recent)
            case MAILIMAP_FLAG_FETCH_OTHER:
                let flag = flag.pointee.fl_flag!
                switch Int(flag.pointee.fl_type) {
                case MAILIMAP_FLAG_FLAGGED:
                    handler(.flagged)
                case MAILIMAP_FLAG_DELETED:
                    handler(.deleted)
                case MAILIMAP_FLAG_SEEN:
                    handler(.seen)
                case MAILIMAP_FLAG_DRAFT:
                    handler(.draft)
                case MAILIMAP_FLAG_KEYWORD:
                    let value = String(cString: flag.pointee.fl_data.fl_keyword!)
                    handler(.keyword(value))
                default: break
                }
            default: break
            }
        }
    }
}
