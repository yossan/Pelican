//
//  String.Encoding+.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/12.
//

import Foundation

extension String.Encoding {
    init?(charset: String) {
        switch charset.lowercased() {
        case "utf-8":
            self = .utf8
        case "utf-16":
            self = .utf16
        case "utf-16be":
            self = .utf16BigEndian
        case "utf-16le":
            self = .utf16LittleEndian
        case "utf-32":
            self = .utf32
        case "utf-32be":
            self = .utf32BigEndian
        case "utf-32le":
            self = .utf32LittleEndian
        case "iso-2022-jp":
            self = .iso2022JP
        case "euc-jp":
            self = .japaneseEUC
        case "shift_jis":
            self = .shiftJIS
        case "‎windows-1250":
            self = .windowsCP1250
        case "‎windows-1251":
            self = .windowsCP1251
        case "‎windows-1252":
            self = .windowsCP1252
        case "‎windows-1253":
            self = .windowsCP1253
        case "‎windows-1254":
            self = .windowsCP1254
        case "big5":
            let cfEnc = CFStringEncodings.big5
            let nsEnc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
            self = String.Encoding(rawValue: nsEnc)
        case "GB18030":
            let cfEnc = CFStringEncodings.GB_18030_2000
            let nsEnc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
            self = String.Encoding(rawValue: nsEnc)
        default:
            return nil
        }
    }
}
