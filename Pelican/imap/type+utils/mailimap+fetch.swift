//
//  mailimap+fetch.swift
//  Pelican
//
//  Created by yoshi-kou on 2018/01/06.
//

import Foundation
import libetpan

extension UnsafeMutablePointer where Pointee == mailimap {
    
    typealias FetchCompletion = (UnsafeMutablePointer<mailimap_msg_att>?)->()
    struct FetchContext {
        let handler: FetchCompletion
    }
    
    func fetch(set: UnsafeMutablePointer<mailimap_set>?, type fetchType: UnsafeMutablePointer<mailimap_fetch_type>?, callBackHandler: @escaping FetchCompletion) -> ImapSessionError {
        
        var fetchContext = FetchContext(handler: callBackHandler)
        mailimap_set_msg_att_handler(self, { (mailimap_msg_att, rawContext) in
            let fetchContext = rawContext!.bindMemory(to: FetchContext.self, capacity: 1)
            fetchContext.pointee.handler(mailimap_msg_att)
        }, &fetchContext)
        
        defer { mailimap_set_msg_att_handler(self, nil, nil) }
        
        var fetchResult: UnsafeMutablePointer<clist>? = clist_new()
        let r = mailimap_fetch(self, set, fetchType, &fetchResult)
        defer { mailimap_fetch_list_free(fetchResult) } // rで成功したかどうかで・・
        return ImapSessionError(r)
    }
}
