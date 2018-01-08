//
//  MailPart+util.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/07.
//

import Foundation
import libetpan

extension MailPart {
    
    public var id: String {
        switch self {
        case let .multiPart(id, _, _, _):
            return id ?? "0"
        case let .singlePart(id, _):
            return id
        }
    }
    
    public var isText: Bool {
        if case let .singlePart(_,data) = self,
            case .text = data {
            return true
        }
        return false
    }
    
    public var isInline: Bool {
        if case let .singlePart(_,data) = self,
            case let .basic(_,disposition,_,_) = data,
            case .inline = disposition {
            return true
        }
        return false
    }
    
    public var hasData: Bool {
        switch self {
        case let .multiPart(_, _, parts, _):
            return parts.first { $0.hasData == false } == nil
        case let .singlePart(_, messageData):
            switch messageData {
            case let .text(_, _, rawData):
                return rawData != nil
            case let .basic(_,_,_,rawData):
                return rawData != nil
            default:
                return false
            }
        }
    }
    
    public var decodedText: String? {
        if case let .singlePart(_, contentData) = self,
            case let .text(_, fields, rawData) = contentData,
            case let .some(data) = rawData {
            switch fields.encoding {
            case .base64:
                /*
                 mailmime_base64_body_parse(const char * message, size_t length,
                 size_t * indx, char ** result,
                 size_t * result_len);
                 */
               
                return data.withUnsafeBytes { (bytes: UnsafePointer<Int8>)->(String?)  in
                    let length = Int(fields.size)
                    var index = 0
                    var result: UnsafeMutablePointer<Int8>? = nil
                    var resultLength = 0
                    
                    let r = mailmime_base64_body_parse(bytes, length, &index, &result, &resultLength).toMIMEError()
                    
                    if r.isSuccess {
                        defer { free(result) }
                        if let result = result {
                            return String(cString: result, encoding: self.stringEncoding(from: fields.charset))
                        }
                    }
                    
                    return nil
                }
                
            case .quoted:
                /*
                 int mailmime_quoted_printable_body_parse(const char * message, size_t length,
                 size_t * indx, char ** result,
                 size_t * result_len, int in_header);
                 */
            return data.withUnsafeBytes { (bytes: UnsafePointer<Int8>)->(String?)  in
                let length = Int(fields.size)
                var index = 0
                var result: UnsafeMutablePointer<Int8>? = nil
                var resultLength = 0
                
                let r = mailmime_quoted_printable_body_parse(bytes, length, &index, &result, &resultLength, 0).toMIMEError()
                
                if r.isSuccess {
                    defer { free(result) }
                    if let result = result {
                        return String(cString: result, encoding: self.stringEncoding(from: fields.charset))
                    }
                }
                
                return nil
                }
                
            case .sevenBit: fallthrough
            case .eightBit: fallthrough
            case .binary:   fallthrough
            case .other:
                return String(data: data, encoding: self.stringEncoding(from: fields.charset))
            }
        }
        return nil
    }
    
    private func stringEncoding(from charset: String?) -> String.Encoding {
        guard let charset = charset else {
            return .ascii
        }
        switch charset.lowercased() {
        case "utf-8": return .utf8
        case "utf-16": return .utf16
        case "utf-16be": return .utf16BigEndian
        case "utf-16le": return .utf16LittleEndian
        case "utf-32": return .utf32
        case "utf-32be": return .utf32BigEndian
        case "utf-32le": return .utf32LittleEndian
        case "iso-2022-jp": return .iso2022JP
        case "euc-jp": return .japaneseEUC
        case "shift_jis": return .shiftJIS
        case "‎windows-1250": return .windowsCP1250
        case "‎windows-1251": return .windowsCP1251
        case "‎windows-1252": return .windowsCP1252
        case "‎windows-1253": return .windowsCP1253
        case "‎windows-1254": return .windowsCP1254
        case "big5":
            let cfEnc = CFStringEncodings.big5
            let nsEnc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
            
            return String.Encoding(rawValue: nsEnc)
        case "GB18030":
            let cfEnc = CFStringEncodings.GB_18030_2000
            let nsEnc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
            
            return String.Encoding(rawValue: nsEnc)
            
        default:
            return .ascii
        }
    }
    
    public func textPart(prefer preferedType: TextType) -> MailPart {
        let textParts = self.singleParts { $0.isText }
        let preferedText = textParts.first { (subPart) in
            guard case let .singlePart(_, data) = subPart,
                case let .text(type, _, _) = data else {
                return false
            }
            return type == preferedType
        }
        return preferedText ?? textParts[0]
    }
    
    public func forEach(_ block: (MailPart)->()) {
        switch self {
        case .multiPart(let id, _, let parts, _):
            if id != nil { block(self) }
            for subPart in parts {
                subPart.forEach(block)
            }
        case .singlePart(_,_):
            block(self)
        }
    }
    
    public func parts(_ predicate: (MailPart)->Bool) -> [MailPart] {
        var parts: [MailPart] = []
        self.forEach { (part) in
            if predicate(part) {
                parts.append(part)
            }
        }
        return parts
    }
    
    public func singleParts(_ predicate: (MailPart)->Bool) -> [MailPart] {
        return self.parts { (part) -> Bool in
            guard case .singlePart = part else {
                return false
            }
            return predicate(part)
        }
    }
    
    public subscript(_ partId: String) -> MailPart? {
        get {
            var hit: MailPart? = nil
            self.forEach { (part) in
                if part.id == partId {
                    hit = part
                }
            }
            return hit
        }
        mutating set {
            guard let newValue = newValue else { return }
            switch self {
            case let .multiPart(id, type, parts, boundary):
                if id == partId {
                    self = newValue
                } else {
                    var newParts: [MailPart] = []
                    for subPart in parts {
                        var newSubPart = subPart
                        newSubPart[partId] = newValue
                        newParts.append(newSubPart)
                    }
 
                    self = .multiPart(id: id, type: type, parts: newParts, boundary: boundary)
                }
            case let .singlePart(id, _):
                guard id == partId else {
                    return
                }
                self = newValue
            }
        }
    }
    
    public var data: Data? {
        get {
            if case let .singlePart(_, mailData) = self {
                switch mailData {
                case let .text(_, _, rawData):
                    return rawData
                case let .basic(_, _, _, rawData):
                    return rawData
                default: break
                }
            }
            return nil
        }
        
        mutating set {
            if case let .singlePart(id, mailData) = self {
                switch mailData {
                case let .text(type, fields, _):
                    self = .singlePart(id: id, data: .text(type: type, fields: fields, rawData: newValue))
                case let .basic(type, disposigion, fields, _):
                    self = .singlePart(id: id, data: .basic(type: type, disposition: disposigion, fields: fields, rawData: newValue))
                default: break
                }
            }
        }
    }
}
