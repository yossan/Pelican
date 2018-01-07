//
//  MailPart.swift
//  Pelican
//
//  Created by yoshi-kou on 2017/12/29.
//

import Foundation

public indirect enum MailPart: CustomStringConvertible {
    case multiPart (id: String?, type: MultipartType, parts: [MailPart], boundary: String?)
    case singlePart(id: String, data: ContentData)
    
    public var description: String {
        switch self {
        case let .multiPart(id, type, parts, boundary):
            let id = id ?? "0"
            let boundary = boundary ?? ""
            return "multiPart(id = \(id), type = \(type), parts = \(parts), boundary = \(boundary))"
        case let .singlePart(id, data):
            return "singlePart(id = \(id), data = \(data))"
        }
    }
}

public enum MultipartType {
//    case mixed
    case alternative
    case related
    case notSupported
}

public enum ContentData: CustomStringConvertible {
    case basic (type: MediaType, disposition: Disposition, fields: BodyFields, rawData: Data?)
    case text (type: TextType, fields: BodyFields, rawData: Data?)
    case message (header: MessageHeader, fields: BodyFields, body: MailPart)
    
    public var description: String {
        switch self {
        case let .basic(type, disposition, fields, rawData):
            return ".basic(\(type), \(disposition), \(fields), \(rawData?.count ?? 0))"
        case let .text(type, fields, rawData):
            return ".text(\(type), \(fields), \(rawData?.count ?? 0))"
        case let .message(header, fields, body):
            return ".message(\(header), \(fields), \(body))"
        }
    }
    
}

public struct BodyFields: CustomStringConvertible {
    public let size: UInt32
    public let encoding: TransferEncoding
    public var id: String?
    public var desc: String?
    public var name: String?
    public var charset: String? // String.Encoding にする デフォルトはUS-ASCII
    文字コードを指示するための charset パラメータがあります。上記の例では、charset パラメータで ISO-2022-JP(日本語) であると指定されています。英語なら US-ASCII、ヨーロッパの主要言語なら ISO-8859-1 と記述します。なお、charset パラメータが省略された場合は、US-ASCII として取り扱われます。
    
    init(size: UInt32, encoding: TransferEncoding) {
        self.size = size
        self.encoding = encoding
    }
    
    public var description: String {
        var result: [String: String] = ["size" : "\(size)", "encoding" : "\(encoding)"]
        if let id = id {
            result["id"] = id
        }
        if let desc = desc {
            result["description"] = desc
        }
        if let name = name {
            result["name"] = name
        }
        if let charset = charset {
            result["charset"] = charset
        }
        return result.lazy.reduce(into: []){ (accumurator: inout [String], args) in
            let (key, value) = args
            accumurator.append("\(key) = \(value)")
            }.joined(separator: ", ")
    }
}

public enum TextType: CustomStringConvertible {
    case plain
    case html
    case notSupported

    public var description: String {
        switch self {
        case .plain:
            return "PLAIN"
        case .html:
            return "HTML"
        case .notSupported:
            return "NotSupported"
        }
    }
}

public enum Disposition: CustomStringConvertible {
    case inline
    case attachment
    case unknown
    
    public var description: String {
        switch self {
        case .inline:
            return "INLINE"
        case .attachment:
            return "ATTACHMENT"
        case .unknown:
            return "UNKNOWN"
        }
    }
}

public enum MediaType: CustomStringConvertible {
    case application (subtype: String)
    case audio  (subtype: String)
    case image  (subtype: String)
    case message (subtype: String)
    case video (subtype: String)
    case other (subtype: String)
    
    public var description: String {
        switch self {
        case let .application (subtype: value):
            return "application(\(value))"
        case let .audio  (subtype: value):
            return "audio(\(value))"
        case let .image  (subtype: value):
            return "image(\(value))"
        case let .message (subtype: value):
            return "message(\(value))"
        case let .video (subtype: value):
            return "video(\(value))"
        case let .other (subtype: value):
            return "other(\(value))"
        }
    }
}

public enum TransferEncoding: CustomStringConvertible {
    case sevenBit
    case eightBit
    case binary
    case base64
    case quoted
    case other
    
    public var description: String {
        switch self {
        case .sevenBit: return "sevenBit"
        case .eightBit: return "eightBit"
        case .binary: return "binary"
        case .base64: return "base64"
        case .quoted: return "quoted"
        case .other: return "other"
        }
    }
}
