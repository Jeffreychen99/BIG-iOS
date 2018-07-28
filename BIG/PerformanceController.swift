//
//  PerformanceController.swift
//  BIG
//
//  Created by Jeffrey Chen on 7/16/18.
//  Copyright © 2018 Jeffrey Chen. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class PerformanceController: UIViewController {
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    var csvPage = false
    let loadingWebView = false
    
    static var alreadyLoaded = false
    
    var navHTML = ""
    static var webViewArr = [IndependentWebView](repeating: IndependentWebView(), count: 5)
    static var navArr = [Double](repeating: 0.0, count: 5)
    static var navDates = [String](repeating: "", count: 5)
    let NAVLabel = UILabel()
    
    let NAVGraph = Chart()
    
    let weekButton = UIButton()
    let monthButton = UIButton()
    let yearButton = UIButton()
    let inceptionButton = UIButton()
    
    let backButton = UIButton()
    
    override func viewDidLoad() {
        //super.viewDidLoad()
        //GIDSignIn.sharedInstance().signOut()
        let width = self.view.frame.width
        let height = self.view.frame.height
        self.view.backgroundColor = UIColor.black
        
        if !PerformanceController.alreadyLoaded {
            let startDate = Calendar.current.date(byAdding: .day, value: PerformanceController.webViewArr.count * -1, to: Date())!
            for i in 0...PerformanceController.webViewArr.count - 1 {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                let date = Calendar.current.date(byAdding: .day, value: i, to: startDate)!
                let dateString = formatter.string(from: date)
                PerformanceController.navDates[i] = dateString
                print(dateString)
            
                let url = "https://www.bivio.com/get-csv/berkeley/accounting/reports/valuation.csv?date=\(dateString)"
                PerformanceController.webViewArr[i] = IndependentWebView(url: url, num: i)
            }
        }
        
        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 0.1*width, y: 0.05*height, width: width*0.8, height: height*0.075)
        headerLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 30)
        headerLabel.text = "NAV (price per share):"
        headerLabel.textColor = UIColor.white
        headerLabel.textAlignment = .center
        self.view.addSubview(headerLabel)
        
        let divider = UILabel()
        divider.frame = CGRect(x: 0.05*width, y: 0.13*height, width: width*0.9, height: 2)
        divider.backgroundColor = UIColor.white
        self.view.addSubview(divider)
            
        NAVLabel.frame = CGRect(x: 0.05*width, y: 0.135*height, width: width*0.9, height: height*0.14)
        NAVLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 75)
        NAVLabel.text = "$00.00"
        NAVLabel.textColor = UIColor.white
        NAVLabel.textAlignment = .center
        
        NAVGraph.frame = CGRect(x: width*0.05, y: height*0.3, width: width*0.9, height: height*0.35)
        NAVGraph.layer.borderColor = UIColor.white.cgColor
        NAVGraph.layer.borderWidth = 2
        self.view.addSubview(NAVGraph)
        
        weekButton.frame = CGRect(x: width*0.05, y: height*0.675, width: width*0.18, height: height*0.05)
        weekButton.setTitle("1w", for: .normal)
        setupButton(button: weekButton)
        
        monthButton.frame = CGRect(x: width*0.29, y: height*0.675, width: width*0.18, height: height*0.05)
        monthButton.setTitle("1m", for: .normal)
        setupButton(button: monthButton)
        
        yearButton.frame = CGRect(x: width*0.53, y: height*0.675, width: width*0.18, height: height*0.05)
        yearButton.setTitle("1y", for: .normal)
        setupButton(button: yearButton)
        
        inceptionButton.frame = CGRect(x: width*0.77, y: height*0.675, width: width*0.18, height: height*0.05)
        inceptionButton.setTitle("All", for: .normal)
        setupButton(button: inceptionButton)
        
        backButton.frame = CGRect(x: width*0.3, y: height*0.85, width: width*0.4, height: height*0.045)
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
        
        makeButtonLight(button: weekButton)
        makeButtonDark(button: monthButton)
        makeButtonDark(button: yearButton)
        makeButtonDark(button: inceptionButton)
    }
    
    func loadNAVVisuals() {
        super.viewDidLoad()
        
        if !PerformanceController.alreadyLoaded {
            PerformanceController.alreadyLoaded = true
            for (i, webView) in PerformanceController.webViewArr.enumerated() {
                PerformanceController.navArr[i] = webView.getPrice()
                print(PerformanceController.navArr[i])
            }
        }
        NAVLabel.text = "$\(String(format: "%.2f", PerformanceController.navArr.last!))"
        self.view.addSubview(NAVLabel)
        
        let series = ChartSeries(PerformanceController.navArr)
        if (PerformanceController.navArr.last! >= PerformanceController.navArr.first!) {
            series.colors = (above: ChartColors.greenColor(), below: ChartColors.blueColor(), zeroLevel: 0)
        } else {
            series.colors = (above: ChartColors.redColor(), below: ChartColors.blueColor(), zeroLevel: 0)
        }
        series.area = true
        NAVGraph.add(series)
        NAVGraph.xLabelsFormatter = xLabelsFormat
        NAVGraph.yLabelsFormatter = yLabelsFormat
        
        NAVGraph.gridColor = UIColor.white
        NAVGraph.labelColor = UIColor.white
        NAVGraph.labelFont = UIFont(name: "EBGaramond08-Regular", size: 15)
        NAVGraph.highlightLineColor = UIColor.white
    }
    
    func xLabelsFormat(i: Int, d: Double) -> String {
        return String(PerformanceController.navDates[i].prefix(5))
    }
    
    func yLabelsFormat(i: Int, d: Double) -> String {
        return "\(String(format: "%.2f", d))"
    }
    
    func setupButton(button: UIButton) {
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = UIColor.black
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 20)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(self.downsizeButton(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpOutside)
        self.view.addSubview(button)
    }
    
    func makeButtonDark(button: UIButton) {
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = UIColor.black
        button.setTitleColor(UIColor.white, for: .normal)
        
        let attributes: [NSAttributedStringKey: Any]? = nil
        let attributedText = NSAttributedString(string: button.currentTitle!, attributes: attributes)
        button.titleLabel?.attributedText = attributedText
    }
    
    func makeButtonLight(button: UIButton) {
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor.black, for: .normal)
        
        let attributes = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
        let attributedText = NSAttributedString(string: button.currentTitle!, attributes: attributes)
        button.titleLabel?.attributedText = attributedText
    }
    
    @objc func buttonClicked(_ sender: AnyObject?) {
        if sender === backButton {
            let openController = OpenController(nibName: nil, bundle: nil)
            self.present(openController, animated: true, completion: nil)
        } else if sender === weekButton {
            makeButtonLight(button: weekButton)
            makeButtonDark(button: monthButton)
            makeButtonDark(button: yearButton)
            makeButtonDark(button: inceptionButton)
            
            PerformanceController.alreadyLoaded = false
            PerformanceController.webViewArr = [IndependentWebView](repeating: IndependentWebView(), count: 5)
            PerformanceController.navArr = [Double](repeating: 0.0, count: 5)
            PerformanceController.navDates = [String](repeating: "", count: 5)
            viewDidLoad()
            loadNAVVisuals()
        } else if sender === monthButton {
            makeButtonDark(button: weekButton)
            makeButtonLight(button: monthButton)
            makeButtonDark(button: yearButton)
            makeButtonDark(button: inceptionButton)
            
            PerformanceController.alreadyLoaded = false
            PerformanceController.webViewArr = [IndependentWebView](repeating: IndependentWebView(), count: 5)
            PerformanceController.navArr = [Double](repeating: 0.0, count: 20)
            PerformanceController.navDates = [String](repeating: "", count: 20)
            viewDidLoad()
            loadNAVVisuals()
        } else if sender === yearButton {
            makeButtonDark(button: weekButton)
            makeButtonDark(button: monthButton)
            makeButtonLight(button: yearButton)
            makeButtonDark(button: inceptionButton)
            
            PerformanceController.alreadyLoaded = false
            PerformanceController.webViewArr = [IndependentWebView](repeating: IndependentWebView(), count: 5)
            PerformanceController.navArr = [Double](repeating: 0.0, count: 240)
            PerformanceController.navDates = [String](repeating: "", count: 240)
            viewDidLoad()
            loadNAVVisuals()
        } else if sender === inceptionButton {
            makeButtonDark(button: weekButton)
            makeButtonDark(button: monthButton)
            makeButtonDark(button: yearButton)
            makeButtonLight(button: inceptionButton)
            
            PerformanceController.alreadyLoaded = false
            PerformanceController.webViewArr = [IndependentWebView](repeating: IndependentWebView(), count: 5)
            PerformanceController.navArr = [Double](repeating: 0.0, count: 5)
            PerformanceController.navDates = [String](repeating: "", count: 5)
            viewDidLoad()
            loadNAVVisuals()
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












