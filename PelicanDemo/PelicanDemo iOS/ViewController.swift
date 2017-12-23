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
   
    lazy var oauthClient: OAuthClient = {
        let info = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Provider", ofType: "plist")!)!
        let provider = Provider.google(
            withClientId: info["client_id"] as! String,
            clientSecret: "",
            redirectURI: info["redirect_uri"] as! String,
            scopes: ["https://mail.google.com"])
        return OAuthClient(provider: provider)
    }()
    
    var authorizationResult: Result<Token, OAuthClientError>? = nil
    
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
        if self.authorizationResult == nil {
            self.showAuthorizationView()
        } else if case .success(let token) = self.authorizationResult! {
            self.fetchAccountMail(withToken: token.accessToken)
        } else if case .failure(let error) = self.authorizationResult! {
            print("Authorization failed: \(error)")
        }
    }
    
    func showAuthorizationView() {
        let athorizationViewController = self.oauthClient.makeAthorizationViewController()
        athorizationViewController.completionHandler = { [weak athorizationViewController] (result) in
            self.authorizationResult = result
            athorizationViewController?.dismiss(animated: true, completion: nil)
        }
        self.present(athorizationViewController, animated: true, completion: nil)
    }
    
    func fetchAccountMail(withToken token: String) {
        let url = URL(string: "https://www.googleapis.com/gmail/v1/users/me/profile")!
        let urlRequest = NSMutableURLRequest(url: url)
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest) { (data, response, error) in
            guard error == nil, data != nil else {
                print("Fetching account mail failed: \(error!)")
                return
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data!),
                let jsonInfo = jsonObject as? [String: Any],
                let emailAddress = jsonInfo["emailAddress"] as? String else {
                    print("emailAddres not found")
                return
            }
            
            self.connectGmail(user: emailAddress, accessToken: token)
            self.showFolderList()
        }
        task.resume()
    }
    
    func connectGmail(user:String, accessToken: String) {
        let imapSession = ImapSession.shared
        _ = imapSession.connect(hostName: "imap.gmail.com", port: 993)
        _ = imapSession.login(user: user, accessToken: accessToken)
    }
    
    func showFolderList() {
        DispatchQueue.main.async {
            let folderListViewController = self.storyboard!.instantiateViewController(withIdentifier: "FolderListViewController")
            self.navigationController?.pushViewController(folderListViewController, animated: true)
        }
    }
    
}

