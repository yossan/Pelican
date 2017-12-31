//
//  LoginSession.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2017/12/30.
//

import Foundation
import OAuthClient
import Result

class AuthorizationSession {
    
    static let shared: AuthorizationSession = AuthorizationSession()
    
    enum State {
        case new
        case tokenExpiration
        case loginPossible (Token, User)
    }
    
    var state: State {
        if let user = StoredData.shared.user,
            let token = StoredData.shared.token {
            if token.isExpired {
                return .tokenExpiration
            } else {
                return .loginPossible(token, user)
            }
        } else {
            return .new
        }
    }
 
    // MARK: - Instance properties
    
    lazy var oauthClient: OAuthClient = {
        let info = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Provider", ofType: "plist")!)!
        let provider = Provider.google(
            withClientId: info["client_id"] as! String,
            clientSecret: "",
            redirectURI: info["redirect_uri"] as! String,
            scopes: ["https://mail.google.com"])
        return OAuthClient(provider: provider)
    }()
    
    // MARK: - Public functions
    
    var hasValidAccessToken: Bool {
        return false
    }
    
    func makeAuthorizationViewController() -> AuthorizationViewController {
        return self.oauthClient.makeAuthorizationViewController()
    }
    
    func refreshAccessToken() {
//        self.oauthClient.refreshAccessToken(<#T##token: Token##Token#>, withCompletion: <#T##(Result<Token, OAuthClientError>) -> Void#>)
    }
}
