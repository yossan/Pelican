//
//  ImapSession.swift
//  Pelican iOS
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
    
    public func connect(hostName: String, port: UInt16) -> ImapSession.Result {
        let r = mailimap_ssl_connect(imap, hostName, port)
        return Result(r)
    }
    
    public func login(user: String, accessToken: String) -> ImapSession.Result {
        let r = mailimap_oauth2_authenticate(imap, user, accessToken)
        return Result(r)
    }
    
    public func fetchFolders() -> [String]? {
    
        // Optional<UnsafeMutablePointer<clist_s>>
        var folderList = clist_new()
        defer { clist_free(folderList) }
    
        let r = mailimap_list(imap, "/", "*", &folderList)
        print("r", r)
        
        var results: [String] = []
        for folder in sequence(folderList!, of: mailimap_mailbox_list.self) {
            let name = String(cString: UnsafePointer<Int8>(folder.pointee.mb_name))
            print("name", name)
            results.append(name)
            
            let type = folder.pointee.mb_flag.pointee.mbf_type
            print("folder.type", type)
            let flags = folder.pointee.mb_flag.pointee.mbf_oflags
            
            for flag in sequence(flags!, of: mailimap_mbx_list_oflag.self) {
                print("of_flag_ext", String(cString: UnsafePointer<Int8>(flag.pointee.of_flag_ext)))
                
                print("of_type",flag.pointee.of_type)
            }
        }
        
        return results.isEmpty == false ? results : nil
    }
}



