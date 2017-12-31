//
//  File.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2017/12/31.
//

import Foundation

indirect enum File {
    case root (FileManager.SearchPathDirectory)
    case sub  (String, in: File)
    case file (String, in: File)
}

extension File {
    var url: URL {
        switch self {
        case .root (let searchPathDirectory):
            return FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask)[0]
        case .sub(let name, let dir):
            return dir.url.appendingPathComponent(name, isDirectory: true)
        case .file(let name, let dir):
            return dir.url.appendingPathComponent(name, isDirectory: false)
        }
    }
    
    var isExist: Bool {
        return FileManager.default.fileExists(atPath: self.url.path)
    }
    
    func create() throws {
        switch self {
        case .root: break
        case .sub:
            try FileManager.default.createDirectory(at: self.url, withIntermediateDirectories: true, attributes: [.protectionKey : FileProtectionType.complete])
        case .file(_, let dir):
            try dir.create()
        }
    }
}
