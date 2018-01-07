//
//  MailPart+util.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/07.
//

import Foundation

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
            switch self {
            case let .multiPart(id, _, parts, _):
                if id == partId {
                    return self
                } else {
                    return parts.first(where: { (subPart) -> Bool in
                        return subPart[partId] != nil
                    })
                }
            case let .singlePart(id, _):
                if id == partId {
                    return self
                }
                return nil
            }
        }
        mutating set {
            guard let newValue = newValue else { return }
            switch self {
            case let .multiPart(id, _, parts, _):
                if id == partId {
                    self = newValue
                } else {
                    var p = parts.first(where: { (subPart) -> Bool in
                        subPart[partId] != nil
                    })
                    p?[partId] = newValue
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
