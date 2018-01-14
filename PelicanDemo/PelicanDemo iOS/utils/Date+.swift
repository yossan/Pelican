//
//  Date+.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/14.
//

import Foundation

extension Date {
    var components: DateComponents {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([
            .calendar,
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second,
            .nanosecond,
            .timeZone,
            .weekday,
            .weekOfYear,
            .weekOfMonth,
            .weekdayOrdinal,
            .era,
            .quarter,
            .timeZone], from: self)
        return components
    }
}
