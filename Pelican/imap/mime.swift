//
//  mime.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2017/12/27.
//

import Foundation
import libetpan

public func parseBody(mailimap_msg_att_body_section bodySection: UnsafeMutablePointer<mailimap_msg_att_body_section>) {
    var index: Int = 0
    var bodyBox: UnsafeMutablePointer<mailimf_body>? = nil
    mailimf_body_parse(bodySection.pointee.sec_body_part, bodySection.pointee.sec_length, &index, &bodyBox)
    if let body = bodyBox {
        print2(mailimf_body: body)
    }
}

func print2(mailimf_body mbody: UnsafeMutablePointer<mailimf_body>) {
    /*
     struct mailimf_body {
     const char * bd_text; /* != NULL */
     size_t bd_size;
     };
     */
    print("mailimf_body:")
    print("bd_size", mbody.pointee.bd_size)
    print("bd_text", String(cString: mbody.pointee.bd_text))
}

public func parseHeader(mailimap_msg_att_body_section bodySection: UnsafeMutablePointer<mailimap_msg_att_body_section>) {
    var headerBox: UnsafeMutablePointer<mailimf_fields>? = nil //mailimf_fields_new_empty()
    var index: Int = 0
    mailimf_fields_parse(bodySection.pointee.sec_body_part, bodySection.pointee.sec_length, &index, &headerBox)
    
    guard let header = headerBox else {
        return
    }
    
    print("header fileds count", header.pointee.fld_list.pointee.count)
    
    for field in sequence(header.pointee.fld_list, of: mailimf_field.self) {
        let data = field.pointee.fld_data
        switch Int(field.pointee.fld_type) {
        case MAILIMF_FIELD_NONE: break
        case MAILIMF_FIELD_RETURN_PATH:
            print("MAILIMF_FIELD_RETURN_PATH")
            let returnPath = data.fld_return_path!
            print2(mailimf_return: returnPath)
        case MAILIMF_FIELD_RESENT_DATE:
            print("MAILIMF_FIELD_RESENT_DATE")
            let resentDate = data.fld_resent_date!
            print2(mailimf_orig_date: resentDate)
        case MAILIMF_FIELD_RESENT_FROM:
            print("MAILIMF_FIELD_RESENT_FROM")
            let resentFrom = data.fld_resent_from!
            print2(mailimf_from: resentFrom)
        case MAILIMF_FIELD_RESENT_SENDER:
            print("MAILIMF_FIELD_RESENT_SENDER")
            let resentSender = data.fld_resent_sender!
            print2(mailimf_sender: resentSender)
        case MAILIMF_FIELD_RESENT_TO:
            print("MAILIMF_FIELD_RESENT_TO")
            let resentTo = data.fld_resent_to!
            print2(mailimf_to: resentTo)
        case MAILIMF_FIELD_RESENT_CC:
            print("MAILIMF_FIELD_RESENT_CC")
            let resentCc = data.fld_resent_cc!
            print2(mailimf_cc: resentCc)
        case MAILIMF_FIELD_RESENT_BCC:
            print("MAILIMF_FIELD_RESENT_BCC")
            let resentBcc = data.fld_resent_bcc!
            print2(mailimf_bcc: resentBcc)
        case MAILIMF_FIELD_RESENT_MSG_ID:
            print("MAILIMF_FIELD_RESENT_MSG_ID")
            let msgId = data.fld_resent_msg_id!
            print2(mailimf_message_id: msgId)
        case MAILIMF_FIELD_ORIG_DATE:
            print("MAILIMF_FIELD_ORIG_DATE")
            let origDate = data.fld_orig_date!
            print2(mailimf_orig_date: origDate)
        case MAILIMF_FIELD_FROM:
            print("MAILIMF_FIELD_FROM")
            let fieldFrom = data.fld_from!
            print2(mailimf_from: fieldFrom)
        case MAILIMF_FIELD_SENDER:
            print("MAILIMF_FIELD_SENDER")
            let sender = data.fld_sender!
            print2(mailimf_sender: sender)
        case MAILIMF_FIELD_REPLY_TO:
            print("MAILIMF_FIELD_REPLY_TO")
            let replyTo = data.fld_reply_to!
            print2(mailimf_reply_to: replyTo)
        case MAILIMF_FIELD_TO:
            print("MAILIMF_FIELD_TO")
            let to = data.fld_to!
            print2(mailimf_to: to)
        case MAILIMF_FIELD_CC:
            print("MAILIMF_FIELD_CC")
            let cc = data.fld_cc!
            print2(mailimf_cc: cc)
        case MAILIMF_FIELD_BCC:
            print("MAILIMF_FIELD_BCC")
            let bcc = data.fld_bcc!
            print2(mailimf_bcc: bcc)
        case MAILIMF_FIELD_MESSAGE_ID:
            print("MAILIMF_FIELD_MESSAGE_ID")
            let msgId = data.fld_message_id!
            print2(mailimf_message_id: msgId)
        case MAILIMF_FIELD_IN_REPLY_TO:
            print("MAILIMF_FIELD_IN_REPLY_TO")
            let inreplyto = data.fld_in_reply_to!
            print2(mailimf_in_reply_to: inreplyto)
        case MAILIMF_FIELD_REFERENCES:
            print("MAILIMF_FIELD_REFERENCES")
            let references = data.fld_references!
            print2(mailimf_references: references)
        case MAILIMF_FIELD_SUBJECT:
            print("MAILIMF_FIELD_SUBJECT")
            let subject = data.fld_subject!
            print2(mailimf_subject: subject)
        case MAILIMF_FIELD_COMMENTS:
            print("MAILIMF_FIELD_COMMENTS")
            let comments = data.fld_comments!
            print2(mailimf_comments: comments)
        case MAILIMF_FIELD_KEYWORDS:
            print("MAILIMF_FIELD_KEYWORDS")
            let keywords = data.fld_keywords!
            print2(mailimf_keywords: keywords)
        case MAILIMF_FIELD_OPTIONAL_FIELD:
            print("MAILIMF_FIELD_OPTIONAL_FIELD")
            let optionalField = data.fld_optional_field!
            print2(mailimf_optional_field: optionalField)
        default: break
        }
    }
}

func print2(mailimf_return ret: UnsafeMutablePointer<mailimf_return>) {
    /*
     struct mailimf_return {
     struct mailimf_path * ret_path; /* != NULL */
     };
     */
    print("mailimf_return")
    print2(mailimf_path: ret.pointee.ret_path!)
}

func print2(mailimf_path path: UnsafeMutablePointer<mailimf_path>) {
    /*
     struct mailimf_path {
     char * pt_addr_spec; /* can be NULL */
     };
     */
    print("mailimf_path")
    if let addr_spec = path.pointee.pt_addr_spec {
        print(" addr_spec", String(cString: addr_spec))
    }
}

func print2(mailimf_optional_field optionalField: UnsafeMutablePointer<mailimf_optional_field>) {
    /*
     struct mailimf_optional_field {
     char * fld_name;  /* != NULL */
     char * fld_value; /* != NULL */
     };
     */
    print("mailimf_optional_field:")
    print(" fld_name", String(cString: optionalField.pointee.fld_name!))
    print(" fld_value", String(cString: optionalField.pointee.fld_value!))
}

func print2(mailimf_keywords keywords: UnsafeMutablePointer<mailimf_keywords>) {
    /*
     struct mailimf_keywords {
     clist * kw_list; /* list of (char *), != NULL */
     };
     */
    print("mailimf_keywords:")
    for keyword in sequence(keywords.pointee.kw_list, of: UInt8.self) {
        print(" keyword", String(cString: keyword))
    }
}

func print2(mailimf_comments comments: UnsafeMutablePointer<mailimf_comments>) {
    /*
     struct mailimf_comments {
     char * cm_value; /* != NULL */
     };
     */
    print("mailimf_comments", comments.pointee.cm_value!)
}

func print2(mailimf_subject subject: UnsafeMutablePointer<mailimf_subject>) {
    /*
     struct mailimf_subject {
     char * sbj_value; /* != NULL */
     };
     */
    print("mailimf_subject:")
    print(" sbj_value", String(cString: subject.pointee.sbj_value))
    
    let value = subject.pointee.sbj_value
    var cur_token = 0;
    var decoded_value: UnsafeMutablePointer<Int8>? = nil
    let r = mailmime_encoded_phrase_parse("us-ascii",
                                          value, strlen(value),
                                          &cur_token, "utf-8", &decoded_value);
    print(r)
    if let decoded_value = decoded_value {
        print("decodedValue", String(cString: decoded_value))
    } else {
        print("decoded value is nil")
    }
}

func print2(mailimf_references references: UnsafeMutablePointer<mailimf_references>) {
    /*
     struct mailimf_references {
     clist * mid_list; /* list of (char *) */
     /* != NULL */
     };
     */
    print("mailimf_references: ")
    for reference in sequence(references.pointee.mid_list, of: Int8.self) {
        print(" ",  String(cString: reference))
    }
}

func print2(mailimf_in_reply_to inreplyto: UnsafeMutablePointer<mailimf_in_reply_to>) {
    /*
     struct mailimf_in_reply_to {
     clist * mid_list; /* list of (char *), != NULL */
     };
     */
    print("mailimf_in_reply_to: ")
    for mid in sequence(inreplyto.pointee.mid_list, of: Int8.self) {
        print(" ", String(cString: mid))
    }
}

func print2(mailimf_bcc bcc: UnsafeMutablePointer<mailimf_bcc>) {
    /*
     struct mailimf_cc {
     struct mailimf_address_list * cc_addr_list; /* != NULL */
     };
     */
    print2(mailimf_address_list: bcc.pointee.bcc_addr_list)
}

func print2(mailimf_cc cc: UnsafeMutablePointer<mailimf_cc>) {
    /*
     struct mailimf_cc {
     struct mailimf_address_list * cc_addr_list; /* != NULL */
     };
     */
    print2(mailimf_address_list: cc.pointee.cc_addr_list)
}

func print2(mailimf_to to: UnsafeMutablePointer<mailimf_to>) {
    /*
     struct mailimf_to {
     struct mailimf_address_list * to_addr_list; /* != NULL */
     
     };*/
    print2(mailimf_address_list: to.pointee.to_addr_list!)
}

func print2(mailimf_reply_to replyTo: UnsafeMutablePointer<mailimf_reply_to>) {
    /*
     struct mailimf_reply_to {
     struct mailimf_address_list * rt_addr_list; /* != NULL */
     };
     */
    print2(mailimf_address_list: replyTo.pointee.rt_addr_list!)
}

func print2(mailimf_sender sender: UnsafeMutablePointer<mailimf_sender>) {
    /*
     struct mailimf_sender {
     struct mailimf_mailbox * snd_mb; /* != NULL */
     };
     */
    print2(mailimf_mailbox: sender.pointee.snd_mb!)
}

func print2(mailimf_from from: UnsafeMutablePointer<mailimf_from>) {
    /*
     struct mailimf_from {
     struct mailimf_mailbox_list * frm_mb_list; /* != NULL */
     };
     */
    print2(mailimf_mailbox_list: from.pointee.frm_mb_list)
}

func print2(mailimf_orig_date origDate: UnsafeMutablePointer<mailimf_orig_date>) {
    /*
     struct mailimf_orig_date {
     struct mailimf_date_time * dt_date_time; /* != NULL */
     };
     */
    print2(mailimf_date_time: origDate.pointee.dt_date_time!)
}

func print2(mailimf_date_time dateTime: UnsafeMutablePointer<mailimf_date_time>) {
    let date = dateTime.pointee
    print(" date time", date.dt_year, date.dt_month, date.dt_day, date.dt_hour, date.dt_min, date.dt_sec, date.dt_zone)
}

func print2(mailimf_message_id msgId: UnsafeMutablePointer<mailimf_message_id>) {
    /*
     struct mailimf_message_id {
     char * mid_value; /* != NULL */
     };
     */
    print("mid_value", String(cString: msgId.pointee.mid_value))
}

func print2(mailimf_address_list addressList: UnsafeMutablePointer<mailimf_address_list>) {
    print("mailimf addresslist:")
    for address in sequence(addressList.pointee.ad_list, of: mailimf_address.self) {
        print2(mailimf_address: address)
    }
}

func print2(mailimf_address address: UnsafeMutablePointer<mailimf_address>) {
    /*
     struct mailimf_address {
     int ad_type;
     union {
     struct mailimf_mailbox * ad_mailbox; /* can be NULL */
     struct mailimf_group * ad_group;     /* can be NULL */
     } ad_data;
     };
     */
    switch Int(address.pointee.ad_type) {
    case MAILIMF_ADDRESS_MAILBOX:
        let mailbox = address.pointee.ad_data.ad_mailbox!
        print("mailbox:")
        print2(mailimf_mailbox: mailbox)
    case MAILIMF_ADDRESS_GROUP:
        let group = address.pointee.ad_data.ad_group!
        print("group:")
        print2(mailimf_group: group)
    case MAILIMF_ADDRESS_ERROR: fallthrough
    default: break
    }
}

func print2(mailimf_group group: UnsafeMutablePointer<mailimf_group>) {
    /*
     struct mailimf_group {
     char * grp_display_name; /* != NULL */
     struct mailimf_mailbox_list * grp_mb_list; /* can be NULL */
     };
     */
    print(" display_name", group.pointee.grp_display_name)
    print2(mailimf_mailbox_list: group.pointee.grp_mb_list)
}

func print2(mailimf_mailbox_list mailboxlist: UnsafeMutablePointer<mailimf_mailbox_list>) {
    print("mailboxlist:")
    for mailbox in sequence(mailboxlist.pointee.mb_list, of: mailimf_mailbox.self) {
        print2(mailimf_mailbox: mailbox)
    }
}

func print2(mailimf_mailbox mailbox: UnsafeMutablePointer<mailimf_mailbox>) {
    /*
     struct mailimf_mailbox {
     char * mb_display_name; /* can be NULL */
     char * mb_addr_spec;    /* != NULL */
     };)
     */
    if let displayName = mailbox.pointee.mb_display_name {
        print(" display_name", String(cString: displayName))
    }
    print(" addr_spec", String(cString: mailbox.pointee.mb_addr_spec))
}

