//
//  LoginSessionViewController.swift
//  PelicanDemo iOS
//
//  Created by yoshi-kou on 2017/12/30.
//

import UIKit
import OAuthClient
import Result

class AuthorizationSessionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Implementation
    
    // MARK: - Properties
    
   
    
    var authorizationResult: Result<Token, OAuthClientError>? = nil
    
    // MARK: - functions

    func showAuthorizationView() {
        let authorizationViewController = LoginSession.shared.makeAuthorizationViewController()
        authorizationViewController.completionHandler = { [weak authorizationViewController] (result) in
            self.authorizationResult = result
            switch result {
            case .success(let token):
                self.saveAccessToken(token.accessToken)
                self.fetchAccountMail(withToken: token.accessToken)
            case .failure(let error):
                print("Authorization failed: \(error)")
            }
            
            authorizationViewController?.dismiss(animated: true, completion: nil)
        }
        self.present(authorizationViewController, animated: true, completion: nil)
    }
    
    func fetchAccountMail(withToken token: String) {
        let url = Configuration.gmail.getUserURL
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
                    DispatchQueue.main.async {
                        self.showAuthorizationView()
                    }
                    return
            }
            
            self.showImapSessionView()
        }
        task.resume()
    }
    
   
    func showImapSessionView() {
        
    }
    
    // MARK -
    
   
}
