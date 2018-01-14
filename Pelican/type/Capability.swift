//
//  Capability.swift
//  Pelican
//
//  Created by yoshi-kou on 2018/01/14.
//

import Foundation
import libetpan

public struct Capability: OptionSet {
    public let rawValue: Int64
    public init(rawValue: Int64) { self.rawValue = rawValue }
    
    static let ACL =                    Capability(rawValue: 1 << 0)
    static let Binary =                 Capability(rawValue: 1 << 1)
    static let Catenate =               Capability(rawValue: 1 << 2)
    static let Children =               Capability(rawValue: 1 << 3)
    static let CompressDeflate =        Capability(rawValue: 1 << 4)
    static let Condstore =              Capability(rawValue: 1 << 5)
    static let Enable =                 Capability(rawValue: 1 << 6)
    static let Idle =                   Capability(rawValue: 1 << 7)
    static let Id =                     Capability(rawValue: 1 << 8)
    static let LiteralPlus =            Capability(rawValue: 1 << 9)
    static let Move =                   Capability(rawValue: 1 << 10)
    static let MultiAppend =            Capability(rawValue: 1 << 11)
    static let Namespace =              Capability(rawValue: 1 << 12)
    static let QResync =                Capability(rawValue: 1 << 13)
    static let Quota =                  Capability(rawValue: 1 << 14)
    static let Sort =                   Capability(rawValue: 1 << 15)
    static let StartTLS =               Capability(rawValue: 1 << 16)
    static let ThreadOrderedSubject =   Capability(rawValue: 1 << 17)
    static let ThreadReferences =       Capability(rawValue: 1 << 18)
    static let UIDPlus =                Capability(rawValue: 1 << 19)
    static let Unselect =               Capability(rawValue: 1 << 20)
    static let XList =                  Capability(rawValue: 1 << 21)
    static let AuthAnonymous =          Capability(rawValue: 1 << 22)
    static let AuthCRAMMD5 =            Capability(rawValue: 1 << 23)
    static let AuthDigestMD5 =          Capability(rawValue: 1 << 24)
    static let AuthExternal =           Capability(rawValue: 1 << 25)
    static let AuthGSSAPI =             Capability(rawValue: 1 << 26)
    static let AuthKerberosV4 =         Capability(rawValue: 1 << 27)
    static let AuthLogin =              Capability(rawValue: 1 << 28)
    static let AuthNTLM =               Capability(rawValue: 1 << 29)
    static let AuthOTP =                Capability(rawValue: 1 << 30)
    static let AuthPlain =              Capability(rawValue: 1 << 31)
    static let AuthSKey =               Capability(rawValue: 1 << 32)
    static let AuthSRP =                Capability(rawValue: 1 << 33)
    static let XOAuth2 =                Capability(rawValue: 1 << 34)
    static let XYMHighestModseq =       Capability(rawValue: 1 << 35)
    static let Gmail =                  Capability(rawValue: 1 << 36)
}

extension Capability {
    init(mailimap imap: UnsafeMutablePointer<mailimap>) {
        typealias Check = (UnsafeMutablePointer<mailimap>) -> Int32
        typealias CheckAndCap = (check: Check, cap: Capability)
        let checks: [CheckAndCap] = [
            ({ mailimap_has_extension($0, "STARTTLS") }, .StartTLS),
            ({ mailimap_has_authentication($0, "PLAIN") }, .AuthPlain),
            ({ mailimap_has_authentication($0, "LOGIN") }, .AuthLogin),
            (mailimap_has_idle, .Idle),
            (mailimap_has_id, .Id),
            (mailimap_has_xlist, .XList),
            ({ mailimap_has_extension($0, "X-GM-EXT-1") }, .Gmail),
            (mailimap_has_condstore, .Condstore),
            (mailimap_has_qresync, .QResync),
            (mailimap_has_xoauth2, .XOAuth2),
            (mailimap_has_namespace, .Namespace),
            (mailimap_has_compress_deflate, .CompressDeflate),
            ({ mailimap_has_extension($0, "CHILDREN") }, .Children),
            ({ mailimap_has_extension($0, "MOVE") }, .Move),
            ({ mailimap_has_extension($0, "XYMHIGHESTMODSEQ") }, .XYMHighestModseq),
            ({ mailimap_has_extension($0, "LITERAL+") }, .LiteralPlus)
        ]
        
        self = checks.reduce([]) { (memo: Capability, checkAndCap: CheckAndCap) -> Capability in
            return checkAndCap.check(imap) == 1 ? memo.union(checkAndCap.cap) : memo
        }
    }
}
