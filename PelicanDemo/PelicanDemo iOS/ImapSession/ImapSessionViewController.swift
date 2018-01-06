//
//  ImapSessionViewController.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2017/12/30.
//

import UIKit
import OAuthClient
import Result
import Pelican

class ImapSessionViewController: UIViewController {

    var authSession: AuthorizationSession! = nil
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.moveForMessageListView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    override func viewDidAppear(_ animated: Bool) {
//        self.showInitialContentView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Internal
    let commandQueue: OperationQueue = {
        let q = OperationQueue()
        q.name = "ImapCommandOperationQueue"
        return q
    }()
    
    func command(_ task: @escaping (ImapSession) throws -> (), catched: @escaping (Error) -> ())  {
        commandQueue.addOperation {
            do {
                try task(ImapSession.shared)
            } catch let error  {
                OperationQueue.main.addOperation {
                    catched(error)
                }
            }
        }
    }
    
    func handleImapError(_ error: ImapSessionError?) {
    }
    
    
    // MARK: - private
    
    private func moveForMessageListView() {
        switch self.authSession.state {
        case .tokenExpiration (let token):
            self.refreshToken(token) { (result) in
                switch result {
                case .success(let user):
                    self.showMessageList(with: user)
                case .failure(let error):
                    self.handleAuthError(error)
                }
            }
        case .loginPossible (let user):
            self.showMessageList(with: user)
        default: break
        }
    }
    
    private func showMessageList(with user: User) {
        self.command({[weak self] (imap) -> () in
            let gmail = Configuration.gmail
            try imap.connect(hostName: gmail.host, port: gmail.port).check()
            try imap.login(user: user.email!, accessToken: user.token!.accessToken).check()
            try imap.select("INBOX").check()
            
            guard let `self` = self else { return }
            OperationQueue.main.addOperation { [weak self] in
                guard let `self` = self else { return }
                let msgNaviViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageNavigationViewController") as! UINavigationController
                self.addChildViewController(msgNaviViewController)
                msgNaviViewController.view.frame = self.view.bounds
                self.view.addSubview(msgNaviViewController.view)
                msgNaviViewController.didMove(toParentViewController: self)
            }
            }, catched: { (error) in
                self.handleImapError(error as? ImapSessionError)
        })
    }
    
    private func showAuthorizationSessionView(animated: Bool = true) {
        let authSessionViewController = self.authSession.makeViewController()
        authSessionViewController.completionHadler = { [unowned authSessionViewController] (result) in
            switch result {
            case .success(let user):
                authSessionViewController.dismiss(animated: true, completion: {
                    self.showMessageList(with: user)
                })
            case .failure(let error):
                self.handleAuthError(error)
                authSessionViewController.dismiss(animated: true)
            }
        }
        
        self.present(authSessionViewController, animated: animated, completion: nil)
    }
    
    private func refreshToken(_ token: Token, completion: @escaping (Result<User, OAuthClientError>)->()) {
        self.authSession.refreshAccessToken(token){ (result) in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
//                self.handleAuthError(error)
                completion(.failure(error))
            }
        }
    }
    
    private func handleAuthError(_ error: OAuthClientError) {
        switch error {
        case .networkError(let error): break
        case .accessTokenDenied: break
        case .invalidScope(let desc): break
        case .userCancelled: break
        case .invalidGrant: fallthrough
        case .invalidRequest: fallthrough
        case .unknown: break
        }
    }
}
