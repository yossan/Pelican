//
//  Namespace+mailimap_namespace_data.swift
//  Pelican
//
//  Created by yoshi-kou on 2018/01/14.
//

import Foundation
import libetpan

extension Namespace {
    init(mailimap_namespace_data data: UnsafeMutablePointer<mailimap_namespace_data>) {
        /*
         struct mailimap_namespace_data {
         struct mailimap_namespace_item * ns_personal; /* can be NULL */
         struct mailimap_namespace_item * ns_other; /* can be NULL */
         struct mailimap_namespace_item * ns_shared; /* can be NULL */
         };
         */
        if let ns_personal = data.pointee.ns_personal {
            self.personal = NamespaceItem(mailimap_namespace_item: ns_personal)
        } else {
            self.personal = nil
        }
        
        if let ns_other = data.pointee.ns_other {
            self.other = NamespaceItem(mailimap_namespace_item: ns_other)
        } else {
            self.other = nil
        }
        
        if let ns_shared = data.pointee.ns_shared {
            self.shared = NamespaceItem(mailimap_namespace_item: ns_shared)
        } else {
            self.shared = nil
        }
    }
}

extension NamespaceItem {
    init(mailimap_namespace_item item: UnsafeMutablePointer<mailimap_namespace_item>) {
        /*
         struct mailimap_namespace_item {
         clist * ns_data_list; /* != NULL, list of mailimap_namespace_info */
         };
         */
        self.infoList =  sequence(item.pointee.ns_data_list, of: mailimap_namespace_info.self).map { NamespaceInfo.init(mailimap_namespace_info: $0) }
    }
}

extension NamespaceInfo {
    init(mailimap_namespace_info info: UnsafeMutablePointer<mailimap_namespace_info>) {
        /*
         struct mailimap_namespace_info {
         char * ns_prefix; /* != NULL */
         char ns_delimiter;
         clist * ns_extensions; /* can be NULL, list of mailimap_namespace_response_extension */
         };
         */
        self.prifix = info.pointee.ns_prefix.string
        self.deliminator = info.pointee.ns_delimiter
        if let extensions = info.pointee.ns_extensions {
            self.extensions = sequence(extensions, of: mailimap_namespace_response_extension.self).map { NamespaceExtension.init(mailimap_namespace_response_extension: $0) }
        } else {
            self.extensions = nil
        }
    }
}

extension NamespaceExtension {
    init(mailimap_namespace_response_extension ext: UnsafeMutablePointer<mailimap_namespace_response_extension>) {
        /*
         struct mailimap_namespace_response_extension {
         char * ns_name; /* != NULL */
         clist * ns_values; /* != NULL, list of char * */
         };
         */
        self.name = ext.pointee.ns_name.string
        self.values = sequence(ext.pointee.ns_values, of: Int8.self).map { $0.string }
    }
}




