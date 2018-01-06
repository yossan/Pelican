//
//  Message+imap.swift
//  Pelican
//
//  Created by yoshi-kou on 2018/01/06.
//

import Foundation
import libetpan

extension Message {
    convenience init?(mailimap_msg_att: UnsafeMutablePointer<mailimap_msg_att>) {
        self.init()
        mailimap_msg_att.pointee.parse { (attribute) in
            switch attribute {
            case .dynamic (let mailimap_msg_att_dynamic):
                self.flags = MessageFlag(mailimap_msg_att_dynamic: mailimap_msg_att_dynamic)
                
            case .`static` (let mailimap_msg_att_static):
                mailimap_msg_att_static.pointee.parse(handler: { (attribute) in
                    switch attribute {
                    case .error: break
                    case .uid (let uid):
                        self.uid = uid
                    case .bodystructure (let mailimap_body):
                        self.body = MailPart(mailimap_body: mailimap_body)
                    case .bodySection (let mailimap_msg_att_body_section):
                        mailimap_msg_att_body_section.pointee.parse(handler: { (attribute) in
                            switch attribute {
                            case let .header(message, length):
                                var index: Int = 0
                                var mimeFieldsBox: UnsafeMutablePointer<mailimf_fields>? = nil
                                mailimf_fields_parse(message, length, &index, &mimeFieldsBox)
                                guard let mimeFields = mimeFieldsBox else { return }
                                defer { mailimf_fields_free(mimeFields) }
                                self.header = MessageHeader(mailimf_fields: mimeFields)
                            
//                            case let .part(id, message, length): break
                            default: break
                            }
                        })
                    }
                })
            case .`extension`: break
            }
        }
    }
}
