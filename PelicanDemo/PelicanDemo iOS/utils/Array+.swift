//
//  Array+.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2018/01/14.
//

import Foundation

extension Array {
    mutating func insert(_ element: Element, at predicate: (Element)->(Bool)) -> Int {
        guard self.isEmpty == false else {
            self.append(element)
            return 0
        }
        
        var index = 0
        for comparison in self {
            index += 1
            if predicate(comparison) {
                self.insert(element, at: index)
                return index
            }
        }
        self.append(element)
        return index
    }

    mutating func popLast(_ maxLength: Int) -> [Element] {
        let subdivition = Array(self.suffix(maxLength))
        let deleteCount = self.count > maxLength ? maxLength : self.count
        self.removeLast(deleteCount)
        return subdivition
    }

}
