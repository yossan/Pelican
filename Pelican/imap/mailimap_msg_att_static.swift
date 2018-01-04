//
//  mailimap_msg_att_static.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2017/12/27.
//

import Foundation
import libetpan

func print2(mailimap_msg_att_static staticItem: UnsafeMutablePointer<mailimap_msg_att_static>) {
    /*
     struct mailimap_msg_att_static {
     int att_type;
     union {
     struct mailimap_envelope * att_env;            /* can be NULL */
     struct mailimap_date_time * att_internal_date; /* can be NULL */
     struct {
     char * att_content; /* can be NULL */
     size_t att_length;
     } att_rfc822;
     struct {
     char * att_content; /* can be NULL */
     size_t att_length;
     } att_rfc822_header;
     struct {
     char * att_content; /* can be NULL */
     size_t att_length;
     } att_rfc822_text;
     uint32_t att_rfc822_size;
     struct mailimap_body * att_bodystructure; /* can be NULL */
     struct mailimap_body * att_body;          /* can be NULL */
     struct mailimap_msg_att_body_section * att_body_section; /* can be NULL */
     uint32_t att_uid;
     } att_data;
     };
     */
    switch Int(staticItem.pointee.att_type) {
    case MAILIMAP_MSG_ATT_ERROR: break
    case MAILIMAP_MSG_ATT_ENVELOPE:
        let envelope = staticItem.pointee.att_data.att_env!
        print2(mailimap_envelope: envelope)
    case MAILIMAP_MSG_ATT_INTERNALDATE: break
    case MAILIMAP_MSG_ATT_RFC822: break
    case MAILIMAP_MSG_ATT_RFC822_HEADER:
        print("rfc822_header", String(cString: staticItem.pointee.att_data.att_rfc822_header.att_content))
    case MAILIMAP_MSG_ATT_RFC822_TEXT:
        let text = staticItem.pointee.att_data.att_rfc822
        print2(att_rfc822_text: text)
    case MAILIMAP_MSG_ATT_RFC822_SIZE:
        print("rfc822_size", staticItem.pointee.att_data.att_rfc822_size)
    case MAILIMAP_MSG_ATT_BODY: //Mail Partの構築が出来る
        print("MAILIMAP_MSG_ATT_BODY")
        let body = staticItem.pointee.att_data.att_body!
        print2(mailimap_body: body)
    case MAILIMAP_MSG_ATT_BODYSTRUCTURE: //Mail Partの構築が出来る extパートを含む
        print("MAILIMAP_MSG_ATT_BODYSTRUCTURE")
        let bodyStructure = staticItem.pointee.att_data.att_bodystructure!
        print2(mailimap_body: bodyStructure)
    case MAILIMAP_MSG_ATT_BODY_SECTION: //MIMEの構築が出来る (header and body)
        print("MAILIMAP_MSG_ATT_BODY_SECTION")
        let bodySection = staticItem.pointee.att_data.att_body_section!
        print2(mailimap_msg_att_body_section: bodySection)
        parseHeader(mailimap_msg_att_body_section: bodySection)
//        parseBody(mailimap_msg_att_body_section: bodySection)
    case MAILIMAP_MSG_ATT_UID:
        print("MAILIMAP_MSG_ATT_UID")
        let uid = staticItem.pointee.att_data.att_uid
        print("uid", uid)
    default: break
    }
}

func print2(mailimap_envelope envelope: UnsafeMutablePointer<mailimap_envelope>) {
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
    print("mailimap_envelope:")
    
    if let env_message_id = envelope.pointee.env_message_id {
        print("env_message_id", String(cString: env_message_id))
    }
    if let env_date = envelope.pointee.env_date {
        print("env_date", String(cString: env_date))
    }
    if let env_subject = envelope.pointee.env_subject {
        print("env_subject", String(cString: env_subject))
    }
    if let env_from = envelope.pointee.env_from {
        print("env_from:")
        print2(mailimap_address: env_from.pointee.frm_list)
    }
    
    if let env_sender = envelope.pointee.env_sender {
        print("env_sender:")
        print2(mailimap_address: env_sender.pointee.snd_list)
    }
    
    if let reply_to = envelope.pointee.env_reply_to {
        print("env_reply_to:")
        print2(mailimap_address: reply_to.pointee.rt_list)
    }
    
    if let env_to = envelope.pointee.env_to {
        print("env_to:")
        print2(mailimap_address: env_to.pointee.to_list)
    }
    
    if let env_cc = envelope.pointee.env_cc {
        print("env_cc:")
        print2(mailimap_address: env_cc.pointee.cc_list)
    }
    
    if let env_bcc = envelope.pointee.env_bcc {
        print("env_bcc:")
        print2(mailimap_address: env_bcc.pointee.bcc_list)
    }
    
    if let env_in_reply_to = envelope.pointee.env_in_reply_to {
        print("env_in_reply_to", String(cString: env_in_reply_to))
    }
}
// 本文
func print2(att_rfc822_text text: mailimap_msg_att_static.__Unnamed_union_att_data.__Unnamed_struct_att_rfc822) {
    /*
     struct {
     char * att_content; /* can be NULL */
     size_t att_length;
     } att_rfc822_text;
     */
    print("att_rfc822_text:")
    print("att_length", text.att_length)
    if let text = text.att_content {
        print("att_content", String(cString: text))
    }
}

func print2(mailimap_body body: UnsafeMutablePointer<mailimap_body>) {
    /*
     int bd_type;
     /* can be MAILIMAP_BODY_1PART or MAILIMAP_BODY_MPART */
     union {
     struct mailimap_body_type_1part * bd_body_1part; /* can be NULL */
     struct mailimap_body_type_mpart * bd_body_mpart; /* can be NULL */
     } bd_data;
     */
    print("mailimap_body:")
    switch Int(body.pointee.bd_type) { //Content-Typeのmainパート
    case MAILIMAP_BODY_MPART: // multipart/*
        print("bd_type", "MAILIMAP_BODY_MPART")
        let mpart = body.pointee.bd_data.bd_body_mpart!
        print2(mailimap_body_type_mpart: mpart)
    case MAILIMAP_BODY_1PART: // multipart以外
        print("bd_type", "MAILIMAP_BODY_1PART")
        print2(mailimap_body_type_1part: body.pointee.bd_data.bd_body_1part)
    default:
        break
    }
}

func print2(mailimap_body_type_1part pbody1part: UnsafeMutablePointer<mailimap_body_type_1part>) {
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
    print("mailimap_body_type_1part:")
    let body1part = pbody1part.pointee
    
    switch Int(body1part.bd_type) { //Content-Type:
    case MAILIMAP_BODY_TYPE_1PART_BASIC: // image/png
        print("MAILIMAP_BODY_TYPE_1PART_BASIC")
        let body = body1part.bd_data.bd_type_basic!
        print2(mailimap_body_type_basic: body)
        
    case MAILIMAP_BODY_TYPE_1PART_TEXT: // text/plain, text/html
        print("MAILIMAP_BODY_TYPE_1PART_TEXT")
        let text =  body1part.bd_data.bd_type_text!
        print2(mailimap_body_type_text: text)
    case MAILIMAP_BODY_TYPE_1PART_MSG: // message/* https://msdn.microsoft.com/en-us/library/ms526229(v=exchg.10).aspx
        print("MAILIMAP_BODY_TYPE_1PART_MSG")
        let msg = body1part.bd_data.bd_type_msg!
        print2(mailimap_body_type_msg: msg)
    default:
        print("default")
        break
    }
    
    if let bd_ext_1part = body1part.bd_ext_1part {
        print("<bd_ext_1part>")
        print2(mailimap_body_ext_1part: bd_ext_1part)
    }
}

func print2(mailimap_body_ext_1part ext: UnsafeMutablePointer<mailimap_body_ext_1part>) {
    /*
     struct mailimap_body_ext_1part {
     char * bd_md5;   /* can be NULL */
     struct mailimap_body_fld_dsp * bd_disposition; /* can be NULL */
     struct mailimap_body_fld_lang * bd_language;   /* can be NULL */
     char * bd_loc; /* can be NULL */
     
     clist * bd_extension_list; /* list of (struct mailimap_body_extension *) */
     /* can be NULL */
     };
     */
    print("mailimap_body_ext_1part:")
    if let bd_md5 = ext.pointee.bd_md5 {
        print("bd_md5", String(cString: bd_md5))
    }
    
    if let dsp = ext.pointee.bd_disposition {
        print2(mailimap_body_fld_dsp: dsp)
    }
    
    if let bd_loc = ext.pointee.bd_loc {
        print("bd_loc", bd_loc)
    }
    
    if let lang = ext.pointee.bd_language {
        print2(mailimap_body_fld_lang: lang)
    }
    
    if let ext_list = ext.pointee.bd_extension_list {
        for e in sequence(ext_list, of: mailimap_body_extension.self) {
            print2(mailimap_body_extension: e)
        }
    }
}

func print2(mailimap_body_type_mpart mpart: UnsafeMutablePointer<mailimap_body_type_mpart>) {
    /*
     struct mailimap_body_type_mpart {
     clist * bd_list; /* list of (struct mailimap_body *) */
     /* != NULL */
     char * bd_media_subtype; /* != NULL */
     struct mailimap_body_ext_mpart * bd_ext_mpart; /* can be NULL */
     };
     */
    print("mailimap_body_type_mpart:", "count = \(mpart.pointee.bd_list.pointee.count)")
    print("bd_media_subtype", String(cString: mpart.pointee.bd_media_subtype))
    
    for body in sequence(mpart.pointee.bd_list, of: mailimap_body.self) {
        print2(mailimap_body: body)
    }
    
    if let ext = mpart.pointee.bd_ext_mpart {
        print2(mailimap_body_ext_mpart: ext)
    }
}

func print2(mailimap_body_ext_mpart ext_mpart: UnsafeMutablePointer<mailimap_body_ext_mpart>) {
    /*
     struct mailimap_body_ext_mpart {
     struct mailimap_body_fld_param * bd_parameter; /* can be NULL */
     struct mailimap_body_fld_dsp * bd_disposition; /* can be NULL */
     struct mailimap_body_fld_lang * bd_language;   /* can be NULL */
     char * bd_loc; /* can be NULL */
     clist * bd_extension_list; /* list of (struct mailimap_body_extension *) */
     /* can be NULL */
     };
     */
    print("mailimap_body_ext_mpart:")
    if let bd_loc = ext_mpart.pointee.bd_loc {
        print("bd_loc", String(cString: bd_loc))
    }
    
    if let bd_parameter = ext_mpart.pointee.bd_parameter {
        print2(mailimap_body_fld_param: bd_parameter)
    }
    if let bd_disposition = ext_mpart.pointee.bd_disposition {
        print2(mailimap_body_fld_dsp: bd_disposition)
    }
    
    if let bd_lang = ext_mpart.pointee.bd_language {
        print2(mailimap_body_fld_lang: bd_lang)
    }
    
    if let bd_ext_list = ext_mpart.pointee.bd_extension_list {
        for ext in sequence(bd_ext_list, of: mailimap_body_extension.self) {
            print2(mailimap_body_extension: ext)
        }
    }
}

func print2(mailimap_body_extension ext: UnsafeMutablePointer<mailimap_body_extension>) {
    /*
     struct mailimap_body_extension {
     int ext_type;
     /*
     can be MAILIMAP_BODY_EXTENSION_NSTRING, MAILIMAP_BODY_EXTENSION_NUMBER
     or MAILIMAP_BODY_EXTENSION_LIST
     */
     union {
     char * ext_nstring;    /* can be NULL */
     uint32_t ext_number;
     clist * ext_body_extension_list;
     /* list of (struct mailimap_body_extension *) */
     /* can be NULL */
     } ext_data;
     };
     */
    print("mailimap_body_extension")
    switch Int(ext.pointee.ext_type) {
    case MAILIMAP_BODY_EXTENSION_NSTRING:
        print("ext_type", "MAILIMAP_BODY_EXTENSION_NSTRING")
        print("ext_nstring", String(cString: ext.pointee.ext_data.ext_nstring!))
    case MAILIMAP_BODY_EXTENSION_NUMBER:
        print("ext_type", "MAILIMAP_BODY_EXTENSION_NUMBER")
        print("ext_number", ext.pointee.ext_data.ext_number)
    case MAILIMAP_BODY_EXTENSION_LIST:
        print("ext_type", "MAILIMAP_BODY_EXTENSION_LIST")
        for bodyExt in sequence(ext.pointee.ext_data.ext_body_extension_list, of: mailimap_body_extension.self) {
            print2(mailimap_body_extension: bodyExt)
        }
    default: break
    }
}

func print2(mailimap_body_fld_lang lang: UnsafeMutablePointer<mailimap_body_fld_lang>) {
    /*
     struct mailimap_body_fld_lang {
     int lg_type;
     union {
     char * lg_single; /* can be NULL */
     clist * lg_list; /* list of string (char *), can be NULL */
     } lg_data;
     };
     */
    print("mailimap_body_fld_lang:")
    switch Int(lang.pointee.lg_type) {
    case MAILIMAP_BODY_FLD_LANG_SINGLE:
        print("lg_type", "MAILIMAP_BODY_FLD_LANG_SINGLE")
        if let lg_single = lang.pointee.lg_data.lg_single {
            print("lg_single", String(cString: lg_single))
        }
    case MAILIMAP_BODY_FLD_LANG_LIST:
        print("lg_type", "MAILIMAP_BODY_FLD_LANG_LIST")
        for lg in sequence(lang.pointee.lg_data.lg_list, of: Int8.self) {
            print("lg", String(cString: lg))
        }
    case MAILIMAP_BODY_FLD_LANG_ERROR: fallthrough
    default: break
    }
}

func print2(mailimap_body_fld_dsp dsp: UnsafeMutablePointer<mailimap_body_fld_dsp>) {
    /*
     struct mailimap_body_fld_dsp {
     char * dsp_type;                     /* != NULL */
     struct mailimap_body_fld_param * dsp_attributes; /* can be NULL */
     };
     */
    print("mailimap_body_fld_dsp:")
    print("dsp_type", String(cString: dsp.pointee.dsp_type))
    if let attributes = dsp.pointee.dsp_attributes {
        print2(mailimap_body_fld_param: attributes)
    }
}


func print2(mailimap_single_body_fld_param param: UnsafeMutablePointer<mailimap_single_body_fld_param>) {
    /*
     struct mailimap_single_body_fld_param {
     char * pa_name;  /* != NULL */
     char * pa_value; /* != NULL */
     };
     */
    print("mailimap_single_body_fld_param:")
    print("pa_name", String(cString: param.pointee.pa_name))
    print("pa_value", String(cString: param.pointee.pa_value))
}

func print2(mailimap_body_type_basic body: UnsafeMutablePointer<mailimap_body_type_basic>) {
    /*
     struct mailimap_body_type_basic {
     struct mailimap_media_basic * bd_media_basic; /* != NULL */
     struct mailimap_body_fields * bd_fields; /* != NULL */
     };
     */
    
    print("mailimap_body_type_basic:")
    let media_basic = body.pointee.bd_media_basic!
    print2(mailimap_media_basic: media_basic)
    
    let bd_fields = body.pointee.bd_fields!
    print2(bd_fields: bd_fields)
}

func print2(mailimap_body_type_msg msg: UnsafeMutablePointer<mailimap_body_type_msg>) {
    /*
     struct mailimap_body_type_msg {
     struct mailimap_body_fields * bd_fields; /* != NULL */
     struct mailimap_envelope * bd_envelope;       /* != NULL */
     struct mailimap_body * bd_body;               /* != NULL */
     uint32_t bd_lines;
     };
     */
    print("mailimap_body_type_msg:")
    
    print("bd_lines", msg.pointee.bd_lines)
    
    let bd_fields = msg.pointee.bd_fields!
    print2(bd_fields: bd_fields)
    
    let envelope = msg.pointee.bd_envelope!
    print2(mailimap_envelope: envelope)
    
    let body = msg.pointee.bd_body!
    print2(mailimap_body: body)
}

func print2(mailimap_media_basic media: UnsafeMutablePointer<mailimap_media_basic>) {
    /*
     struct mailimap_media_basic {
     int med_type;
     char * med_basic_type; /* can be NULL */
     char * med_subtype;    /* != NULL */
     };
     */
    print("mailimap_media_basic:")
    switch Int(media.pointee.med_type) {
    case MAILIMAP_MEDIA_BASIC_APPLICATION:
        print("med_type","MAILIMAP_MEDIA_BASIC_APPLICATION")
    case MAILIMAP_MEDIA_BASIC_AUDIO:
        print("med_type","MAILIMAP_MEDIA_BASIC_AUDIO")
    case MAILIMAP_MEDIA_BASIC_IMAGE:
        print("med_type","MAILIMAP_MEDIA_BASIC_IMAGE")
    case MAILIMAP_MEDIA_BASIC_MESSAGE:
        print("med_type","MAILIMAP_MEDIA_BASIC_MESSAGE")
    case MAILIMAP_MEDIA_BASIC_VIDEO:
        print("med_type","MAILIMAP_MEDIA_BASIC_VIDEO")
    case MAILIMAP_MEDIA_BASIC_OTHER:
        print("med_type","MAILIMAP_MEDIA_BASIC_OTHER")
    default: break
    }
    
    if let basicType = media.pointee.med_basic_type {
        print("med_basic_type", String(cString: basicType))
    }
    
    print("med_subtype", String(cString: media.pointee.med_subtype))
}

func print2(mailimap_body_type_text text: UnsafeMutablePointer<mailimap_body_type_text>) {
    /*
     struct mailimap_body_type_text {
     char * bd_media_text;                         /* != NULL */
     struct mailimap_body_fields * bd_fields; /* != NULL */
     uint32_t bd_lines;
     };
     */
    print("mailimap_body_type_text:")
    print("bd_lines",  text.pointee.bd_lines)
    print("bd_media_text", String(cString: text.pointee.bd_media_text!)) //PLAIN or HTML
    
    let bd_fields = text.pointee.bd_fields!
    print2(bd_fields: bd_fields)
}

func print2(bd_fields: UnsafeMutablePointer<mailimap_body_fields>) {
    /*
     struct mailimap_body_fields {
     struct mailimap_body_fld_param * bd_parameter; /* can be NULL */
     char * bd_id;                                  /* can be NULL */
     char * bd_description;                         /* can be NULL */
     struct mailimap_body_fld_enc * bd_encoding;    /* != NULL */
     uint32_t bd_size;
     };
     */
    print("bd_fields:")
    
    if let bd_id = bd_fields.pointee.bd_id {
        print("bd_id", String(cString: bd_id))
    }
    
    print("bd_size", bd_fields.pointee.bd_size)
    
    let bd_encoding = bd_fields.pointee.bd_encoding! //Content-Transfer-Encoding
    print2(mailimap_body_fld_enc: bd_encoding)
    
    
    if let body_param = bd_fields.pointee.bd_parameter {
        print("<bd_parameter>")
        print2(mailimap_body_fld_param: body_param)
    }
    
    
    if let bd_description = bd_fields.pointee.bd_description {
        print("<bd_description>")
        print("bd_description", String(cString: bd_description))
    }
}

func print2(mailimap_body_fld_param param: UnsafeMutablePointer<mailimap_body_fld_param>) {
    /*
     struct mailimap_body_fld_param {
     clist * pa_list; /* list of (struct mailimap_single_body_fld_param *) */
     /* != NULL */
     };
     */
    print("mailimap_body_fld_param:")
    for param in sequence(param.pointee.pa_list, of: mailimap_single_body_fld_param.self) {
        print("pa_name", String(cString: param.pointee.pa_name)) //CHARSET utf8,iso-2022-jp
        print("pa_value", String(cString: param.pointee.pa_value))
    }
}

func print2(mailimap_body_fld_enc enc: UnsafeMutablePointer<mailimap_body_fld_enc>) {
    /*
     struct mailimap_body_fld_enc {
     int enc_type;
     char * enc_value; /* can be NULL */
     };
     */
    print("mailimap_body_fld_enc:")
    switch Int(enc.pointee.enc_type) {
    case MAILIMAP_BODY_FLD_ENC_7BIT:
        print("enc_type", "MAILIMAP_BODY_FLD_ENC_7BIT")
    case MAILIMAP_BODY_FLD_ENC_8BIT:
        print("enc_type", "MAILIMAP_BODY_FLD_ENC_8BIT")
    case MAILIMAP_BODY_FLD_ENC_BINARY:
        print("enc_type", "MAILIMAP_BODY_FLD_ENC_BINARY")
    case MAILIMAP_BODY_FLD_ENC_BASE64:
        print("enc_type", "MAILIMAP_BODY_FLD_ENC_BASE64")
    case MAILIMAP_BODY_FLD_ENC_QUOTED_PRINTABLE:
        print("enc_type", "MAILIMAP_BODY_FLD_ENC_QUOTED_PRINTABLE")
    case MAILIMAP_BODY_FLD_ENC_OTHER:
        print("enc_type", "MAILIMAP_BODY_FLD_ENC_OTHER")
    default: break
    }
    
    if let enc_value = enc.pointee.enc_value {
        print("enc_value", String(cString: enc_value))
    }
}


func print2(mailimap_address address: UnsafeMutablePointer<clist>) {
    /*
     struct mailimap_address {
     char * ad_personal_name; /* can be NULL */
     char * ad_source_route;  /* can be NULL */
     char * ad_mailbox_name;  /* can be NULL */
     char * ad_host_name;     /* can be NULL */
     };
     */
    print("mailimap_address")
    for addres in sequence(address, of: mailimap_address.self) {
        print(" host", String(cString: addres.pointee.ad_host_name))
        print(" mailbox name", String(cString:  addres.pointee.ad_mailbox_name))
        if addres.pointee.ad_source_route != nil {
            print(" source route", String(cString: addres.pointee.ad_source_route))
        } else {
            print(" source root is nil")
        }
        
        if addres.pointee.ad_personal_name != nil {
            print(" personal name", String(cString: addres.pointee.ad_personal_name))
        } else {
            print(" personal name is nil")
        }
    }
}


// body section

func print2(mailimap_msg_att_body_section bodySection: UnsafeMutablePointer<mailimap_msg_att_body_section>) {
    /*
     struct mailimap_msg_att_body_section {
     struct mailimap_section * sec_section; /* != NULL */
     uint32_t sec_origin_octet;
     char * sec_body_part; /* can be NULL */
     size_t sec_length;
     };
     */
    print("mailimap_msg_att_body_section:")
    print("sec_length", bodySection.pointee.sec_length)
    print("sec_origin_octet", bodySection.pointee.sec_origin_octet)
    if let sec_spection = bodySection.pointee.sec_section {
        print2(mailimap_section: sec_spection)
    }
    print("sec_body_part", String(cString: bodySection.pointee.sec_body_part)) //body
}

func print2(mailimap_section section: UnsafeMutablePointer<mailimap_section>) {
    /*
     struct mailimap_section {
     struct mailimap_section_spec * sec_spec; /* can be NULL */
     };
     */
    print("mailimap_section: ")
    if let sec_spec = section.pointee.sec_spec {
        switch Int(sec_spec.pointee.sec_type) {
        case MAILIMAP_SECTION_SPEC_SECTION_MSGTEXT:
            print("sec_type", "MAILIMAP_SECTION_SPEC_SECTION_MSGTEXT")
            let sec_msgtext = sec_spec.pointee.sec_data.sec_msgtext!
            print2(mailimap_section_msgtext: sec_msgtext)
        case MAILIMAP_SECTION_SPEC_SECTION_PART:
            print("sec_type", "MAILIMAP_SECTION_SPEC_SECTION_PART")
            let sec_part = sec_spec.pointee.sec_data.sec_part!
            print2(mailimap_section_part: sec_part)
        default: break
        }
    }
}

func print2(mailimap_section_msgtext sec_msgtext: UnsafeMutablePointer<mailimap_section_msgtext>) {
    /*
     struct mailimap_section_msgtext {
     int sec_type;
     struct mailimap_header_list * sec_header_list; /* can be NULL */
     };
     */
    print(" sec_type", sec_msgtext.pointee.sec_type)
    if let headerList = sec_msgtext.pointee.sec_header_list {
        for hdr in sequence(headerList.pointee.hdr_list, of: Int8.self) {
            print("hdr", String(cString: hdr))
        }
    }
}

func print2(mailimap_section_part sec_part: UnsafeMutablePointer<mailimap_section_part>) {
    /*
     struct mailimap_section_part {
     clist * sec_id; /* list of nz-number (uint32_t *) */
     /* != NULL */
     };
     */
    print("mailimap_section_part:")
    for id in sequence(sec_part.pointee.sec_id, of: UInt32.self) {
        print("sec_part.id", id)
    }
}

// MARK: - Flags
public func print2(mailimap_msg_att_dynamic flags: UnsafeMutablePointer<mailimap_msg_att_dynamic>) {
    /*
     struct mailimap_msg_att_dynamic {
     clist * att_list; /* list of (struct mailimap_flag_fetch *) */
     /* can be NULL */
     };
     */
    print("mailimap_msg_att_dynamic")
    for flagFetch in sequence(flags.pointee.att_list, of: mailimap_flag_fetch.self) {
        print2(mailimap_flag_fetch: flagFetch)
    }
}

func print2(mailimap_flag_fetch flagFetch: UnsafeMutablePointer<mailimap_flag_fetch>) {
    /*
     struct mailimap_flag_fetch {
     int fl_type;
     struct mailimap_flag * fl_flag; /* can be NULL */
     };
     */
    print("mailimap_flag_fetch")
    switch Int(flagFetch.pointee.fl_type) {
    case MAILIMAP_FLAG_FETCH_RECENT:
        print("MAILIMAP_FLAG_FETCH_RECENT")
        fallthrough
    case MAILIMAP_FLAG_FETCH_OTHER:
        print("MAILIMAP_FLAG_FETCH_OTHER")
        let flag = flagFetch.pointee.fl_flag!
        print2(mailimap_flag: flag)
    case MAILIMAP_FLAG_FETCH_ERROR: fallthrough
    default: break
    }
}

func print2(mailimap_flag flag: UnsafeMutablePointer<mailimap_flag>) {
    print("mailimap_flag:")
    switch Int(flag.pointee.fl_type) {
    case MAILIMAP_FLAG_FLAGGED:
        print("MAILIMAP_FLAG_ANSWERED")
    case MAILIMAP_FLAG_DELETED:
        print("MAILIMAP_FLAG_DELETED")
    case MAILIMAP_FLAG_SEEN:
        print("MAILIMAP_FLAG_SEEN")
    case MAILIMAP_FLAG_DRAFT:
        print("MAILIMAP_FLAG_DRAFT")
    case MAILIMAP_FLAG_KEYWORD:
        print("")
        if let keyword = flag.pointee.fl_data.fl_keyword {
            print("keyword", keyword)
        }
    case MAILIMAP_FLAG_EXTENSION:
        print("MAILIMAP_FLAG_EXTENSION")
        if let ext = flag.pointee.fl_data.fl_extension {
            print("extension", ext)
        }
    default: break
    }
}


