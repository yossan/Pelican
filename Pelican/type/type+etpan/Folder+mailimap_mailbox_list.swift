//
//  Folder+mailimap_mailbox_list.swift
//  Pelican
//
//  Created by yoshi-kou on 2018/01/14.
//

import Foundation
import libetpan

extension Folder {
    init(mailimap_mailbox_list list: UnsafeMutablePointer<mailimap_mailbox_list>) {
        /*
         struct mailimap_mailbox_list {
         struct mailimap_mbx_list_flags * mb_flag; /* can be NULL */
         char mb_delimiter;
         char * mb_name; /* != NULL */
         };
         */
        self.name = list.pointee.mb_name.string
        self.delimiter = list.pointee.mb_delimiter
    }
}
