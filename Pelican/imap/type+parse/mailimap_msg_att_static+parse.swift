//
//  mailimap_msg_att_static+parse.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/06.
//

import Foundation
import libetpan

extension mailimap_msg_att_static {
    
    enum StaticMessageAttribute {
        case error
        case uid (UInt32)
        case bodystructure (UnsafeMutablePointer<mailimap_body>)
        case bodySection (UnsafeMutablePointer<mailimap_msg_att_body_section>)
    }
    
    func parse(handler: (StaticMessageAttribute)->()) {
        switch Int(self.att_type) {
        case MAILIMAP_MSG_ATT_BODYSTRUCTURE:
            let value = self.att_data.att_bodystructure!
            handler(.bodystructure(value))
        case MAILIMAP_MSG_ATT_BODY_SECTION:
            let value = self.att_data.att_body_section!
            handler(.bodySection(value))
        case MAILIMAP_MSG_ATT_UID:
            let value = self.att_data.att_uid
            handler(.uid(value))
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
    }
}
