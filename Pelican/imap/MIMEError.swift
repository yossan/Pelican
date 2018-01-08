//
//  MIMEError.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/08.
//

import Foundation

/*
 enum {
 MAILIMF_NO_ERROR = 0,
 MAILIMF_ERROR_PARSE,
 MAILIMF_ERROR_MEMORY,
 MAILIMF_ERROR_INVAL,
 MAILIMF_ERROR_FILE
 };
 */
enum MIMEError: Int, Error {
    case NO_ERROR
    case PARSE
    case MEMORY
    case INVAL
    case FILE
    
    init(_ value: Int32) {
        self.init(rawValue: Int(value))!
    }
    
    var isSuccess: Bool {
        switch self {
        case .NO_ERROR:
            return true
        default:
            return false
        }
    }
    
    func check() throws {
        if self.isSuccess == false {
            throw self
        }
    }
}
