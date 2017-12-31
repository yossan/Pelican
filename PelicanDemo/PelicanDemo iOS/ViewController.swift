//
//  ViewController.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2017/12/23.
//

import UIKit
import OAuthClient
import Result
import Pelican

class ViewController: UIViewController {
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       
    }
    

    
    
    
    
    
    func connectGmail(user:String, accessToken: String) {
        let imapSession = ImapSession.shared
        var r = imapSession.connect(hostName: "imap.gmail.com", port: 993)
        print("connect", r)
        r = imapSession.login(user: user, accessToken: accessToken)
        print("login", r)
    }
    
    func showFolderList() {
        let folderListViewController = self.storyboard!.instantiateViewController(withIdentifier: "FolderListViewController")
        
        
    }
    

}

