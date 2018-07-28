//
//  LoginController
//  BIG
//
//  Created by Jeffrey Chen on 5/21/18.
//  Copyright © 2018 Jeffrey Chen. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class LoginController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets]

    private let service = GTLRSheetsService()
    let signInButton = GIDSignInButton()
    
    let backButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        let width = self.view.frame.width
        let height = self.view.frame.height
        self.view.backgroundColor = UIColor.black

        let logo = UIImage(named: "biglogo.png")
        let logoView = UIImageView(image: logo)
        logoView.frame = CGRect(x: width*0.1, y: height*0.075, width: width*0.8, height: width*0.8*(444/1052))
        self.view.addSubview(logoView)
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
        }
        
        backButton.frame = CGRect(x: width*0.35, y: height*0.6, width: width*0.3, height: height*0.045)
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.white.cgColor
        backButton.backgroundColor = UIColor.black
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 18)
        backButton.setTitle("Back",for: .normal)
        backButton.layer.cornerRadius = 12.5
        
        backButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(self.downsizeButton(_:)), for: .touchDown)
        backButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpOutside)
        
        self.view.addSubview(backButton)

        // Add the sign-in button.
        let signInButton = GIDSignInButton(frame: CGRect(x: width*0.325, y: height*0.4, width: width*0.35, height: height*0.15))
        view.addSubview(signInButton)
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            let menuController = MenuController(nibName: nil, bundle: nil)
            self.present(menuController, animated: false, completion: nil)
        }
    }

    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func buttonClicked(_ sender: AnyObject?) {
        if sender === backButton {
            let openController = OpenController(nibName: nil, bundle: nil)
            self.present(openController, animated: true, completion: nil)
        }
    }  
    
    @objc func downsizeButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: { sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9) })
    }
    
    @objc func upsizeButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: { sender.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) })
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
}

















