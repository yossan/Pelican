//
//  SearchCondition+.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/13.
//

import Foundation
import Pelican

extension SearchCondition {
    static func weeks(range: CountableRange<Int>) -> [SearchCondition] {
        var weeks: [SearchCondition] = []
        for i in range {
            weeks.append(week(ago: i))
        }
        return weeks
    }

    static func week(ago: Int) -> SearchCondition {
        let timeInterval = TimeInterval(24*60*60*7 * -ago)
        let date = Date(timeIntervalSinceNow: timeInterval)
        let components = date.components
        
        var weekbegin = DateComponents()
        weekbegin.calendar = components.calendar
        weekbegin.year = components.year
        weekbegin.timeZone = TimeZone(secondsFromGMT: 0)
        weekbegin.month = components.month
        weekbegin.weekOfMonth = components.weekOfMonth
        weekbegin.weekday = 1
        let weekbeginDate = weekbegin.date!
        let s = weekbeginDate.components
        let weekbeginCondition: SearchCondition = .key(.sentsince(day: Int32(s.day!), month: Int32(s.month!), year: Int32(s.year!)))
        
        var weekend = DateComponents()
        weekend.calendar = components.calendar
        weekend.year = components.year
        weekend.timeZone = TimeZone(secondsFromGMT: 0)
        weekend.month = components.month
        weekend.weekOfMonth = components.weekOfMonth
        weekend.weekday = 7
        let weekendDate = weekend.date!
        let e = weekendDate.components
        let weekendCondition: SearchCondition = .key(.sentbefore(day: Int32(e.day!), month: Int32(e.month!), year: Int32(e.year!)))
        
        return .and(weekbeginCondition, weekendCondition)
    }
}


