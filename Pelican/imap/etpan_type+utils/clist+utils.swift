//
//  clist+utils.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2017/12/24.
//

import Foundation
import libetpan

class ClistIterator<T>: IteratorProtocol {
    let clist: UnsafeMutablePointer<clist>
    var current: UnsafeMutablePointer<clistcell>?
    
    init(clist: UnsafeMutablePointer<clist>) {
        self.clist = clist
        self.current = self.clist.pointee.first
    }
    
    func next() -> UnsafeMutablePointer<T>? {
        defer {
            current = current?.pointee.next
        }
        guard let unsafeData = current?.pointee.data else { return nil }
        let data = unsafeData.bindMemory(to: T.self, capacity: 1)
        return data
    }
}

func sequence<T>(_ clist: UnsafeMutablePointer<clist>, of type: T.Type) -> AnySequence<UnsafeMutablePointer<T>> {
    return AnySequence {
        return ClistIterator(clist: clist)
    }
}

extension UnsafeMutablePointer where Pointee == clist {
    func array<T>() -> [T] {
        var temps: [T] = []
        for item in sequence(self, of: T.self) {
            temps.append(item.pointee)
        }
        return temps
    }
}

