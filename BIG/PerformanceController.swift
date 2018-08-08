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
    
    static var alreadyLoaded = false
    static var currentDayNAVLoaded = false
    
    var webView: IndepWKWebView?
    
    var navHTML = ""
    //static var webViewArr = [IndepWKWebView](repeating: IndepWKWebView(), count: 5)
    static var navArr = [Double](repeating: 0.0, count: 5)
    static var navDates = [String](repeating: "", count: 5)
    static let NAVLabel = UILabel()
    
    var graphDays = 5
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
            loadNAVData()
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
            
        if PerformanceController.currentDayNAVLoaded == false {
            PerformanceController.NAVLabel.frame = CGRect(x: 0.05*width, y: 0.135*height, width: width*0.9, height: height*0.14)
            PerformanceController.NAVLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 50)
            PerformanceController.NAVLabel.text = "Loading..."
            PerformanceController.NAVLabel.textColor = UIColor.white
            PerformanceController.NAVLabel.textAlignment = .center
            getCurrentNAV()
        }
        self.view.addSubview(PerformanceController.NAVLabel)
        
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
    
    func getCurrentNAV() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let dateString = formatter.string(from: Date())
        let url = "https://www.bivio.com/get-csv/berkeley/accounting/reports/valuation.csv?date=\(dateString)"
        //let a = IndependentWebView(url: url, num: -999, pfController: self)
        let a = IndepWKWebView(url: url, num: -999, pfController: self)
        self.view.addSubview(a)
    }
    
    func loadNAVData() {
        var weekEndDiff = 0
        let startDate = Date()
        var increment = Int (floor( Double(graphDays) / 52.0 ) )
        if increment < 1 {
            increment = 1
        }
        for j in 0...PerformanceController.navDates.count - 1 {
            let i = j * increment
            
            let arrIndex = PerformanceController.navDates.count - 1 - j
        
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            var date = Calendar.current.date(byAdding: .day, value: i * -1, to: startDate)!
            
            let myCalendar = Calendar(identifier: .gregorian)
            var weekDay = myCalendar.component(.weekday, from: date)
            date = Calendar.current.date(byAdding: .day, value: weekEndDiff * -1, to: date)!
            if weekDay == 1 {
                date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
                weekEndDiff += 1
            } 
            weekDay = myCalendar.component(.weekday, from: date)
            if weekDay == 7 {
                date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
                weekEndDiff += 1
            }
            let dateString = formatter.string(from: date)
            PerformanceController.navDates[arrIndex] = dateString
            print(dateString)
        
            //PerformanceController.webViewArr[arrIndex] = IndependentWebView(url: url, num: arrIndex, pfController: self)
        }
        let url = "https://www.bivio.com/get-csv/berkeley/accounting/reports/valuation.csv?date=\(PerformanceController.navDates[0])"
        webView = IndepWKWebView(url: url, num: 0, pfController: self)
        self.view.addSubview(webView!)
        print()
        
        /**PerformanceController.webViewArr[0].frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(PerformanceController.webViewArr[0])
        self.view.addSubview(monthButton)
        self.view.addSubview(yearButton)*/
    }
    
    func loadNAVVisuals() {
        /**if !PerformanceController.alreadyLoaded {
            PerformanceController.alreadyLoaded = true
            for (i, webView) in PerformanceController.webViewArr.enumerated() {
                PerformanceController.navArr[i] = webView.getPrice()
                print(PerformanceController.navArr[i])
            }
        }*/
        
        NAVGraph.removeAllSeries()
        
        let series = ChartSeries(PerformanceController.navArr)
        if (PerformanceController.navArr.last! >= PerformanceController.navArr.first!) {
            series.colors = (above: ChartColors.greenColor(), below: ChartColors.blueColor(), zeroLevel: 0)
        } else {
            series.colors = (above: ChartColors.redColor(), below: ChartColors.blueColor(), zeroLevel: 0)
        }
        series.area = true
        NAVGraph.add(series)
        
        let increment = floor( Double(PerformanceController.navDates.count) / 5.0 )
        print("INCREMENT: \(increment)")
        NAVGraph.xLabels = [0, increment, 2*increment, 3*increment, 4*increment]
        
        NAVGraph.xLabelsFormatter = xLabelsFormat
        NAVGraph.yLabelsFormatter = yLabelsFormat
        
        NAVGraph.gridColor = UIColor.white
        NAVGraph.labelColor = UIColor.white
        NAVGraph.labelFont = UIFont(name: "EBGaramond08-Regular", size: 15)
        NAVGraph.highlightLineColor = UIColor.white
    }
    
    func xLabelsFormat(i: Int, d: Double) -> String {
        var dateString = String(PerformanceController.navDates[ Int(d) ] )
        if graphDays > 30 {
            var month = dateString.prefix(2)
            if month.prefix(1) == "0" {
                month = month.suffix(1)
            }
            let year = dateString.suffix(4)
            return "\(month)/\(year)"
        }
        if dateString.prefix(1) == "0" {
            dateString = String( dateString.suffix(dateString.count - 1))
            return String( dateString.prefix(4) )
        }
        return String( dateString.prefix(5) )
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
            
            webView!.removeFromSuperview()
            PerformanceController.alreadyLoaded = false
            self.graphDays = 5
            PerformanceController.navArr = [Double](repeating: 0.0, count: 5)
            PerformanceController.navDates = [String](repeating: "", count: 5)
            loadNAVData()
        } else if sender === monthButton {
            makeButtonDark(button: weekButton)
            makeButtonLight(button: monthButton)
            makeButtonDark(button: yearButton)
            makeButtonDark(button: inceptionButton)
            
            webView!.removeFromSuperview()
            PerformanceController.alreadyLoaded = false
            self.graphDays = 25
            PerformanceController.navArr = [Double](repeating: 0.0, count: 25)
            PerformanceController.navDates = [String](repeating: "", count: 25)
            loadNAVData()
        } else if sender === yearButton {
            makeButtonDark(button: weekButton)
            makeButtonDark(button: monthButton)
            makeButtonLight(button: yearButton)
            makeButtonDark(button: inceptionButton)
            
            webView!.removeFromSuperview()
            PerformanceController.alreadyLoaded = false
            self.graphDays = 365
            PerformanceController.navArr = [Double](repeating: 0.0, count: 52)
            PerformanceController.navDates = [String](repeating: "", count: 52)
            loadNAVData()
        } else if sender === inceptionButton {
            makeButtonDark(button: weekButton)
            makeButtonDark(button: monthButton)
            makeButtonDark(button: yearButton)
            makeButtonLight(button: inceptionButton)
            
            webView!.removeFromSuperview()
            PerformanceController.alreadyLoaded = false
            self.graphDays = 365
            PerformanceController.navArr = [Double](repeating: 0.0, count: 52)
            PerformanceController.navDates = [String](repeating: "", count: 52)
            loadNAVData()
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












