//
//  ImapSession.swift
//  Pelican
//
//  Created by yoshi-kou on 2017/12/23.
//

import Foundation
import libetpan

/**
 ImapSession is not threadsafe.
 */
public class ImapSession {
    let imap: UnsafeMutablePointer<mailimap>
    public var storedCapability: Capability = []
    
    public init() {
        self.imap = mailimap_new(0, nil)
        mailimap_set_progress_callback(imap, {(_,_,_) in },{(_,_,_) in }, nil)
    }
    
    deinit {
        mailimap_set_progress_callback(imap, nil, nil, nil)
        mailimap_logout(imap)
        mailimap_free(imap)
    }
    
    public func connect(hostName: String, port: UInt16) throws {
        try mailimap_ssl_connect(imap, hostName, port).toImapSessionError().check()
    }
    
    public func login(user: String, accessToken: String) throws {
        try mailimap_oauth2_authenticate(imap, user, accessToken).toImapSessionError().check()
    }
    
    public func capability() throws -> Capability {
        var capabilityData: UnsafeMutablePointer<mailimap_capability_data>? = nil
        
        try mailimap_capability(imap, &capabilityData).toImapSessionError().check()
        defer { mailimap_capability_data_free(capabilityData) }
        
        return Capability(mailimap: imap)
    }
    
    public func namespace() throws -> Namespace? {
        if self.storedCapability.contains(.Namespace) {
            // fetch namespace
            var namespaceData: UnsafeMutablePointer<mailimap_namespace_data>? = nil
            try mailimap_namespace(imap, &namespaceData).toImapSessionError().check()
            defer { mailimap_namespace_data_free(namespaceData) }
            return Namespace(mailimap_namespace_data: namespaceData!)
        }
        return nil
    }
    
    public func list(namespace: NamespaceItem? = nil) throws -> [Folder] {
        let deliminatorCode = namespace?.infoList.first?.deliminator ?? 47 // 47 = backslash
        let deleminatoer = String(UnicodeScalar(UInt8(deliminatorCode)))
        
        var listResult: UnsafeMutablePointer<clist>? = nil
        try mailimap_list(imap, deleminatoer, "*", &listResult).toImapSessionError().check()
        defer { clist_free(listResult) }
        
        return sequence(listResult!, of: mailimap_mailbox_list.self).map { Folder.init(mailimap_mailbox_list: $0) }
    }
    
    private var selectedFolderName: String = ""
    public func select(_ name: String) throws -> SelectionInfo {
        guard self.selectedFolderName != name else {
            return try self.selectedFolder()
        }
        self.selectedFolderName = name
        
        try mailimap_select(imap, name).toImapSessionError().check()
        let selectedFolder = try self.selectedFolder()
        return selectedFolder
    }
    
    public func selectedFolder() throws -> SelectionInfo {
        guard let info = imap.pointee.imap_selection_info else { throw ImapSessionError.SELECTEDFOLDER }
        return SelectionInfo(mailimap_selection_info: info)
    }
    
    public struct FetchOptions: OptionSet {
        public static let messageHeader = FetchOptions(rawValue: 1 << 1)
        public static let bodystructure = FetchOptions(rawValue: 1 << 0)
        
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public func fetch(uids: [UInt32], options: FetchOptions, handler: @escaping (Message)->()) throws {
        let set = mailimap_set_new_empty();
        for uid in uids {
            mailimap_set_add_single(set, uid)
        }
        defer { mailimap_set_free(set) }
        
        try self.fetch(set: set!, options: options, handler: handler)
    }
    
    public func fetchLast(num: UInt32, options: FetchOptions, handler: @escaping (Message)->()) throws {
        
        let messageCount: UInt32 = {
            guard let info = self.imap.pointee.imap_selection_info,
                info.pointee.sel_has_exists == 1 else {
                    return 0
            }
            return UInt32(info.pointee.sel_exists)
        }()
        
        let range: Range<UInt32> = messageCount - num ..< messageCount
        try self.fetch(range: range, options: options, handler: handler)
    }
    
    public func fetch(range: Range<UInt32>, options: FetchOptions, handler: @escaping (Message)->()) throws {
        let set = mailimap_set_new_empty();
        mailimap_set_add_interval(set, range.lowerBound, range.upperBound)
        defer { mailimap_set_free(set) }
        try self.fetch(set: set!, options: options, handler: handler)
    }
    
    func fetch(set: UnsafeMutablePointer<mailimap_set>, options: FetchOptions, handler: @escaping (Message)->()) throws {
        let fetchType = mailimap_fetch_type_new_fetch_att_list_empty()
        defer { mailimap_fetch_type_free(fetchType) }
        
        let uidAtt = mailimap_fetch_att_new_uid();
        mailimap_fetch_type_new_fetch_att_list_add(fetchType, uidAtt)
        
        if options.contains(.messageHeader) {
            let flagsAtt = mailimap_fetch_att_new_flags()
            mailimap_fetch_type_new_fetch_att_list_add(fetchType, flagsAtt)
            
            let headerSection = mailimap_section_new_header()
            let headerAtt = mailimap_fetch_att_new_body_peek_section(headerSection)
            mailimap_fetch_type_new_fetch_att_list_add(fetchType, headerAtt)
        }
        
        if options.contains(.bodystructure) {
            let bodyStructureAtt = mailimap_fetch_att_new_bodystructure()
            mailimap_fetch_type_new_fetch_att_list_add(fetchType, bodyStructureAtt)
        }
        
        try self.imap.fetch(isUID: false, set: set, type: fetchType) { (messageAttribute) in
            guard let messageAttribute = messageAttribute,
                let message = Message(mailimap_msg_att: messageAttribute) else {
                    return
            }
            handler(message)
        }
    }
    
    public func fetchData(uid: UInt32, partId: String, completion: @escaping (Data)->()) throws {
        
        let set = mailimap_set_new_single(uid)
        defer { mailimap_set_free(set) }
        
        var fetchType = mailimap_fetch_type_new_fetch_att_list_empty()
        defer { mailimap_fetch_type_free(fetchType) }
        
        let sectionId = partId.split(separator: ".").map{Int32($0)!}.reduce(into: clist_new()) { (result, partialId) in
            // released when mailimap_fetch_type_free(fetchType) occured
            let partId = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
            partId.pointee = partialId
            clist_append(result, partId)
            } as UnsafeMutablePointer<clist>
        
        let sectionPart = mailimap_section_part_new(sectionId)
        let section = mailimap_section_new_part(sectionPart)
        let bodyPeekSection = mailimap_fetch_att_new_body_peek_section(section)
        mailimap_fetch_type_new_fetch_att_list_add(fetchType, bodyPeekSection)

        try self.imap.fetch(isUID: true, set: set, type: fetchType) { (messageAttribute) in
            messageAttribute?.pointee.parse(handler: { (attribute) in
                guard case let .`static`(mailimap_msg_att_static) = attribute else {
                    return
                }
                mailimap_msg_att_static.pointee.parse(handler: { (attribute) in
                    guard case let .bodySection (mailimap_msg_att_body_section) = attribute else {
                        return
                    }
                    mailimap_msg_att_body_section.pointee.parse(handler: { (bodySection) in
                        guard case let .part (_, message, length) = bodySection else {
                            return
                        }
                        let data = Data(buffer: UnsafeBufferPointer(start: message, count: length))
                        completion(data)
                    })
                })
            })
        }
    }
    
    /*
    func fetchMessages() -> Bool {
        
        mailimap_set_msg_att_handler(imap, { (message, context) in
        }, nil/*contextを渡す*/)
        
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

    }*/
    
    public func search(_ condition: SearchCondition) throws -> [UInt32] {
        let charset = "UTF-8"
        let searchKey = condition.createMAILIMAP_SEACH_KEY()
        defer { mailimap_search_key_free(searchKey) }
        var resultBox: UnsafeMutablePointer<clist>? = nil
        if self.storedCapability.contains(.LiteralPlus) {
            try mailimap_search_literalplus(imap, charset, searchKey, &resultBox).toImapSessionError().check()
        } else {
            try mailimap_uid_search(imap, charset, searchKey, &resultBox).toImapSessionError().check()
        }
        defer { mailimap_search_result_free(resultBox) }
        guard let result = resultBox else {
            throw ImapSessionError.SEARCH
        }
        
        return result.array()
    }
}
