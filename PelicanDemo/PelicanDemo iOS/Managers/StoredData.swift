//
//  StoredData.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2017/12/30.
//

import Foundation
import OAuthClient

class StoredData {
    static let shared = StoredData()
    
    // MARK: - token
    
    lazy var token: Token? = {
        return self.load(Token.self, from: Paths.tokenFile)
    }()
    
    func save(token: Token) throws {
        self.token = token
        try self.save(token, to: Paths.tokenFile)
    }
    
    // MARK: - user
    lazy var user: User? = {
        return self.load(User.self, from: Paths.userFile)
    }()
    
    func save(user: User) throws {
        self.user = user
        try self.save(user, to: Paths.userFile)
    }
}

extension StoredData {
    func save<T>(_ object: T, to file: File) throws where T: Encodable {
        do {
            if file.isExist == false {
                try file.create()
            }
            let data = try JSONEncoder().encode(object)
            try data.write(to: file.url, options: [.completeFileProtection])
        } catch let e as NSError {
            print("Saving \(type(of: object)) failed: \(e)")
            throw e
        }
    }
    
    func load<T>(_ type: T.Type, from file: File) -> T? where T: Decodable {
        do {
            let data = try Data(contentsOf: file.url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch let e as NSError {
            print("Loading Token failed: \(e)")
            return nil
        }
    }
}

