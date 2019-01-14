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
    
    var webViewNAV: NAVWebView?
    var webViewSP: SPWebView?
    var webViewACWI: ACWIWebView?
    
    static var NAVloaded = false
    static var SPloaded = false
    static var ACWIloaded = false
    
    let activityIndicator = UIActivityIndicatorView()
    
    static var navArr = [Double](repeating: 0.0, count: 5)
    static var spArr = [Double](repeating: 0.0, count: 5)
    static var acwiArr = [Double](repeating: 0.0, count: 5)
    
    static var dates = [String](repeating: "", count: 5)
    static let NAVLabel = UILabel()
    
    var graphDays = 5
    let NAVGraph = Chart()
    
    let loadingIndicator = UIActivityIndicatorView()
    
    let weekButton = UIButton()
    let monthButton = UIButton()
    let oneYearButton = UIButton()
    let threeYearButton = UIButton()
    let fiveYearButton = UIButton()
    
    let navButton = UIButton()
    var showNAV = true
    let spButton = UIButton()
    var showSP = false
    let acwiButton = UIButton()
    var showACWI = false
    
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
        
        loadNAVVisuals()
            
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
        
        weekButton.frame = CGRect(x: width*0.05, y: height*0.675, width: width*0.14, height: height*0.05)
        weekButton.setTitle("1w", for: .normal)
        setupButton(button: weekButton)
        
        monthButton.frame = CGRect(x: width*0.24, y: height*0.675, width: width*0.14, height: height*0.05)
        monthButton.setTitle("1m", for: .normal)
        setupButton(button: monthButton)
        
        oneYearButton.frame = CGRect(x: width*0.43, y: height*0.675, width: width*0.14, height: height*0.05)
        oneYearButton.setTitle("1y", for: .normal)
        setupButton(button: oneYearButton)
        
        threeYearButton.frame = CGRect(x: width*0.62, y: height*0.675, width: width*0.14, height: height*0.05)
        threeYearButton.setTitle("3y", for: .normal)
        setupButton(button: threeYearButton)
        
        fiveYearButton.frame = CGRect(x: width*0.81, y: height*0.675, width: width*0.14, height: height*0.05)
        fiveYearButton.setTitle("5y", for: .normal)
        setupButton(button: fiveYearButton)
        
        
        navButton.frame = CGRect(x: width*0.05, y: height*0.75, width: width*0.27, height: height*0.05)
        navButton.setTitle("NAV", for: .normal)
        setupButton(button: navButton)
        
        spButton.frame = CGRect(x: width*0.365, y: height*0.75, width: width*0.27, height: height*0.05)
        spButton.setTitle("S&P 500", for: .normal)
        setupButton(button: spButton)
        
        acwiButton.frame = CGRect(x: width*0.68, y: height*0.75, width: width*0.27, height: height*0.05)
        acwiButton.setTitle("ACWI", for: .normal)
        setupButton(button: acwiButton)
        
        activityIndicator.frame = CGRect(x: width*0.3, y: height*0.825, width: width*0.4, height: height*0.05)
        if !PerformanceController.NAVloaded && !PerformanceController.SPloaded && !PerformanceController.ACWIloaded {
            activityIndicator.startAnimating()
            activityIndicator.hidesWhenStopped = true
            self.view.addSubview(activityIndicator)
        }
        
        backButton.frame = CGRect(x: width*0.3, y: height*0.905, width: width*0.4, height: height*0.045)
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
        makeButtonDark(button: oneYearButton)
        makeButtonDark(button: threeYearButton)
        makeButtonDark(button: fiveYearButton)
        
        makeButtonLight(button: navButton)
        webViewACWI = ACWIWebView(pfController: self)
        webViewSP = SPWebView(pfController: self)
    }
    
    func getCurrentNAV() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let dateString = formatter.string(from: Date())
        let url = "https://www.bivio.com/get-csv/berkeley/accounting/reports/valuation.csv?date=\(dateString)"
        //let a = IndependentWebView(url: url, num: -999, pfController: self)
        let a = NAVWebView(url: url, num: -999, pfController: self)
        self.view.addSubview(a)
    }
    
    func loadNAVData() {
        var weekEndDiff = 0
        let startDate = Date()
        //startDate = Calendar.current.date(byAdding: .day, value: -1, to: startDate)!
        var increment = Int (floor( Double(graphDays) / Double(PerformanceController.navArr.count) ) )
        if increment < 1 {
            increment = 1
        }
        for j in 0...PerformanceController.dates.count - 1 {
            let i = j * increment
            
            let arrIndex = PerformanceController.dates.count - 1 - j
        
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            var date = Calendar.current.date(byAdding: .day, value: i * -1, to: startDate)!
            
            let myCalendar = Calendar(identifier: .gregorian)
            date = Calendar.current.date(byAdding: .day, value: weekEndDiff * -1, to: date)!
            var weekDay = myCalendar.component(.weekday, from: date)
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
            PerformanceController.dates[arrIndex] = dateString
            print("\(dateString)    \(myCalendar.component(.weekday, from: date))")
        
            //PerformanceController.webViewArr[arrIndex] = IndependentWebView(url: url, num: arrIndex, pfController: self)
        }
        let url = "https://www.bivio.com/get-csv/berkeley/accounting/reports/valuation.csv?date=\(PerformanceController.dates[0])"
        webViewNAV = NAVWebView(url: url, num: 0, pfController: self)
        self.view.addSubview(webViewNAV!)
        print()
    }
    
    func loadNAVVisuals() {
        if !PerformanceController.NAVloaded { print("NOT ALL NAV") }
        if !PerformanceController.SPloaded { print("NOT ALL SP") }
        if !PerformanceController.ACWIloaded { print("NOT ALL ACWI") }
        
        if PerformanceController.NAVloaded && PerformanceController.SPloaded && PerformanceController.ACWIloaded {
            activityIndicator.stopAnimating()
        }
    
        NAVGraph.removeAllSeries()
        let moreThanOne = (showNAV && showSP) || (showNAV && showACWI) || (showSP && showACWI)
        
        if showNAV && PerformanceController.NAVloaded {
            var NAVSeries = ChartSeries(PerformanceController.navArr)
            if moreThanOne {
                var percentNAVArr = [Double]()
                for i in PerformanceController.navArr {
                    percentNAVArr.append( i / PerformanceController.navArr.max()!)
                }
                NAVSeries = ChartSeries(percentNAVArr)
            }
            if (PerformanceController.navArr.last! >= PerformanceController.navArr.first!) {
                NAVSeries.colors = (above: ChartColors.greenColor(), below: ChartColors.greenColor(), zeroLevel: 0)
            } else {
                NAVSeries.colors = (above: ChartColors.darkRedColor(), below: ChartColors.darkRedColor(), zeroLevel: 0)
            }   
            NAVSeries.area = true
            NAVGraph.add(NAVSeries)
        }
        
        if showSP && PerformanceController.SPloaded {
            var SPSeries = ChartSeries(PerformanceController.spArr)
            if moreThanOne {
                var percentSP = [Double]()
                for i in PerformanceController.spArr {
                    percentSP.append( i / PerformanceController.spArr.max()!)
                }
                SPSeries = ChartSeries(percentSP)
            }
            SPSeries.colors = (above: ChartColors.cyanColor(), below: ChartColors.cyanColor(), zeroLevel: 0)
            SPSeries.area = true
            NAVGraph.add(SPSeries)
        }
        
       if showACWI && PerformanceController.ACWIloaded {
            var ACWISeries = ChartSeries(PerformanceController.acwiArr)
            if moreThanOne {
                var percentACWI = [Double]()
                for i in PerformanceController.acwiArr {
                    percentACWI.append( i / PerformanceController.acwiArr.max()!)
                }
                ACWISeries = ChartSeries(percentACWI)
            }
            ACWISeries.colors = (above: ChartColors.pinkColor(), below: ChartColors.pinkColor(), zeroLevel: 0)
            ACWISeries.area = true
            NAVGraph.add(ACWISeries)
        }
        
        let increment = floor( Double(PerformanceController.dates.count) / 5.0 )
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
        var dateString = String(PerformanceController.dates[ Int(d) ] )
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
        if (showNAV && showSP) || (showNAV && showACWI) || (showSP && showACWI) { return "" }
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
            makeButtonDark(button: oneYearButton)
            makeButtonDark(button: threeYearButton)
            makeButtonDark(button: fiveYearButton)
            
            webViewNAV!.removeFromSuperview()
            PerformanceController.alreadyLoaded = false
            PerformanceController.NAVloaded = false
            PerformanceController.SPloaded = false
            PerformanceController.ACWIloaded = false
            self.graphDays = 5
            PerformanceController.dates = [String](repeating: "", count: 5)
            PerformanceController.navArr = [Double](repeating: 0.0, count: 5)
            PerformanceController.spArr = [Double](repeating: 0.0, count: 5)
            PerformanceController.acwiArr = [Double](repeating: 0.0, count: 5)
            webViewSP?.load(URLRequest(url: URL(string: "https://quotes.wsj.com/index/SPX/historical-prices")!))
            webViewACWI?.load(URLRequest(url: URL(string: "https://www.nasdaq.com/symbol/acwi/historical")!))
            loadNAVData()
            activityIndicator.startAnimating()
        } else if sender === monthButton {
            makeButtonDark(button: weekButton)
            makeButtonLight(button: monthButton)
            makeButtonDark(button: oneYearButton)
            makeButtonDark(button: threeYearButton)
            makeButtonDark(button: fiveYearButton)
             
            webViewNAV!.removeFromSuperview()
            PerformanceController.alreadyLoaded = false
            PerformanceController.NAVloaded = false
            PerformanceController.SPloaded = false
            PerformanceController.ACWIloaded = false
            self.graphDays = 20
            PerformanceController.dates = [String](repeating: "", count: 20)
            PerformanceController.navArr = [Double](repeating: 0.0, count: 20)
            PerformanceController.spArr = [Double](repeating: 0.0, count: 20)
            PerformanceController.acwiArr = [Double](repeating: 0.0, count: 20)
            webViewSP?.load(URLRequest(url: URL(string: "https://quotes.wsj.com/index/SPX/historical-prices")!))
            webViewACWI?.load(URLRequest(url: URL(string: "https://www.nasdaq.com/symbol/acwi/historical")!))
            loadNAVData()
            activityIndicator.startAnimating()
        } else if sender === oneYearButton {
            makeButtonDark(button: weekButton)
            makeButtonDark(button: monthButton)
            makeButtonLight(button: oneYearButton)
            makeButtonDark(button: threeYearButton)
            makeButtonDark(button: fiveYearButton)
            
            webViewNAV!.removeFromSuperview()
            PerformanceController.alreadyLoaded = false
            PerformanceController.NAVloaded = false
            PerformanceController.SPloaded = false
            PerformanceController.ACWIloaded = false
            self.graphDays = 365
            PerformanceController.dates = [String](repeating: "", count: 52)
            PerformanceController.navArr = [Double](repeating: 0.0, count: 52)
            PerformanceController.spArr = [Double](repeating: 0.0, count: 52)
            PerformanceController.acwiArr = [Double](repeating: 0.0, count: 52)
            webViewSP?.load(URLRequest(url: URL(string: "https://quotes.wsj.com/index/SPX/historical-prices")!))
            webViewACWI?.load(URLRequest(url: URL(string: "https://www.nasdaq.com/symbol/acwi/historical")!))
            loadNAVData()
            activityIndicator.startAnimating()
        } else if sender === threeYearButton {
            makeButtonDark(button: weekButton)
            makeButtonDark(button: monthButton)
            makeButtonDark(button: oneYearButton)
            makeButtonLight(button: threeYearButton)
            makeButtonDark(button: fiveYearButton)
            
            webViewNAV!.removeFromSuperview()
            PerformanceController.alreadyLoaded = false
            PerformanceController.NAVloaded = false
            PerformanceController.SPloaded = false
            PerformanceController.ACWIloaded = false
            self.graphDays = 1095
            PerformanceController.dates = [String](repeating: "", count: 60)
            PerformanceController.navArr = [Double](repeating: 0.0, count: 60)
            PerformanceController.spArr = [Double](repeating: 0.0, count: 60)
            PerformanceController.acwiArr = [Double](repeating: 0.0, count: 60)
            webViewSP?.load(URLRequest(url: URL(string: "https://quotes.wsj.com/index/SPX/historical-prices")!))
            webViewACWI?.load(URLRequest(url: URL(string: "https://www.nasdaq.com/symbol/acwi/historical")!))
            loadNAVData()
            activityIndicator.startAnimating()
        } else if sender === fiveYearButton {
            makeButtonDark(button: weekButton)
            makeButtonDark(button: monthButton)
            makeButtonDark(button: oneYearButton)
            makeButtonDark(button: threeYearButton)
            makeButtonLight(button: fiveYearButton)
            
            webViewNAV!.removeFromSuperview()
            PerformanceController.alreadyLoaded = false
            PerformanceController.NAVloaded = false
            PerformanceController.SPloaded = false
            PerformanceController.ACWIloaded = false
            self.graphDays = 1825
            PerformanceController.dates = [String](repeating: "", count: 60)
            PerformanceController.navArr = [Double](repeating: 0.0, count: 60)
            PerformanceController.spArr = [Double](repeating: 0.0, count: 60)
            PerformanceController.acwiArr = [Double](repeating: 0.0, count: 60)
            webViewSP?.load(URLRequest(url: URL(string: "https://quotes.wsj.com/index/SPX/historical-prices")!))
            webViewACWI?.load(URLRequest(url: URL(string: "https://www.nasdaq.com/symbol/acwi/historical")!))
            loadNAVData()
            activityIndicator.startAnimating()
        } else if sender === navButton {
            makeButtonLight(button: navButton)
            if showNAV {
                makeButtonDark(button: navButton)
            }
            showNAV = !showNAV
            loadNAVVisuals()
        } else if sender === spButton {
            makeButtonLight(button: spButton)
            if showSP {
                makeButtonDark(button: spButton)
            }
            showSP = !showSP
            loadNAVVisuals()
        } else if sender === acwiButton {
            makeButtonLight(button: acwiButton)
            if showACWI {
                makeButtonDark(button: acwiButton)
            } 
            showACWI = !showACWI
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












