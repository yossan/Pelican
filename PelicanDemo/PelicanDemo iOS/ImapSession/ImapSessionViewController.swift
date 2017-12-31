//
//  ImapSessionViewController.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2017/12/30.
//

import UIKit
import Pelican

class ImapSessionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func command<R>(ctx: UnsafeRawPointer? = nil, task: (ImapSession) throws -> R?, success: (UnsafeRawPointer?, R?) -> Void, failure: ((UnsafeRawPointer?, ImapSessionError) -> (Bool))? = nil) {
        do {
            let r = try task(ImapSession.shared)
            success(ctx, r)
        } catch let error  {
            if let error = error as? ImapSessionError {
                guard let failure = failure else {
                    self.handleImapError(error)
                    return
                }
                if failure(ctx, error) {
                    self.handleImapError(error)
                }
            }
        }
    }
    
    func handleImapError(_ error: ImapSessionError?) {
        
    }

    
    func showInitialContentView() {
        switch AuthorizationSession.shared.state {
        case .new:
            self.showAuthorizationSessionView()
        // AuthorizationSessionViewを表示する
        case .tokenExpiration:
            AuthorizationSession.shared.refreshAccessToken()
        // refreshToken
        case .loginPossible (let token, let user):
            self.command(ctx: nil,
                task: { (imap) -> Void in
                    let gmail = Configuration.gmail
                    try imap.connect(hostName: gmail.host, port: gmail.port).check()
                    try imap.login(user: user.email, accessToken: token.accessToken).check()
                },
                success: { _,_ in
                })
            // connect & login
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

    
    func connectGmail(user:String, accessToken: String) {
        
        let imapSession = ImapSession.shared
        let gmail = Configuration.gmail
        var r = imapSession.connect(hostName: gmail.host, port: gmail.port)
        print("connect", r)
        r = imapSession.login(user: user, accessToken: accessToken)
        print("login", r)
    }
    
    func loginGmail() {
    }
    
    // ログインに失敗した際は表示する
    func showAuthorizationSessionView() {
    }
    
    func selectInbox() {
    }
    
    func showMessageListView() {
    }
}
