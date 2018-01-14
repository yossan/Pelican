//
//  SearchKey.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/13.
//

import Foundation
import libetpan

public enum SearchKye {
    case all
    case sentbefore (day: Int32, month: Int32, year: Int32)
    case sentsince  (day: Int32, month: Int32, year: Int32)
    case subject (String)
    case to      (String)
    case cc      (String)
    case bcc     (String)
    case body    (String)
    case text    (String)
    case unseen
    case seen
    case flagged
    
    static let charset = "UTF-8"
    
    func createMAILIMAP_SEACH_KEY() -> UnsafeMutablePointer<mailimap_search_key> {
        switch self {
        case .all:
            return mailimap_search_key_new_all()
        case .sentbefore(let day, let month, let year):
            let date = mailimap_date_new(day, month, year)
            return mailimap_search_key_new_sentbefore(date)
        case .sentsince (let day, let month, let year):
            let date = mailimap_date_new(day, month, year)
            return mailimap_search_key_new_sentsince(date)
        case .subject (let text):
            return mailimap_search_key_new_subject(text.createCString(using: .utf8))
        case .to (let text):
            return mailimap_search_key_new_to(text.createCString(using: .utf8))
        case .cc (let text):
            return mailimap_search_key_new_cc(text.createCString(using: .utf8))
        case .bcc (let text):
            return mailimap_search_key_new_bcc(text.createCString(using: .utf8))
        case .body (let text):
            return mailimap_search_key_new_body(text.createCString(using: .utf8))
        case .text (let text):
            return mailimap_search_key_new_text(text.createCString(using: .utf8))
        case .unseen:
            return mailimap_search_key_new(Int32(MAILIMAP_SEARCH_KEY_UNSEEN),
                                           nil, nil, nil, nil, nil,
                                           nil, nil, nil, nil, nil,
                                           nil, nil, nil, nil, 0,
                                           nil, nil, nil, nil, nil,
                                           nil, 0, nil, nil, nil)
        case .seen:
            return mailimap_search_key_new(Int32(MAILIMAP_SEARCH_KEY_SEEN),
                                           nil, nil, nil, nil, nil,
                                           nil, nil, nil, nil, nil,
                                           nil, nil, nil, nil, 0,
                                           nil, nil, nil, nil, nil,
                                           nil, 0, nil, nil, nil)
        case .flagged:
            return mailimap_search_key_new(Int32(MAILIMAP_SEARCH_KEY_FLAGGED),
                                           nil, nil, nil, nil, nil,
                                           nil, nil, nil, nil, nil,
                                           nil, nil, nil, nil, 0,
                                           nil, nil, nil, nil, nil,
                                           nil, 0, nil, nil, nil)
            
        }
    }
}
