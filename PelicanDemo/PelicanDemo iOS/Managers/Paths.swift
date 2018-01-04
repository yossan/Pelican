//
//  Paths.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2017/12/31.
//

import Foundation
import UIKit

/** Application file structure manager
 + Application Support/
   + PelicanDemo/
     + StoredData/ token.dat, userInfo.dat
 */
class Paths {
    
    // MARK: - Files in Application Support
    private static let applicationSupport: File = .root(.applicationSupportDirectory)
    private static let appDir: File = .sub(Bundle.main.bundleIdentifier!, in: applicationSupport)
    
    // MARK: Files in StoredData
    private static let storedData: File = .sub("StoredData", in: appDir)
    static let tokenFile: File = .file("token.dat", in: storedData)
    static let userFile : File = .file("userInfo.dat", in: storedData)
}
