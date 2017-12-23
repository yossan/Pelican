//
//  ImapSession+Result.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2017/12/23.
//

public extension ImapSession {
    public enum Result: Int {
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
        case Unknown
        
        init(_ value: Int32) {
            if let r =  Result(rawValue: Int(value)) {
                self = r
            } else {
                self = .Unknown
            }
        }
    }
}
