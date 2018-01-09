//
//  File.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2017/12/31.
//

import Foundation

indirect enum File {
    case root (FileManager.SearchPathDirectory)
    case file (String, in: File)
}

extension File {
    var name: String {
        switch self {
        case let .root(dir):
            switch dir {
            case .applicationDirectory: return "applicationDirectory"
            case .demoApplicationDirectory: return "demoApplicationDirectory"
            case .developerApplicationDirectory: return "developerApplicationDirectory"
            case .adminApplicationDirectory: return "adminApplicationDirectory"
            case .libraryDirectory: return "libraryDirectory"
            case .developerDirectory: return "developerDirectory"
            case .userDirectory: return "userDirectory"
            case .documentationDirectory: return "documentationDirectory"
            case .documentDirectory: return "documentDirectory"
            case .coreServiceDirectory: return "coreServiceDirectory"
            case .autosavedInformationDirectory: return "autosavedInformationDirectory"
            case .desktopDirectory: return "desktopDirectory"
            case .cachesDirectory: return "cachesDirectory"
            case .applicationSupportDirectory: return "applicationSupportDirectory"
            case .downloadsDirectory: return "downloadsDirectory"
            case .inputMethodsDirectory: return "inputMethodsDirectory"
            case .moviesDirectory: return "moviesDirectory"
            case .musicDirectory: return "musicDirectory"
            case .picturesDirectory: return "picturesDirectory"
            case .printerDescriptionDirectory: return "printerDescriptionDirectory"
            case .sharedPublicDirectory: return "sharedPublicDirectory"
            case .preferencePanesDirectory: return "preferencePanesDirectory"
            case .itemReplacementDirectory: return "itemReplacementDirectory"
            case .allApplicationsDirectory: return "allApplicationsDirectory"
            case .allLibrariesDirectory: return "allLibrariesDirectory"
            case .trashDirectory: return "trashDirectory"
            case .applicationScriptsDirectory:
                return "applicationScriptsDirectory"
            }
        case let .file(name, in: _):
            return name
        }
    }
    var url: URL {
        switch self {
        case .root (let searchPathDirectory):
            return FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask)[0]
        case .file(let name, let dir):
            return dir.url.appendingPathComponent(name)
        }
    }
    
    var isExist: Bool {
        return FileManager.default.fileExists(atPath: self.url.path)
    }
    
    func create() throws {
        if case .file = self {
            let dirURL: URL
            if self.url.hasDirectoryPath {
                dirURL = self.url
            } else {
                dirURL = self.url.deletingLastPathComponent()
            }
            
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: [.protectionKey : FileProtectionType.complete])
        }
    }
    
    func add(file: String) -> File {
        return .file(file, in: self)
    }
}
