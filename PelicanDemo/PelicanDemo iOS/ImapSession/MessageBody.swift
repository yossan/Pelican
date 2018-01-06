//
//  MessageBody.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/04.
//

import Foundation
import Pelican

/**
 # MessageBody
 - text: a text singlePart or an alternative multiPart which of parts contains two text singleParts.
 - inlines: Collection of a inline basic singlePart.
 - attachment: Collection of a attachment basic singlePart.
 */
struct MessageBody {
    public let texts: [TextData]
    public let inlines: [MediaData]?
    public let attachments: [MediaData]?
    
    // Returns nil if the given mailPart is not supported.
    init?(root: MailPart) {
        var texts: [TextData] = []
        var inlines: [MediaData] = []
        var attachements: [MediaData] = []
        
        root.split(&texts, &inlines, &attachements)
        guard texts.count > 0 else { return nil }
        self.texts = texts
        self.inlines = inlines
        self.attachments = attachements
    }
    
    func findText(_ type: TextType)  -> TextData? {
        var hit: TextData? = nil
        for text in texts {
            guard text.type == type else {
                continue
            }
            hit = text
            break
        }
        return hit
    }
}

//case text (type: TextType, fields: BodyFields, rowData: Data?)
struct TextData {
    let partId: String
    let type: TextType
    let bodyFields: BodyFields
    var data: Data?
}

//case basic (type: MediaType, disposition: Disposition, fields: BodyFields, rowData: Data?)
struct MediaData {
    let partId: String
    let type: MediaType
    let fields: BodyFields
    var data: Data?
}

extension MailPart {
    
    fileprivate func forEach(_ body: (MailPart) -> ()) {
        body(self)
        if case let .multiPart(_,_,parts,_) = self {
            parts.forEach { (subPart) in
                subPart.forEach(body)
            }
        }
    }
    
    fileprivate func split(_ text: inout [TextData], _ inlines: inout [MediaData], _ attachments: inout [MediaData]) {
        self.forEach { (mailPart) in
            guard case let .singlePart(partId, data)  = mailPart else {
                return
            }
            switch data {
            case let .basic(type, disposition, fields, rowData):
                let mediaData = MediaData(partId: partId, type: type, fields: fields, data: rowData)
                if disposition == .inline {
                    inlines.append(mediaData)
                } else {
                    attachments.append(mediaData)
                }
            case let .text(type, fields, rowData):
                let textData = TextData(partId: partId, type: type, bodyFields: fields, data: rowData)
                text.append(textData)
            default: break
            }
        }
        
        /*
        switch self {
        case let .multiPart(_, type, parts, _):
            switch type {
            case .related:
                for subPart in parts {
                    subPart.split(&text, &inlines, &attachments)
                }
            case .alternative:
                let isContainingTextPart = parts.reduce(true) { (result, subPart) in
                    return result && subPart.isTextPart
                }
                if isContainingTextPart == true {
                    
                    text.append(self)
                } else {
                    self.split(&text, &inlines, &attachments)
                }
            default:
                break
            }
        case let .singlePart(_, data):
            switch data {
            case .text:
                text.append(self)
            case .basic(_, let disposition, _, _):
                switch disposition {
                case .inline:
                    inlines.append(self)
                case .attachment:
                    attachments.append(self)
                default: break
                }
            case .message: break
            }
        }
         */
    }
    
    var isTextPart: Bool {
        if case let .singlePart(_, type) = self,
            case .text = type {
            return true
        } else {
            return false
        }
    }
}
