//
//  String+.swift
//  Pelican iOS
//
//  Created by yoshi-kou on 2017/12/24.
//

import Foundation

extension UnsafeMutablePointer where Pointee == Int8 {
    var string: String {
        return String(cString: self)
    }
}

extension String {
    func createCString(using encoding: String.Encoding) -> UnsafeMutablePointer<Int8> {
        let data = self.data(using: encoding)!
        let cstring = UnsafeMutablePointer<Int8>.allocate(capacity: 1)
        data.withUnsafeBytes({ (pointer: UnsafePointer<Int8>) in
            cstring.initialize(from: pointer, count: data.count)
        })
        return cstring
    }
}
