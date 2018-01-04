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
    
    init(user: User?) {
        self.user = user ?? User.new()
    }
    
    //MARK: - Instance properties
    
    let user: User
    
    var state: State {
        if self.user.isNew == false {
            if let token = self.user.token,
                token.isExpired {
                return .tokenExpiration(token)
            } else {
                return .loginPossible(user)
            }
        } else {
            return .new
        }
    }
 
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
    
    func saveUserInfo() {
        if user.isNew == false {
            try? StoredData.shared.save(user: user)
        }
    }
    
    func makeViewController() -> AuthorizationSessionViewController {
        let viewController = AuthorizationSessionViewController(nibName: "AuthorizationSessionViewController", bundle: nil)
        viewController.manager = self
        return viewController
    }
    
    func refreshAccessToken(_ oldToken: Token, completion: @escaping (Result<User, OAuthClientError>)->()) {
        
        self.oauthClient.refreshAccessToken(oldToken) { (result) in
            switch result {
            case .success(let token):
                self.user.token = token
                try? StoredData.shared.update(token: token)
                completion(.success(self.user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
