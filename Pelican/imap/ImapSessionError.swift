//
//  ImapSessionError.swift
//  Pelican
//
//  Created by yoshi-kou on 2017/12/30.
//

import Foundation

public enum ImapSessionError: Int, Error {
    case NO_ERROR = 0
    case NO_ERROR_AUTHENTICATED = 1
    case NO_ERROR_NON_AUTHENTICATED = 2
    case BAD_STATE
    case STREAM
    case PARSE
    case CONNECTION_REFUSED
    case MEMORY
    case FATAL
    case PROTOCOL
    case DONT_ACCEPT_CONNECTION
    case APPEND
    case NOOP
    case LOGOUT
    case CAPABILITY
    case CHECK
    case CLOSE
    case EXPUNGE
    case COPY
    case UID_COPY
    case MOVE
    case UID_MOVE
    case CREATE
    case DELETE
    case EXAMINE
    case FETCH
    case UID_FETCH
    case LIST
    case LOGIN
    case LSUB
    case RENAME
    case SEARCH
    case UID_SEARCH
    case SELECT
    case STATUS
    case STORE
    case UID_STORE
    case SUBSCRIBE
    case UNSUBSCRIBE
    case STARTTLS
    case INVAL
    case EXTENSION
    case SASL
    case SSL
    case NEEDS_MORE_DATA
    case CUSTOM_COMMAND
    case UNKNOWN
    
    init(_ value: Int32) {
        if let r =  ImapSessionError(rawValue: Int(value)) {
            self = r
        } else {
            self = .UNKNOWN
        }
    }
    
    public var isSuccess: Bool {
        switch self {
        case .NO_ERROR,
             .NO_ERROR_AUTHENTICATED,
             .NO_ERROR_NON_AUTHENTICATED:
            return true
        default:
            return false
        }
    }
    
    public func check() throws {
        guard self.isSuccess == false else {
            return
        }
        throw self
    }
}

extension ImapSessionError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .NO_ERROR: return "NO_ERROR"
        case .NO_ERROR_AUTHENTICATED: return "NO_ERROR_AUTHENTICATED"
        case .NO_ERROR_NON_AUTHENTICATED: return "NO_ERROR_NON_AUTHENTICATED"
        case .BAD_STATE: return "BAD_STATE"
        case .STREAM: return "STREAM"
        case .PARSE: return "PARSE"
        case .CONNECTION_REFUSED: return "CONNECTION_REFUSED"
        case .MEMORY: return "MEMORY"
        case .FATAL: return "FATAL"
        case .PROTOCOL: return "PROTOCOL"
        case .DONT_ACCEPT_CONNECTION: return "DONT_ACCEPT_CONNECTION"
        case .APPEND: return "APPEND"
        case .NOOP: return "NOOP"
        case .LOGOUT: return "LOGOUT"
        case .CAPABILITY: return "CAPABILITY"
        case .CHECK: return "CHECK"
        case .CLOSE: return "CLOSE"
        case .EXPUNGE: return "EXPUNGE"
        case .COPY: return "COPY"
        case .UID_COPY: return "UID_COPY"
        case .MOVE: return "MOVE"
        case .UID_MOVE: return "UID_MOVE"
        case .CREATE: return "CREATE"
        case .DELETE: return "DELETE"
        case .EXAMINE: return "EXAMINE"
        case .FETCH: return "FETCH"
        case .UID_FETCH: return "UID_FETCH"
        case .LIST: return "LIST"
        case .LOGIN: return "LOGIN"
        case .LSUB: return "LSUB"
        case .RENAME: return "RENAME"
        case .SEARCH: return "SEARCH"
        case .UID_SEARCH: return "UID_SEARCH"
        case .SELECT: return "SELECT"
        case .STATUS: return "STATUS"
        case .STORE: return "STORE"
        case .UID_STORE: return "UID_STORE"
        case .SUBSCRIBE: return "SUBSCRIBE"
        case .UNSUBSCRIBE: return "UNSUBSCRIBE"
        case .STARTTLS: return "STARTTLS"
        case .INVAL: return "INVAL"
        case .EXTENSION: return "EXTENSION"
        case .SASL: return "SASL"
        case .SSL: return "SSL"
        case .NEEDS_MORE_DATA: return "NEEDS_MORE_DATA"
        case .CUSTOM_COMMAND: return "CUSTOM_COMMAND"
        default: return "Unknown"
        }
    }
}

extension ImapSessionError: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int32) {
        self.init(value)
    }
}
