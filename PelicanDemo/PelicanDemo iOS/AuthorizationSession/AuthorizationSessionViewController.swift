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

    // MARK: - Instance properties
    var manager: AuthorizationSession!
    var authedResult: Result<Token, OAuthClientError>? = nil
    var completionHadler: ((Result<User, OAuthClientError>) -> ())? = nil

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.authedResult == nil {
            self.showAuthorizationView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private methods
    
    private func showAuthorizationView() {
        let authorizationViewController = self.manager.oauthClient.makeAuthorizationViewController()
        authorizationViewController.completionHandler = { [weak authorizationViewController] (result) in
            self.authedResult = result
            switch result {
            case .success(let token):
                self.manager.user.token = token
                self.fetchAccountMail(withToken: token.accessToken)
            case .failure(let error):
                print("Authorization failed: \(error)")
            }
            
            authorizationViewController?.dismiss(animated: false, completion: nil)
        }
        self.present(authorizationViewController, animated: false, completion: nil)
    }
    
    private func fetchAccountMail(withToken token: String) {
        let url = Configuration.gmail.getUserURL
        let urlRequest = NSMutableURLRequest(url: url)
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest) { (data, response, error) in
            guard error == nil, data != nil else {
                self.callCompletion(with: .failure(.networkError(error! as NSError)))
                return
            }
            
            if let jsonObject = try? JSONSerialization.jsonObject(with: data!),
                let jsonInfo = jsonObject as? [String: Any] {
                let result = self.parseFetchingAccountMail(jsonInfo)
                switch result {
                case .success(let accountMail):
                    self.manager.user.email = accountMail
                    self.manager.saveUserInfo()
                    self.callCompletion(with: .success(self.manager.user))
                case .failure(let error):
                    self.callCompletion(with: .failure(error))
                }
            }
        }
        task.resume()
    }
    
    private func parseFetchingAccountMail(_ result: [String: Any]) -> Result<String, OAuthClientError> {
        if let accountMail = result["emailAddress"] as? String {
            return .success(accountMail)
        } else if let errorInfo = result["error"] as? [String: Any],
        let message = errorInfo["message"] as? String,
            let code = errorInfo["code"] as? Int {
            print("errorInfo: \(errorInfo)")
            let error = OAuthClientError(message)
            return .failure(error)
        } else {
            return .failure(.unknown)
        }
    }
    
    func callCompletion(with result: Result<User, OAuthClientError>) {
        OperationQueue.main.addOperation {
           self.completionHadler?(result)
        }
    }
}
