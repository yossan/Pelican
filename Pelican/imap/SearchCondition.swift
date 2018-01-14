//
//  SearchCondition.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2018/01/13.
//

import Foundation
import libetpan

public indirect enum SearchCondition {
    case and (SearchCondition, SearchCondition)
    case or  (SearchCondition, SearchCondition)
    case not (SearchCondition)
    case key (SearchKye)
    
    func createMAILIMAP_SEACH_KEY() -> UnsafeMutablePointer<mailimap_search_key> {
        switch self {
        case .and(let lhs, let rhs):
            return mailimap_search_key_new_multiple([lhs, rhs].createClist())
        case .or(let lhs, let rhs):
            return mailimap_search_key_new_or(lhs.createMAILIMAP_SEACH_KEY(), rhs.createMAILIMAP_SEACH_KEY())
        case .not(let condition):
            return mailimap_search_key_new_not(condition.createMAILIMAP_SEACH_KEY())
        case .key(let searchKey):
            return searchKey.createMAILIMAP_SEACH_KEY()
        }
    }
}

extension Array where Element == SearchCondition {
    func createClist() -> UnsafeMutablePointer<clist> {
        let list = clist_new()!
        for condition in self {
            clist_append(list, condition.createMAILIMAP_SEACH_KEY())
        }
        return list
    }
}
