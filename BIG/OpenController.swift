//
//  OpenController.swift
//  BIG
//
//  Created by Jeffrey Chen on 5/21/18.
//  Copyright © 2018 Jeffrey Chen. All rights reserved.
//

import UIKit
import WebKit

class OpenController: UIViewController {
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    
    let officerButton = UIButton()
    let infoButton = UIButton()
    
    let performanceController = PerformanceController()

    override func viewDidLoad() {
        super.viewDidLoad()
        //GIDSignIn.sharedInstance().signOut()

        let width = self.view.frame.width
        let height = self.view.frame.height
        self.view.backgroundColor = UIColor.black

        let logo = UIImage(named: "biglogo.png")
        let logoView = UIImageView(image: logo)
        logoView.frame = CGRect(x: width*0.1, y: height*0.075, width: width*0.8, height: height*0.2)
        self.view.addSubview(logoView)
        
        infoButton.frame = CGRect(x: width*0.15, y: height*0.425, width: width*0.7, height: height*0.075)
        infoButton.setTitle("Fund Performance",for: .normal)
        setupButton(button: infoButton)
        self.view.addSubview(infoButton)
        
        officerButton.frame = CGRect(x: width*0.15, y: height*0.55, width: width*0.7, height: height*0.075)
        officerButton.setTitle("Officer Portal",for: .normal)
        setupButton(button: officerButton)
        self.view.addSubview(officerButton)
        
        if PerformanceController.alreadyLoaded == false {
            performanceController.viewDidLoad()
        }
    }
    
    func setupButton(button: UIButton) {
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = UIColor.black
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(self.downsizeButton(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpOutside)
    }
    
    @objc func buttonClicked(_ sender: AnyObject?) {
        if sender === officerButton {
            let loginController = LoginController()
            self.present(loginController, animated: true, completion: nil)
            loginController.viewDidLoad()
        } else if sender === infoButton {
            //let performanceController = PerformanceController()
            //performanceController.loadNAVVisuals()
            self.present(performanceController, animated: true, completion: nil)
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

















