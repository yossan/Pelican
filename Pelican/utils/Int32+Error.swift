//
//  Int32+libetpanError.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/08.
//

import Foundation
import libetpan

extension Int32 {
    func toImapSessionError() -> ImapSessionError {
        return ImapSessionError(self)
    }
    
    func toMIMEError() -> MIMEError {
        return MIMEError(self)
    }
}
