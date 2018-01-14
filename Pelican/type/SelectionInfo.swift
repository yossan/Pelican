//
//  SelectionInfo.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/14.
//

import Foundation
import libetpan

public struct SelectionInfo {
    let uidNext: UInt32
    let uidValidity: UInt32
    let firstUnseen: UInt32
    let exists: UInt32?
    let recent: UInt32?
    let unseen: UInt32
//    let allowflags: Bool
    
    init(mailimap_selection_info info: UnsafeMutablePointer<mailimap_selection_info>) {
        self.uidNext = info.pointee.sel_uidnext
        self.uidValidity = info.pointee.sel_uidvalidity
        self.firstUnseen = info.pointee.sel_first_unseen
        self.unseen = info.pointee.sel_first_unseen
        
        if info.pointee.sel_has_exists == 1 {
            self.exists = info.pointee.sel_exists
        } else {
            self.exists = nil
        }
        
        if info.pointee.sel_has_recent == 1 {
            self.recent = info.pointee.sel_recent
        } else {
            self.recent = nil
        }
    }
}
