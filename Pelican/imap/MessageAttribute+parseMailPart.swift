//
//  MessageAttribute+parseMailPart.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/03.
//

import Foundation
import libetpan

extension MessageAttribute {
    static func parseMailPart(mailimap_body body: UnsafeMutablePointer<mailimap_body>) -> MailPart {
        /*
         int bd_type;
         /* can be MAILIMAP_BODY_1PART or MAILIMAP_BODY_MPART */
         union {
         struct mailimap_body_type_1part * bd_body_1part; /* can be NULL */
         struct mailimap_body_type_mpart * bd_body_mpart; /* can be NULL */
         } bd_data;
         */
        switch Int(body.pointee.bd_type) {
        case MAILIMAP_BODY_MPART:
            let mpart = body.pointee.bd_data.bd_body_mpart!
            return parse(mailimap_body_type_mpart: mpart, partId: nil)
        case MAILIMAP_BODY_1PART:
            return parse(mailimap_body_type_1part: body.pointee.bd_data.bd_body_1part, partId: "1")
        default:
            fatalError()
        }
    }
    
    static private func parse(mailimap_body_type_mpart mpart: UnsafeMutablePointer<mailimap_body_type_mpart>, partId: String? = nil) -> MailPart {
        /*
         struct mailimap_body_type_mpart {
         clist * bd_list; /* list of (struct mailimap_body *) */
         /* != NULL */
         char * bd_media_subtype; /* != NULL */
         struct mailimap_body_ext_mpart * bd_ext_mpart; /* can be NULL */
         };
         */
        
        let type: MultipartType = {
            let subType = String(cString: mpart.pointee.bd_media_subtype)
            switch subType {
            case "RELATED":
                return .related
            case "ALTERNATIVE":
                return .alternative
            default:
                return .notSupported
            }
        }()
        
        var parts: [MailPart] = []
        for (i, body) in sequence(mpart.pointee.bd_list, of: mailimap_body.self).enumerated() {
           
            let part: MailPart = {
                let id = partId == nil ? "\(i+1)" : "\(partId!).\(i+1)"
                switch Int(body.pointee.bd_type) {
                case MAILIMAP_BODY_MPART:
                    let mpart = body.pointee.bd_data.bd_body_mpart!
                    return self.parse(mailimap_body_type_mpart: mpart, partId: id)
                case MAILIMAP_BODY_1PART:
                    
                    return self.parse(mailimap_body_type_1part: body.pointee.bd_data.bd_body_1part, partId: id)
                default:
                    fatalError()
                }
            }()
           
            parts.append(part)
        }
        
        var boundary: String? = nil
        if let ext = mpart.pointee.bd_ext_mpart,
            let bd_param = ext.pointee.bd_parameter {
            let params = self.parse(mailimap_body_fld_param: bd_param)
            boundary = params["BOUNDARY"]
        }
        
        return .multiPart(id: partId, type: type, parts: parts, boundary: boundary)
    }
    
    static private func parse(mailimap_body_type_1part body: UnsafeMutablePointer<mailimap_body_type_1part>, partId: String) -> MailPart {
        /*
         struct mailimap_body_type_1part {
         int bd_type;
         union {
         struct mailimap_body_type_basic * bd_type_basic; /* can be NULL */
         struct mailimap_body_type_msg * bd_type_msg;     /* can be NULL */
         struct mailimap_body_type_text * bd_type_text;   /* can be NULL */
         } bd_data;
         struct mailimap_body_ext_1part * bd_ext_1part;   /* can be NULL */
         };
         */
        switch Int(body.pointee.bd_type) {
        case MAILIMAP_BODY_TYPE_1PART_BASIC:
            
            let basic = body.pointee.bd_data.bd_type_basic!
            
            let (mediaType, bodyFields) = parse(mailimap_body_type_basic: basic)
            
            var disposition: Disposition = .unknown
            if let bd_ext_1part = body.pointee.bd_ext_1part,
                let bd_disposition =  bd_ext_1part.pointee.bd_disposition {
                disposition = parse(mailimap_body_fld_dsp: bd_disposition)
            }
            
            return .singlePart(id: partId, type: .basic(type: mediaType, disposition: disposition, fields: bodyFields))
            
        case MAILIMAP_BODY_TYPE_1PART_TEXT:
            let text =  body.pointee.bd_data.bd_type_text!
            let (textType, bodyFields) = parse(mailimap_body_type_text: text)
            return .singlePart(id: partId, type: .text(type: textType, fields: bodyFields))
        case MAILIMAP_BODY_TYPE_1PART_MSG:
            let msg = body.pointee.bd_data.bd_type_msg!
            return parse(mailimap_body_type_msg: msg, partId: partId)
        default:
            fatalError()
            break
        }
    }
    
    static private func parse(mailimap_body_type_basic body: UnsafeMutablePointer<mailimap_body_type_basic>) -> (MediaType, BodyFields) {
        /*
         struct mailimap_body_type_basic {
         struct mailimap_media_basic * bd_media_basic; /* != NULL */
         struct mailimap_body_fields * bd_fields; /* != NULL */
         };
         */
        
        let media_basic = body.pointee.bd_media_basic!
        let mediaType = parse(mailimap_media_basic: media_basic)
        
        let bd_fields = body.pointee.bd_fields!
        let bodyFields = parse(bd_fields: bd_fields)
        
        return (mediaType, bodyFields)
    }
    
    static private func parse(mailimap_media_basic media: UnsafeMutablePointer<mailimap_media_basic>) -> MediaType {
        /*
         struct mailimap_media_basic {
         int med_type;
         char * med_basic_type; /* can be NULL */
         char * med_subtype;    /* != NULL */
         };
         */
        
        let subtype: String = String(cString: media.pointee.med_subtype)
        switch Int(media.pointee.med_type) {
        case MAILIMAP_MEDIA_BASIC_APPLICATION:
            return .application(subtype: subtype)
        case MAILIMAP_MEDIA_BASIC_AUDIO:
            return .audio(subtype: subtype)
        case MAILIMAP_MEDIA_BASIC_IMAGE:
            return .image(subtype: subtype)
        case MAILIMAP_MEDIA_BASIC_MESSAGE:
            return .message(subtype: subtype)
        case MAILIMAP_MEDIA_BASIC_VIDEO:
            return .video(subtype: subtype)
        case MAILIMAP_MEDIA_BASIC_OTHER: fallthrough
        default:
            return .other(subtype: subtype)
        }
    }
    
    static private func parse(mailimap_body_type_text text: UnsafeMutablePointer<mailimap_body_type_text>) -> (TextType, BodyFields) {
        /*
         struct mailimap_body_type_text {
         char * bd_media_text;                         /* != NULL */
         struct mailimap_body_fields * bd_fields; /* != NULL */
         uint32_t bd_lines;
         };
         */
        let textType: TextType = {
            let bd_media_text = text.pointee.bd_media_text!
            switch String(cString: bd_media_text) {
            case "PLAIN":
                return .plain
            case "HTML":
                return .html
            default:
                return .notSupported
            }
        }()
        
        let bodyFields = parse(bd_fields: text.pointee.bd_fields!)
        
        return (textType, bodyFields)
    }
    
    
    static private func parse(mailimap_body_type_msg msg: UnsafeMutablePointer<mailimap_body_type_msg>, partId: String) -> MailPart {
        /*
         struct mailimap_body_type_msg {
         struct mailimap_body_fields * bd_fields; /* != NULL */
         struct mailimap_envelope * bd_envelope;       /* != NULL */
         struct mailimap_body * bd_body;               /* != NULL */
         uint32_t bd_lines;
         };
         */
        let bodyFields = parse(bd_fields: msg.pointee.bd_fields!)
        let mailPart   = self.parseMailPart(mailimap_body: msg.pointee.bd_body!)
        let messageHeader = parse(mailimap_envelope: msg.pointee.bd_envelope!)
        
        return .singlePart(id: partId, type: .message(header: messageHeader, fields: bodyFields, body: mailPart))
    }
    
    
    static private func parse(bd_fields: UnsafeMutablePointer<mailimap_body_fields>) -> BodyFields {
        /*
         struct mailimap_body_fields {
         struct mailimap_body_fld_param * bd_parameter; /* can be NULL */
         char * bd_id;                                  /* can be NULL */
         char * bd_description;                         /* can be NULL */
         struct mailimap_body_fld_enc * bd_encoding;    /* != NULL */
         uint32_t bd_size;
         };
         */
        var bodyFields: BodyFields = {
            let size = bd_fields.pointee.bd_size
            let bdEncoding = self.parse(mailimap_body_fld_enc: bd_fields.pointee.bd_encoding)
            
            return BodyFields(size: size, encoding: bdEncoding)
        }()
        
        if let bd_id = bd_fields.pointee.bd_id {
            bodyFields.id = String(cString: bd_id)
        }
        
        if let body_param = bd_fields.pointee.bd_parameter {
            let params = self.parse(mailimap_body_fld_param: body_param)
            bodyFields.charset = params["CHARSET"]
            bodyFields.name    = params["NAME"]
        }
        
        if let bd_description = bd_fields.pointee.bd_description {
            bodyFields.desc = String(cString: bd_description)
        }
        return bodyFields
    }
    
    static private func parse(mailimap_body_fld_param param: UnsafeMutablePointer<mailimap_body_fld_param>) -> Dictionary<String, String> {
        /*
         struct mailimap_body_fld_param {
         clist * pa_list; /* list of (struct mailimap_single_body_fld_param *) */
         /* != NULL */
         };
         */
        var params: [String: String] = [:]
        for param in sequence(param.pointee.pa_list, of: mailimap_single_body_fld_param.self) {
            let key = String(cString: param.pointee.pa_name)
            let value = String(cString: param.pointee.pa_value)
            params[key] = value
        }
        return params
    }
    
    static private func parse(mailimap_body_fld_dsp dsp: UnsafeMutablePointer<mailimap_body_fld_dsp>) -> Disposition {
        /*
         struct mailimap_body_fld_dsp {
         char * dsp_type;                     /* != NULL */
         struct mailimap_body_fld_param * dsp_attributes; /* can be NULL */
         };
         */
        let dspType = String(cString: dsp.pointee.dsp_type)
        switch dspType {
        case "INLINE":
            return .inline
        case "ATTACHMENT":
            return .attachment
        default:
            return .unknown
        }
    }
    
    static private func parse(mailimap_body_fld_enc enc: UnsafeMutablePointer<mailimap_body_fld_enc>) -> TransferEncoding {
        /*
         struct mailimap_body_fld_enc {
         int enc_type;
         char * enc_value; /* can be NULL */
         };
         */
        switch Int(enc.pointee.enc_type) {
        case MAILIMAP_BODY_FLD_ENC_7BIT:
            return .sevenBit
        case MAILIMAP_BODY_FLD_ENC_8BIT:
            return .eightBit
        case MAILIMAP_BODY_FLD_ENC_BINARY:
            return .binary
        case MAILIMAP_BODY_FLD_ENC_BASE64:
            return .base64
        case MAILIMAP_BODY_FLD_ENC_QUOTED_PRINTABLE:
            return .quoted
        case MAILIMAP_BODY_FLD_ENC_OTHER: fallthrough
        default:
            return .other
        }
    }
    
    static private func parse(mailimap_envelope envelope: UnsafeMutablePointer<mailimap_envelope>) -> MessageHeader {
        /*
         struct mailimap_envelope {
         char * env_date;                             /* can be NULL */
         char * env_subject;                          /* can be NULL */
         struct mailimap_env_from * env_from;         /* can be NULL */
         struct mailimap_env_sender * env_sender;     /* can be NULL */
         struct mailimap_env_reply_to * env_reply_to; /* can be NULL */
         struct mailimap_env_to * env_to;             /* can be NULL */
         struct mailimap_env_cc * env_cc;             /* can be NULL */
         struct mailimap_env_bcc * env_bcc;           /* can be NULL */
         char * env_in_reply_to;                      /* can be NULL */
         char * env_message_id;                       /* can be NULL */
         };
         */
        
        var messageHeader = MessageHeader()
        
        if let env_message_id = envelope.pointee.env_message_id {
            messageHeader.messageId = String(cString: env_message_id)
        }
        
        if let env_date = envelope.pointee.env_date {
            print("env_date", String(cString: env_date))
        }
        
        if let env_subject = envelope.pointee.env_subject {
            messageHeader.subject = String(cString: env_subject)
        }
        
        if let env_from = envelope.pointee.env_from {
            messageHeader.from = parse(mailimap_address_list: env_from.pointee.frm_list)
            
        }
        
        if let env_sender = envelope.pointee.env_sender {
            messageHeader.sender = parse(mailimap_address_list: env_sender.pointee.snd_list).first
        }
        
        if let reply_to = envelope.pointee.env_reply_to {
            messageHeader.to = parse(mailimap_address_list: reply_to.pointee.rt_list).map {
                return .mailBox($0)
            }
        }
        
        if let env_to = envelope.pointee.env_to {
            messageHeader.to = parse(mailimap_address_list: env_to.pointee.to_list).map {
                return .mailBox($0)
            }
        }
        
        if let env_cc = envelope.pointee.env_cc {
            messageHeader.cc = parse(mailimap_address_list: env_cc.pointee.cc_list).map {
                return .mailBox($0)
            }
        }
        
        if let env_bcc = envelope.pointee.env_bcc {
            messageHeader.bcc = parse(mailimap_address_list: env_bcc.pointee.bcc_list).map {
                return .mailBox($0)
            }
        }
        
        if let env_in_reply_to = envelope.pointee.env_in_reply_to {
            messageHeader.inReplyTo = [String(cString: env_in_reply_to)]
        }
        return messageHeader
    }
    
    static private func parse(mailimap_address_list list: UnsafeMutablePointer<clist>) -> [AddressMailBox] {
        var result: [AddressMailBox] = []
        for imap_address in sequence(list, of: mailimap_address.self) {
            guard let address = self.parse(mailimap_address: imap_address) else {
                continue
            }
            
            result.append(address)
        }
        return result
    }
    
    static private func parse(mailimap_address address: UnsafeMutablePointer<mailimap_address>) -> AddressMailBox? {
        /*
         struct mailimap_address {
         char * ad_personal_name; /* can be NULL */
         char * ad_source_route;  /* can be NULL */
         char * ad_mailbox_name;  /* can be NULL */
         char * ad_host_name;     /* can be NULL */
         };
         */
        
        guard let email: String = {
            let host = address.pointee.ad_host_name
            let mailBox = address.pointee.ad_mailbox_name
            switch (host, mailBox) {
            case let (host?, mailBox?):
                return "\(String(cString: mailBox))@\(String(cString: host))"
            case let (host?, nil):
                return "@\(String(cString: host))"
            case let (nil, mailBox?):
                return String(cString: mailBox)
            default:
                return nil
            }
            }() else { return nil }
        
        var displayName: String?
        if let personal_name = address.pointee.ad_personal_name {
            displayName = String(cString: personal_name)
        }
        
        return AddressMailBox(email: email, displayName: displayName)
    }
}
