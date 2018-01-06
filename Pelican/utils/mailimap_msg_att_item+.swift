//
//  mailimap_msg_att_item+.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/05.
//

import Foundation
import libetpan
/*
class MessageAttributesParser {
    let attributes: UnasfeMutablePointer<mailimap_msg_att>
    init(mailimap_msg_att attributes: UnasfeMutablePointer<mailimap_msg_att>) {
        self.attributes = attributes
    }
    enum MessageAttributes {
        case dynamic (UnsafeMutablePointer<mailimap_msg_att_dynamic>)
        case `static` (UnsafeMutablePointer<mailimap_msg_att_static>)
        case `extension` (UnsafeMutablePointer<mailimap_extension_data>)
    }
//    func parse(handler:)
}

class class MessageDynamicAttributeParser {
    enum MessageDynamicAttribute {
        case recent
        case flagged
        case deleted
        case seen
        case draft
        case keyword (String)
    }
}

class class MessageStaticAttributeParser {
    init(mailimap_msg_att_static item: UnsafeMutablePointer<mailimap_msg_att_static>) {
    }
    
    enum MessageStaticAttribute {
        case error
        case uid (UInt32)
        case bodystructure (UnsafeMutablePointer<mailimap_body>)
        case bodySection (UnsafeMutablePointer<mailimap_msg_att_body_section>)
    }
}

extension mailimap_msg_att_item {
    enum
    func parse() {
        let attType = messageAtt.pointee.att_type
        switch Int(attType) {
        case MAILIMAP_MSG_ATT_ITEM_DYNAMIC:
            let dynamicItem = messageAtt.pointee.att_data.att_dyn!
            let flags = self.parseMessageFlags(mailimap_msg_att_dynamic: dynamicItem)
            handler(.messageFlags(flags))
            
        case MAILIMAP_MSG_ATT_ITEM_STATIC:
            let staticItem = messageAtt.pointee.att_data.att_static!
            switch Int(staticItem.pointee.att_type) {
            case MAILIMAP_MSG_ATT_BODYSTRUCTURE:
                let bodyStructure = staticItem.pointee.att_data.att_bodystructure!
                let part = self.parseBody(mailimap_body: bodyStructure)
                handler(.mailPart(part))
            case MAILIMAP_MSG_ATT_BODY_SECTION:
                let bodySection = staticItem.pointee.att_data.att_body_section!
                //        parseBody(mailimap_msg_att_body_section: bodySection)
                guard let header = self.parseHeader(mailimap_msg_att_body_section: bodySection) else { continue }
                handler(.messageHeader(header))
                
            case MAILIMAP_MSG_ATT_UID:
                let value = staticItem.pointee.att_data.att_uid
                handler(.uid(Int(value)))
            default: break
                /*
                 case MAILIMAP_MSG_ATT_ERROR: break
                 case MAILIMAP_MSG_ATT_ENVELOPE: break
                 case MAILIMAP_MSG_ATT_INTERNALDATE: break
                 case MAILIMAP_MSG_ATT_RFC822: break
                 case MAILIMAP_MSG_ATT_RFC822_HEADER: break
                 case MAILIMAP_MSG_ATT_RFC822_TEXT: break
                 case MAILIMAP_MSG_ATT_RFC822_SIZE: break
                 case MAILIMAP_MSG_ATT_BODY: break
                 */
            }
        default: break
        }
    }
}
 */
