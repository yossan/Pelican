//
//  MessageFlag+mailimap_msg_att_dynamic.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/06.
//

import Foundation
import libetpan

extension MessageFlag {
    init(mailimap_msg_att_dynamic attribute: UnsafeMutablePointer<mailimap_msg_att_dynamic>) {
        var flags: MessageFlag = .none
        attribute.pointee.parse { (flag) in
            switch flag {
            case .none:
                flags.formUnion(.none)
            case .recent:
                flags.formUnion(.recent)
            case .flagged:
                flags.formUnion(.flagged)
            case .deleted:
                flags.formUnion(.deleted)
            case .seen:
                flags.formUnion(.seen)
            case .draft:
                flags.formUnion(.draft)
            case .keyword (let keyword):
                switch keyword {
                case "$Forwarded": flags.formUnion(.forwarded)
                case "$MDNSent": flags.formUnion(.MDNSent)
                case "$SubmitPending": flags.formUnion(.submitPending)
                case "$Submitted": flags.formUnion(.submitted)
                default: break
                }
            }
        }
        self = flags
    }
}
