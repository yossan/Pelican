//
//  MessageAttribute+parseHeader.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/03.
//

import Foundation
import libetpan

extension MessageAttribute {
    private static func parse(mailimap_section: UnsafeMutablePointer<mailimap_section>) {
        /*
         struct mailimap_section {
         struct mailimap_section_spec * sec_spec; /* can be NULL */
         };
         */
        
    }
    private static func parse(mailimap_section_spec sectionInfo: UnsafeMutablePointer<mailimap_section_spec>) {
        /*
         struct mailimap_section_spec {
         int sec_type;
         union {
         struct mailimap_section_msgtext * sec_msgtext; /* can be NULL */
         struct mailimap_section_part * sec_part;       /* can be NULL */
         } sec_data;
         struct mailimap_section_text * sec_text;       /* can be NULL */
         };

         */
        switch Int(sectionInfo.pointee.sec_type) {
        case MAILIMAP_SECTION_SPEC_SECTION_MSGTEXT:
            let msgText = sectionInfo.pointee.sec_data.sec_msgtext!
            self.parse(mailimap_section_msgtext: msgText)
        case MAILIMAP_SECTION_SPEC_SECTION_PART:
            let part = sectionInfo.pointee.sec_data.sec_part!
            self.parse(mailimap_section_part: part)
        default: break
            
        }
    }
    private static func parse(mailimap_section_part part: UnsafeMutablePointer<mailimap_section_part>) {
        /*
         struct mailimap_section_part {
         clist * sec_id; /* list of nz-number (uint32_t *) */
         /* != NULL */
         };
         */
        for id in sequence(part.pointee.sec_id, of: UInt32.self) {
            print("id", id)
        }
    }
    
    private static func parse(mailimap_section_msgtext msgtext: UnsafeMutablePointer<mailimap_section_msgtext>) {
        /*
         struct mailimap_section_msgtext {
         int sec_type;
         struct mailimap_header_list * sec_header_list; /* can be NULL */
         };
         */
        switch Int(msgtext.pointee.sec_type) {
        case  MAILIMAP_SECTION_MSGTEXT_HEADER: break
        case MAILIMAP_SECTION_MSGTEXT_HEADER_FIELDS: break
        case MAILIMAP_SECTION_MSGTEXT_HEADER_FIELDS_NOT: break
        case MAILIMAP_SECTION_MSGTEXT_TEXT: break
        default: break
        }
        print("msgtext.pointee.sec_type", msgtext.pointee.sec_type)
        if let headers = msgtext.pointee.sec_header_list {
            self.parse(mailimap_header_list: headers)
        }
    }
    
    private static func parse(mailimap_header_list headers: UnsafeMutablePointer<mailimap_header_list>) {
        /*
         struct mailimap_header_list {
         clist * hdr_list; /* list of astring (char *), != NULL */
         };
         */
        for header in sequence(headers.pointee.hdr_list, of: Int8.self) {
            print("header", header)
        }
    }
    
    public static func parseHeader(mailimap_msg_att_body_section bodySection: UnsafeMutablePointer<mailimap_msg_att_body_section>) -> MessageHeader? {
        
        if let sectionInfo = bodySection.pointee.sec_section.pointee.sec_spec {
            self.parse(mailimap_section_spec: sectionInfo)
        }
        
        
        var index: Int = 0
        var headerBox: UnsafeMutablePointer<mailimf_fields>? = nil
        mailimf_fields_parse(bodySection.pointee.sec_body_part, bodySection.pointee.sec_length, &index, &headerBox)
        
        guard let header = headerBox else { return nil }
        defer { mailimf_fields_free(headerBox) }
        
        var messageHeader = MessageHeader()
        for field in sequence(header.pointee.fld_list, of: mailimf_field.self) {
            let data = field.pointee.fld_data
            switch Int(field.pointee.fld_type) {
            case MAILIMF_FIELD_NONE: break
            case MAILIMF_FIELD_RETURN_PATH: break
            case MAILIMF_FIELD_RESENT_DATE: break
            case MAILIMF_FIELD_RESENT_FROM: break
            case MAILIMF_FIELD_RESENT_SENDER: break
            case MAILIMF_FIELD_RESENT_TO: break
            case MAILIMF_FIELD_RESENT_CC: break
            case MAILIMF_FIELD_RESENT_BCC: break
            case MAILIMF_FIELD_RESENT_MSG_ID: break
            case MAILIMF_FIELD_ORIG_DATE:
                let origDate = data.fld_orig_date!
                messageHeader.date = self.parse(mailimf_orig_date: origDate)
            case MAILIMF_FIELD_FROM:
                let fieldFrom = data.fld_from!
                let mailBoxes = self.parse(mailimf_mailbox_list: fieldFrom.pointee.frm_mb_list)
                messageHeader.from = mailBoxes
            case MAILIMF_FIELD_SENDER:
                let sender = data.fld_sender!
                messageHeader.sender = self.parse(mailimf_mailbox: sender.pointee.snd_mb)
            case MAILIMF_FIELD_REPLY_TO:
                let replyTo = data.fld_reply_to!
                messageHeader.replyTo = self.parse(mailimf_address_list: replyTo.pointee.rt_addr_list)
            case MAILIMF_FIELD_TO:
                let to = data.fld_to!
                messageHeader.to = self.parse(mailimf_address_list: to.pointee.to_addr_list)
            case MAILIMF_FIELD_CC:
                let cc = data.fld_cc!
                messageHeader.cc = self.parse(mailimf_address_list: cc.pointee.cc_addr_list)
            case MAILIMF_FIELD_BCC:
                let bcc = data.fld_bcc!
                messageHeader.bcc = self.parse(mailimf_address_list: bcc.pointee.bcc_addr_list)
            case MAILIMF_FIELD_MESSAGE_ID:
                let msgId = data.fld_message_id!
                messageHeader.messageId = String(cString: msgId.pointee.mid_value)
            case MAILIMF_FIELD_IN_REPLY_TO:
                let inReplyTo = data.fld_in_reply_to!
                messageHeader.inReplyTo = self.parse(mailimf_in_reply_to: inReplyTo)
            case MAILIMF_FIELD_REFERENCES:
                let references = data.fld_references!
                messageHeader.references = self.parse(mailimf_references: references)
            case MAILIMF_FIELD_SUBJECT:
                let subject = data.fld_subject!
                messageHeader.subject = self.parse(mailimf_subject: subject)
            case MAILIMF_FIELD_COMMENTS: break
            case MAILIMF_FIELD_KEYWORDS: break
            case MAILIMF_FIELD_OPTIONAL_FIELD:
                let optionalField = data.fld_optional_field!
                let field = self.parse(mailimf_optional_field: optionalField)
                if var optionalField = messageHeader.optionalField {
                    optionalField.merge(field) { (_, new) in new }
                } else {
                    messageHeader.optionalField = field
                }
            default: break
            }
        }
        return messageHeader
    }
    
    static func parse(mailimf_subject subject: UnsafeMutablePointer<mailimf_subject>) -> String {
        /*
         struct mailimf_subject {
         char * sbj_value; /* != NULL */
         };
         */
        
        return self.decodeMIMEHeader(from: subject.pointee.sbj_value)
    }
    
    static private func decodeMIMEHeader(from encodedValue: UnsafeMutablePointer<Int8>) -> String {
        var curToken = 0;
        var decodedValue: UnsafeMutablePointer<Int8>? = nil
        let r = mailmime_encoded_phrase_parse("us-ascii",
                                              encodedValue, strlen(encodedValue),
                                              &curToken, "utf-8", &decodedValue);
        defer { free(decodedValue) }
        if let decodedValue = decodedValue {
            return String(cString: decodedValue)
        } else {
            return String(cString: encodedValue)
        }
    }
    
    static func parse(mailimf_orig_date date: UnsafeMutablePointer<mailimf_orig_date>) -> Date? {
        /*
         struct mailimf_orig_date {
         struct mailimf_date_time * dt_date_time; /* != NULL */
         };
         */
        return parse(mailimf_date_time: date.pointee.dt_date_time!)
    }
    
    static func parse(mailimf_date_time dateTime: UnsafeMutablePointer<mailimf_date_time>) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar(identifier: .gregorian)
        dateComponents.year   = Int(dateTime.pointee.dt_year)
        dateComponents.month  = Int(dateTime.pointee.dt_month)
        dateComponents.day    = Int(dateTime.pointee.dt_day)
        dateComponents.hour   = Int(dateTime.pointee.dt_hour)
        dateComponents.minute = Int(dateTime.pointee.dt_min)
        dateComponents.timeZone = {
            let timeZoneHour = Int(dateTime.pointee.dt_zone / 100)
            let timeZoneMin  = Int(dateTime.pointee.dt_zone % 100)
            let sign = dateTime.pointee.dt_zone > 0 ? 1 : -1
            return TimeZone(secondsFromGMT: sign * 3600 * timeZoneHour + 60 * timeZoneMin)
        }()
        return dateComponents.date
    }
    
    static func parse(mailimf_mailbox_list list: UnsafeMutablePointer<mailimf_mailbox_list>) -> [AddressMailBox] {
        /*
         struct mailimf_mailbox_list {
         clist * mb_list; /* list of (struct mailimf_mailbox *), != NULL */
         };
         */
        var mailBoxes: [AddressMailBox] = []
        for imapMailBox in sequence(list.pointee.mb_list, of: mailimf_mailbox.self) {
            let mailBox = self.parse(mailimf_mailbox: imapMailBox)
            mailBoxes.append(mailBox)
        }
        return mailBoxes
    }
    
    static func parse(mailimf_mailbox mailbox: UnsafeMutablePointer<mailimf_mailbox>) -> AddressMailBox {
        let email = String(cString: mailbox.pointee.mb_addr_spec)
        
        var displayName: String?
        if let display_name = mailbox.pointee.mb_display_name {
            displayName = self.decodeMIMEHeader(from: display_name)
        }
        return AddressMailBox(email: email, displayName: displayName)
    }
    
    static func parse(mailimf_address address: UnsafeMutablePointer<mailimf_address>) -> Address? {
        
        switch Int(address.pointee.ad_type) {
        case MAILIMF_ADDRESS_MAILBOX:
            let value = parse(mailimf_mailbox: address.pointee.ad_data.ad_mailbox)
            return .mailBox(value)
        case MAILIMF_ADDRESS_GROUP:
            let value = parse(mailimf_group: address.pointee.ad_data.ad_group)
            return .group(value)
        case MAILIMF_ADDRESS_ERROR:
            fallthrough
        default:
            return nil
        }
    }
    
    static func parse(mailimf_group group: UnsafeMutablePointer<mailimf_group>) -> AddressGroup {
        let displayName = self.decodeMIMEHeader(from: group.pointee.grp_display_name)
        var mailBoxes: [AddressMailBox] = []
        if let mbList = group.pointee.grp_mb_list {
            for imapMailbox in sequence(mbList.pointee.mb_list, of: mailimf_mailbox.self) {
                let mailBox = parse(mailimf_mailbox: imapMailbox)
                mailBoxes.append(mailBox)
            }
        }
        return AddressGroup(displayName: displayName, mailBoxes: mailBoxes)
    }
    
    static func parse(mailimf_address_list list: UnsafeMutablePointer<mailimf_address_list>) -> [Address] {
        /*
         struct mailimf_address_list {
         clist * ad_list; /* list of (struct mailimf_address *), != NULL */
         };
         */
        var addressList: [Address] = []
        for imapAddress in sequence(list.pointee.ad_list, of: mailimf_address.self) {
            guard let address = self.parse(mailimf_address: imapAddress) else { continue }
            addressList.append(address)
        }
        return addressList
    }
    
    static func parse(mailimf_in_reply_to inreplyto: UnsafeMutablePointer<mailimf_in_reply_to>) -> [String] {
        /*
         struct mailimf_in_reply_to {
         clist * mid_list; /* list of (char *), != NULL */
         };
         */
        var inReplyTo: [String] = []
        for mid in sequence(inreplyto.pointee.mid_list, of: Int8.self) {
            inReplyTo.append(String(cString: mid))
        }
        return inReplyTo
    }
    
    static func parse(mailimf_references references: UnsafeMutablePointer<mailimf_references>) -> [String] {
        /*
         struct mailimf_references {
         clist * mid_list; /* list of (char *) */
         /* != NULL */
         };
         */
        var refers: [String] = []
        for reference in sequence(references.pointee.mid_list, of: Int8.self) {
            refers.append(String(cString: reference))
        }
        return refers
    }
    
    static func parse(mailimf_optional_field optionalField: UnsafeMutablePointer<mailimf_optional_field>) -> [String: String]{
        /*
         struct mailimf_optional_field {
         char * fld_name;  /* != NULL */
         char * fld_value; /* != NULL */
         };
         */
        let name = String(cString: optionalField.pointee.fld_name!)
        let value = String(cString: optionalField.pointee.fld_value!)
        return [name: value]
    }
}
