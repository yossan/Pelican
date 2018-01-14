//
//  mailimap_msg_att+parse.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/06.
//

import Foundation
import libetpan

extension mailimap_msg_att {
    
    enum MessageAttributes {
        case dynamic (UnsafeMutablePointer<mailimap_msg_att_dynamic>)
        case `static` (UnsafeMutablePointer<mailimap_msg_att_static>)
        case `extension` (UnsafeMutablePointer<mailimap_extension_data>)
    }
    
    func parse(handler: (MessageAttributes) -> ()) {
        for attribute in sequence(self.att_list, of: mailimap_msg_att_item.self) {
            let attributeType = attribute.pointee.att_type
            switch Int(attributeType) {
            case MAILIMAP_MSG_ATT_ITEM_DYNAMIC:
                let value = attribute.pointee.att_data.att_dyn!
                handler(.dynamic(value))
            case MAILIMAP_MSG_ATT_ITEM_STATIC:
                let value = attribute.pointee.att_data.att_static!
                handler(.`static`(value))
            case MAILIMAP_MSG_ATT_ITEM_EXTENSION:
                let value = attribute.pointee.att_data.att_extension_data!
                handler(.`extension`(value))
            default:
                break
            }
        }
    }
}
