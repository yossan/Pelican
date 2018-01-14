//
//  Namespace.swift
//  Pelican
//
//  Created by yoshi-kou on 2018/01/14.
//

import Foundation

public struct Namespace {
    public let personal: NamespaceItem?
    public let other: NamespaceItem?
    public let shared: NamespaceItem?
}

public struct NamespaceItem {
    public let infoList: [NamespaceInfo]
}

public struct NamespaceInfo {
    public let deliminator: Int8
    public let prifix: String
    public let extensions: [NamespaceExtension]?
}

public struct NamespaceExtension {
    public let name: String
    public let values: [String]
}
