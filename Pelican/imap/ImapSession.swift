//
//  ImapSession.swift
//  Pelican
//
//  Created by yoshi-kou on 2017/12/23.
//

import Foundation
import libetpan

public class ImapSession {
    public static let shared: ImapSession = ImapSession()
    
    let imap: UnsafeMutablePointer<mailimap>
    init() {
        self.imap = mailimap_new(0, nil)
    }
    
    public func connect(hostName: String, port: UInt16) -> ImapSessionError {
        let r = mailimap_ssl_connect(imap, hostName, port)
        return ImapSessionError(r)
    }
    
    public func login(user: String, accessToken: String) -> ImapSessionError {
        let r = mailimap_oauth2_authenticate(imap, user, accessToken)
        return ImapSessionError(r)
    }
    
    public func list(withResult result: inout [String]) -> ImapSessionError {
        
        return .Unknown
    }
    
    public func fetchFolders() -> [String]? {
    
    
        // Optional<UnsafeMutablePointer<clist_s>>
        var folderList = clist_new()
        defer { clist_free(folderList) }
    
        guard mailimap_list(imap, "/", "*", &folderList) == 0 else {
            print("fetching folders failed")
            return nil
        }
        
        var results: [String] = []
        for folder in sequence(folderList!, of: mailimap_mailbox_list.self) {
            let name = String(cString: UnsafePointer<Int8>(folder.pointee.mb_name))
          
            results.append(name)
            
//            let delimiter: String = String(cString: &folder.pointee.mb_delimiter)
//            print("delimiter", delimiter)
//
//            let type = folder.pointee.mb_flag.pointee.mbf_type
//            print("folder.type", type)
//            let flags = folder.pointee.mb_flag.pointee.mbf_oflags
//
//            for flag in sequence(flags!, of: mailimap_mbx_list_oflag.self) {
//                print("of_flag_ext", String(cString: UnsafePointer<Int8>(flag.pointee.of_flag_ext)))
//
//                print("of_type",flag.pointee.of_type)
//            }
        }
        
        return results.isEmpty == false ? results : nil
    }
    
    public func selectFolder(_ folder: String) -> Bool {
        return mailimap_select(imap, folder) == 0 ? true : false
    }
    
    struct FetchOptions: OptionSet {
        static let headers       = FetchOptions(rawValue: 1 << 1)
        static let bodystructure = FetchOptions(rawValue: 1 << 0)
        
        let rawValue: Int
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    /**
     options
     Body.headers
     Body.headers(.subject, .othrer(""))
     
     */
    public func fetch() {
        
    }
    
    public func fetchMessages() -> Bool {
//        mailimap_set_progress_callback(imap, {(_,_,_) in },{(_,_,_) in }, nil)
//        mailimap_set_msg_att_handler(imap, { (message, _) in
//            print("こいこい")
//        }, nil/*contextを渡す*/)
        
        // 結果を格納
        var fetch_result = clist_new()
       
        
        // コンフィグレーション
//        let set = mailimap_set_new_interval(1, 0); /* fetch in interval 1:* */
        let set = mailimap_set_new_empty()
        mailimap_set_add_interval(set, 4, 4)
        
//        var fetch_type = mailimap_fetch_type_new_all()
        var fetch_type = mailimap_fetch_type_new_fetch_att_list_empty()
//        print("ft_type", fetch_type?.pointee.ft_type)
//        print(String(describing: fetch_type?.pointee.ft_data.ft_fetch_att))
//        print(String(describing: fetch_type?.pointee.ft_data.ft_fetch_att_list))
        
        let uid_att = mailimap_fetch_att_new_uid();
        mailimap_fetch_type_new_fetch_att_list_add(fetch_type, uid_att)
        
//        let flags_att = mailimap_fetch_att_new_flags()
//        mailimap_fetch_type_new_fetch_att_list_add(fetch_type, flags_att)

//        let envelope_att = mailimap_fetch_att_new_envelope()
//        mailimap_fetch_type_new_fetch_att_list_add(fetch_type, envelope_att)
        
//        let header_att = mailimap_fetch_att_new_rfc822_header()
//        mailimap_fetch_type_new_fetch_att_list_add(fetch_type, header_att)
        
//        let header_text_att = mailimap_fetch_att_new_rfc822_text()
//        mailimap_fetch_type_new_fetch_att_list_add(fetch_type, header_text_att)
        
        // BodyStructure
//        let body_structure_att = mailimap_fetch_att_new_bodystructure()
//        mailimap_fetch_type_new_fetch_att_list_add(fetch_type, body_structure_att)
        
        
        // peekだと既読にならない？
        // MIME
        // body + text
//        let bodySection = mailimap_section_new(nil)
//        let bodyAttr = mailimap_fetch_att_new_body_section(headerSection)
//         mailimap_fetch_type_new_fetch_att_list_add(fetch_type, bodyAttr)
        // header
        let headerSection = mailimap_section_new_header()
        let headerAttr = mailimap_fetch_att_new_body_peek_section(headerSection)
////        let headerAttr = mailimap_fetch_att_new_body_section(headerSection)
       mailimap_fetch_type_new_fetch_att_list_add(fetch_type, headerAttr)
        // text (contentヘッダーつき)
//        let textSection = mailimap_section_new_text()
//        let textAttr = mailimap_fetch_att_new_body_peek_section(textSection)
//        mailimap_fetch_type_new_fetch_att_list_add(fetch_type, textAttr)
        
        // partの中身のみを取りたい場合は、part_idを指定する
        // section part
//        let list = clist_new()
//        var part1 = 1
//        clist_append(list, &part1)
//        var part2 = 2
//        clist_append(list, &part2)
//
//        let sectionPart = mailimap_section_part_new(list)
//        let section = mailimap_section_new_part(sectionPart)
//        let bodyPeekSection = mailimap_fetch_att_new_body_peek_section(section)
//        fetch_type = mailimap_fetch_type_new_fetch_att(bodyPeekSection)
        
        
        // Body //BODYSTRUCTUREに類似。Content-MD5、Content-Disposition、Content-Language（拡張フィールド）を除いた表示を行う
//        let body_att = mailimap_fetch_att_new_body()
//        mailimap_fetch_type_new_fetch_att_list_add(fetch_type, body_att)
        
        // メッセージの取得
//        let r = mailimap_fetch(imap, set, fetch_type, &fetch_result)
        let r = mailimap_uid_fetch(imap, set, fetch_type, &fetch_result)
        for message in sequence(fetch_result!, of: mailimap_msg_att.self) {
            for messageAtt in sequence(message.pointee.att_list, of: mailimap_msg_att_item.self) {
                let attType = messageAtt.pointee.att_type
                
                switch Int(attType) {
                case MAILIMAP_MSG_ATT_ITEM_DYNAMIC:
                    print("MAILIMAP_MSG_ATT_ITEM_DYNAMIC")
                    let dynamicItem = messageAtt.pointee.att_data.att_dyn!
                    Pelican.print2(mailimap_msg_att_dynamic: dynamicItem)
                case MAILIMAP_MSG_ATT_ITEM_STATIC:
                    print("MAILIMAP_MSG_ATT_ITEM_STATIC")
                    let staticItem = messageAtt.pointee.att_data.att_static!
                    Pelican.print2(mailimap_msg_att_static: staticItem)
                    
                default: break
                }
            }
        }
        
        return r == 0 ? true : false

    }
}
