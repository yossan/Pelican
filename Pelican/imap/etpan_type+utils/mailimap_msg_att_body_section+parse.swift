//
//  mailimap_msg_att_body_section+parse.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/06.
//

import Foundation
import libetpan

extension mailimap_msg_att_body_section {
    enum BodySection {
        case header (message: UnsafeMutablePointer<Int8>, length: size_t)
        case text   (message: UnsafeMutablePointer<Int8>, length: size_t)
        case part   (id: String, message: UnsafeMutablePointer<Int8>, length: size_t)
    }
    
    func parse(handler: (BodySection)->()) {
        /*
         struct mailimap_msg_att_body_section {
         struct mailimap_section * sec_section; /* != NULL */
         uint32_t sec_origin_octet;
         char * sec_body_part; /* can be NULL */
         size_t sec_length;
         };

         */
        guard let secInfo = self.sec_section.pointee.sec_spec else {
            return
        }
        switch Int(secInfo.pointee.sec_type) {
        case MAILIMAP_SECTION_SPEC_SECTION_MSGTEXT:
            let msgtext = secInfo.pointee.sec_data.sec_msgtext!
            switch Int(msgtext.pointee.sec_type) {
            case MAILIMAP_SECTION_MSGTEXT_HEADER:
                handler(.header(message: self.sec_body_part, length: self.sec_length))
            case MAILIMAP_SECTION_MSGTEXT_TEXT:
                handler(.text(message: self.sec_body_part, length: self.sec_length))
            case MAILIMAP_SECTION_MSGTEXT_HEADER_FIELDS: fallthrough
            case MAILIMAP_SECTION_MSGTEXT_HEADER_FIELDS_NOT: fallthrough
            default: break
            }
        case MAILIMAP_SECTION_SPEC_SECTION_PART:
            let part = secInfo.pointee.sec_data.sec_part!
            let partId = sequence(part.pointee.sec_id, of: UInt32.self).reduce(into: "", { (accumulator, partialId) in
                accumulator = "\(accumulator).\(partialId)"
            })
            handler(.part(id: partId, message: self.sec_body_part, length: self.sec_length))
        default: break
        }
    }
}
