//
//  File.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2017/12/27.
//

import Foundation
import libetpan

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
