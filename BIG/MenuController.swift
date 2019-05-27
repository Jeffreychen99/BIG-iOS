//
//  MenuController.swift
//  BIG
//
//  Created by Jeffrey Chen on 5/30/18.
//  Copyright © 2018 Jeffrey Chen. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class MenuController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets]
    private let service = GTLRSheetsService()
    
    var portfolioButton = UIButton()
    var votingButton = UIButton()
    var ideasButton = UIButton()
    var backButton = UIButton()
    var logoutButton = UIButton()
    
    let portfolioController = PortfolioController()
    
    let nameLabel = UILabel()
    var namePicker = UIPickerView()
    var nameValues = [String]()
    var nameRow = NSInteger(0)
    var name = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        
        //self.portfolioController.viewDidLoad()

        let width = self.view.frame.width
        let height = self.view.frame.height
        self.view.backgroundColor = UIColor.black

        let logo = UIImage(named: "biglogo.png")
        let logoView = UIImageView(image: logo)
        logoView.frame = CGRect(x: width*0.1, y: height*0.075, width: width*0.8, height: width*0.8*(444/1052))
        self.view.addSubview(logoView)
        
        portfolioButton = UIButton(frame: CGRect(x: width*0.2, y: height*0.5, width: width*0.6, height: height*0.075))
        votingButton = UIButton(frame: CGRect(x: width*0.2, y: height*0.605, width: width*0.6, height: height*0.075))
        ideasButton = UIButton(frame: CGRect(x: width*0.2, y: height*0.71, width: width*0.6, height: height*0.075))
        
        portfolioButton.layer.borderWidth = 2
        portfolioButton.layer.borderColor = UIColor.white.cgColor
        portfolioButton.backgroundColor = UIColor.black
        portfolioButton.setTitleColor(UIColor.white, for: .normal)
        portfolioButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
        portfolioButton.setTitle("Portfolio",for: .normal)
        
        votingButton.layer.borderWidth = 2
        votingButton.layer.borderColor = UIColor.white.cgColor
        votingButton.backgroundColor = UIColor.black
        votingButton.setTitleColor(UIColor.white, for: .normal)
        votingButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
        votingButton.setTitle("Voting",for: .normal)
        
        ideasButton.layer.borderWidth = 2
        ideasButton.layer.borderColor = UIColor.white.cgColor
        ideasButton.backgroundColor = UIColor.black
        ideasButton.setTitleColor(UIColor.white, for: .normal)
        ideasButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
        ideasButton.setTitle("Ideas",for: .normal)
        
        portfolioButton.layer.cornerRadius = 25
        votingButton.layer.cornerRadius = 25
        ideasButton.layer.cornerRadius = 25
        
        backButton = UIButton(frame: CGRect(x: width*0.3, y: height*0.85, width: width*0.4, height: height*0.045))
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.white.cgColor
        backButton.backgroundColor = UIColor.black
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 18)
        backButton.setTitle("Back",for: .normal)
        backButton.layer.cornerRadius = 12.5
        
        logoutButton = UIButton(frame: CGRect(x: width*0.3, y: height*0.91, width: width*0.4, height: height*0.045))
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = UIColor.white.cgColor
        logoutButton.backgroundColor = UIColor.black
        logoutButton.setTitleColor(UIColor.white, for: .normal)
        logoutButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 18)
        logoutButton.setTitle("Logout",for: .normal)
        logoutButton.layer.cornerRadius = 12.5
        
        portfolioButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        portfolioButton.addTarget(self, action: #selector(self.downsizeButton(_:)), for: .touchDown)
        portfolioButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpInside)
        portfolioButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpOutside)
        
        votingButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        votingButton.addTarget(self, action: #selector(self.downsizeButton(_:)), for: .touchDown)
        votingButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpInside)
        votingButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpOutside)
        
        ideasButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        ideasButton.addTarget(self, action: #selector(self.downsizeButton(_:)), for: .touchDown)
        ideasButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpInside)
        ideasButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpOutside)
        
        backButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(self.downsizeButton(_:)), for: .touchDown)
        backButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpOutside)
        
        logoutButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(self.downsizeButton(_:)), for: .touchDown)
        logoutButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpOutside)
        
        nameLabel.text = "Name:"
        nameLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
        nameLabel.textColor = UIColor.white
        nameLabel.frame = CGRect(x: 0.175*width, y: 0.35*height, width: width*0.2, height: height*0.075)
        nameLabel.layer.borderColor = UIColor.white.cgColor
        nameLabel.isHidden = false
        
        namePicker.frame = CGRect(x: 0.375*width, y: 0.2875*height, width: 0.5*width, height: height*0.2)
        namePicker.backgroundColor = UIColor.black
        
        portfolioButton.isHidden = false
        votingButton.isHidden = false
        ideasButton.isHidden = false
        logoutButton.isHidden = false
        
        self.view.addSubview(portfolioButton)
        self.view.addSubview(votingButton)
        self.view.addSubview(ideasButton)
        self.view.addSubview(backButton)
        self.view.addSubview(logoutButton)
        
        self.view.addSubview(nameLabel)
        getData()
    }
    
    func numberOfComponents(in namePicker: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return nameValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return nameValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = nameValues[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "EBGaramond08-Regular", size: 15)!,NSAttributedStringKey.foregroundColor:UIColor.white])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let userDefaults = UserDefaults.standard
        nameRow = row
        userDefaults.setValue(row, forKey: "nameRow")
        userDefaults.set(nameValues[row], forKey: "name")
    }

    func getData() {
        let spreadsheetId = "1uFzXgwJmmsAqTrkEC1mil7fAvieLgU82TAlWMDmN8wo" // Voting
        let range = "Vote Calc - Summer '19!B6:C"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query, delegate: self, didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }

    // Process the response and display output
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket, finishedWithObject result : GTLRSheets_ValueRange, error : NSError?) {

        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        let data = result.values!        
        if data.isEmpty {
            print("no data found")
            return
        }
        for row in data {
            if (row[0] as! String) == "Average" {
                break
            }
            nameValues.append(row[0] as! String)
        }
        
        nameValues.sort()
        
        self.namePicker.dataSource = self
        self.namePicker.delegate = self   
        self.view.addSubview(namePicker)
        
        
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: "nameRow") != nil && userDefaults.object(forKey: "name") != nil {
            nameRow = userDefaults.value(forKey: "nameRow") as! NSInteger!
            //userDefaults.setValue(0, forKey: "nameRow")
            //nameRow = 0
            name = userDefaults.object(forKey: "name") as! String!
            namePicker.selectRow(nameRow, inComponent: 0, animated: true)
        } else {
            nameRow = 0
            name = nameValues[0]
            namePicker.selectRow(nameRow, inComponent: 0, animated: true)
        }
        print("nameRow is:   \(nameRow)")
        print("name is:   \(nameValues[nameRow])")
        
        userDefaults.setValue(nameRow, forKey: "nameRow")
        //userDefaults.set(nameValues[nameRow], forKey: "name")
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
        if sender === portfolioButton {
            //let portfolioController = PortfolioController(nibName: nil, bundle: nil)
            self.present(portfolioController, animated: true, completion: nil)
        }
        if sender === votingButton {
            let voteController = VoteController(nibName: nil, bundle: nil)
            self.present(voteController, animated: true, completion: nil)
        }
        if sender === ideasButton {
            let ideasController = IdeasController(nibName: nil, bundle: nil)
            self.present(ideasController, animated: true, completion: nil)
        } 
        if sender === backButton {
            let openController = OpenController(nibName: nil, bundle: nil)
            self.present(openController, animated: true, completion: nil)
        }
        if sender === logoutButton {
            let alert = UIAlertController(title: "Are you sure you want to logout?", message: "You can always log back in", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { action in
                switch action.style{
                
                case .default:
                    GIDSignIn.sharedInstance().signOut()
                    let loginController = LoginController()
                    self.present(loginController, animated: true, completion: nil)
                
                case .cancel:
                    print("cancel")
                
                case .destructive:
                    print("destructive")
                }
            }))
            self.present(alert, animated: true, completion: nil)
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
        //return UIStatusBarStyle.default   // Make dark again
    }
    
}
















