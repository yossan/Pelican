//
//  MessageAttributeParser.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/02.
//

import Foundation
import libetpan

/*
 Fetch result parser
 - uid:  a uniqu message identifier in Folder. this value will be always callbacked.
 - messageFlags : Include messageHeader when fetch request.
 - messageHeader: Include messageHeader when fetch request.
 - messageBody  : Include bodyStructure when fetch request.
 */
enum MessageAttribute {
    case uid (Int)
    case messageFlags  (MessageFlag)
    case messageHeader (MessageHeader)
    case mailPart      (MailPart)
    
    static func parse(mailimap_msg_att message: UnsafeMutablePointer<mailimap_msg_att>, handler: (MessageAttribute) -> ()) {
        
        for messageAtt in sequence(message.pointee.att_list, of: mailimap_msg_att_item.self) {
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

    
}

