//
//  MailPart.swift
//  Pelican
//
//  Created by yoshi-kou on 2017/12/29.
//

import Foundation

public indirect enum MailPart {
    case multi (id: String, type: MultipartType, parts: [MailPart])
    case single(id: String, header: ContentHeader , data: Data)
}

public enum MultipartType {
//    case mixed
    case alternative
    case related
}

public enum ContentHeader {
    case basic (type: MediaType, disposition: Disposition, fields: MediaFields)
    case text (type: TextType, fields: TextFields)
    case message (header: MessageHeader, body: MailPart)
}

public enum TextType {
    case html
    case plan
}

public struct TextFields {
    let encoding: TransferEncoding
    let size: UInt32
    let charset: String
}

public enum Disposition {
    case inline
    case attachment
}

public struct MediaFields {
    let id: String
    var name: String?
    let subtype: String //拡張子(ex png)
    let size: UInt32
    let encoding: TransferEncoding
    let description: String?
}

public enum MediaType {
    case application
    case audio
    case image
    case message
    case video
    case other
}

public enum TransferEncoding {
    case sevenBit
    case eightBit
    case binary
    case base64
    case quoted
    case other
}
