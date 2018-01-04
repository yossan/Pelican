//
//  RootViewController.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2017/12/30.
//

import UIKit
import OAuthClient

class RootViewController: UIViewController {

    let authSession = AuthorizationSession(user: StoredData.shared.user)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let user = StoredData.shared.user {
            self.moveToImapSessionView(with: user, from: nil)
        } else {
            self.showAuthSessionViewView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showAuthSessionViewView() {
        let authSessionViewController = self.makeAuthSessionViewController()
        self.addChildViewController(authSessionViewController)
        authSessionViewController.view.frame = self.view.bounds
        self.view.addSubview(authSessionViewController.view)
        authSessionViewController.didMove(toParentViewController: self)
    }
    
    private func makeAuthSessionViewController() -> AuthorizationSessionViewController {
        let authSessionViewController = self.authSession.makeViewController()
        authSessionViewController.completionHadler = { [unowned authSessionViewController] (result) in
            switch result {
            case .success(let user):
                self.moveToImapSessionView(with: user, from: authSessionViewController)
            case .failure(let error):
                self.handleAuthError(error)
                authSessionViewController.dismiss(animated: true)
            }
        }
        return authSessionViewController
    }
    
    func moveToImapSessionView(with user: User, from fromViewController: UIViewController?) {
        let imapViweController = self.makeImapSessionViewController(with: user)
        self.addChildViewController(imapViweController)
        imapViweController.view.frame = self.view.bounds
        self.view.insertSubview(imapViweController.view, at: 0)
        
        if let from = fromViewController {
            from.willMove(toParentViewController: nil)
    
            UIView.animate(withDuration: 0.25, animations: {
                var fromRect = from.view.frame
                fromRect.origin.y += self.view.frame.size.height
                from.view.frame = fromRect
                
            }, completion: { (finished) in
                from.removeFromParentViewController()
                imapViweController.didMove(toParentViewController: self)
                from.removeFromParentViewController()
            })
            
        } else {
            self.view.addSubview(imapViweController.view)
            imapViweController.didMove(toParentViewController: self)
        }
    }
    
    func makeImapSessionViewController(with user: User) -> ImapSessionViewController {
        let imapViewController = UIStoryboard(name: "ImapSession", bundle: nil).instantiateInitialViewController() as! ImapSessionViewController
        let authSession = AuthorizationSession(user: user)
        imapViewController.authSession = authSession
        return imapViewController
    }
    
    func handleAuthError(_ error: OAuthClientError) {
        
    }


}
