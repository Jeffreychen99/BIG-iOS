//
//  PortfolioController.swift
//  BIG
//
//  Created by Jeffrey Chen on 5/21/18.
//  Copyright © 2018 Jeffrey Chen. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import Foundation

import Alamofire
import SwiftyJSON

class PortfolioController: UIViewController {
    
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets]
    private let service = GTLRSheetsService()

    var loginParent: LoginController? = nil
    var portfolioData = Array<Array<Any>>()
    
    let longButton = UIButton()
    let shortButton = UIButton()
    let backButton = UIButton()
    
    var showLongs = true

    let scrollView = UIScrollView()
    
    let totalCashLabel = UILabel()
    let totalAUMLabel = UILabel()
    let dailyGainLabel = UILabel()
    let totalGainLabel = UILabel()
    
    var totalCash = ""
    var totalAssets = ""
    var dailyAUMGain = ""
    var totalAUMGain = ""
    
    var totalDailyChangePct = 0.0
    var completeData = [[Any]]()
    
    let green = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
    let red = UIColor(red: 0.8, green: 0, blue: 0, alpha: 1)
    
    var longList = [[Any]]()
    var shortList = [[Any]]()
    
    var scrollItemList = [[UILabel]]()
    var tickerList = [[UIButton]]()
    
    let loadingLabel = UILabel()
    let loadingIndicator = UIActivityIndicatorView()
    
    var updater = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        self.view.backgroundColor = UIColor.black
        
        longButton.frame = CGRect(x: 0.3*width, y: 0.05*height, width: width*0.25, height: height*0.06)
        longButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 20)
        longButton.setTitle("Longs",for: .normal)
        makeButtonLight(button: longButton)
        longButton.layer.borderWidth = 2
        longButton.layer.cornerRadius = 15
        longButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        longButton.addTarget(self, action: #selector(self.downsizeButton(_:)), for: .touchDown)
        longButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpInside)
        longButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpOutside)
        view.addSubview(longButton)
        
        shortButton.frame = CGRect(x: 0.625*width, y: 0.05*height, width: width*0.25, height: height*0.06)
        shortButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 20)
        shortButton.setTitle("Shorts",for: .normal)
        makeButtonDark(button: shortButton)
        shortButton.layer.borderWidth = 2
        shortButton.layer.cornerRadius = 15
        shortButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        shortButton.addTarget(self, action: #selector(self.downsizeButton(_:)), for: .touchDown)
        shortButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpInside)
        shortButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpOutside)
        view.addSubview(shortButton)
        
        let backBlue = UIColor(red: CGFloat(0), green: CGFloat(0.5), blue: CGFloat(1), alpha: 1.0)
        
        let backArrow = UIButton()
        backArrow.frame = CGRect(x: 0.05*width, y: 0.0475*height, width: width*0.05, height: height*0.07)
        backArrow.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 50)
        backArrow.backgroundColor = UIColor.black
        backArrow.setTitleColor(backBlue, for: .normal)
        backArrow.setTitle("<",for: .normal)
        backArrow.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        view.addSubview(backArrow)

        backButton.frame = CGRect(x: 0.091*width, y: 0.0525*height, width: width*0.14, height: height*0.06)
        backButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 22.5)
        backButton.backgroundColor = UIColor.black
        backButton.setTitleColor(backBlue, for: .normal)
        backButton.setTitle("Back",for: .normal)
        backButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        view.addSubview(backButton)
        
        let headerLine = UILabel()
        headerLine.frame = CGRect(x: 0.03*width, y: 0.125*height, width: width*0.94, height: 3)
        headerLine.backgroundColor = UIColor.white
        view.addSubview(headerLine)
        
        loadingLabel.frame = CGRect(x: 0.03*width, y: 0.2*height, width: width*0.95, height: height*0.1)
        loadingLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 50)
        loadingLabel.textColor = UIColor.white
        loadingLabel.text = "Loading..."
        loadingLabel.textAlignment = .center
        self.view.addSubview(loadingLabel)
        
        loadingIndicator.frame = CGRect(x: 0.3*width, y: 0.3*height, width: width*0.4, height: height*0.1)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        self.view.addSubview(loadingIndicator)
        
        let footerLine = UILabel()
        footerLine.frame = CGRect(x: 0.03*width, y: 0.8*height, width: width*0.94, height: 3)
        footerLine.backgroundColor = UIColor.white
        view.addSubview(footerLine)
        
        totalCashLabel.frame = CGRect(x: 0.05*width, y: 0.8*height+18, width: 0.6*width, height: 0.07*height)
        totalCashLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 30)
        totalCashLabel.textColor = UIColor.white
        view.addSubview(totalCashLabel)
        
        totalAUMLabel.frame = CGRect(x: 0.05*width, y: 0.88*height+18, width: 0.6*width, height: 0.07*height)
        totalAUMLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 30)
        totalAUMLabel.textColor = UIColor.white
        view.addSubview(totalAUMLabel)
        
        dailyGainLabel.frame = CGRect(x: 0.65*width, y: 0.8*height+18, width: 0.3*width, height: 0.07*height)
        dailyGainLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 35)
        dailyGainLabel.backgroundColor = green
        dailyGainLabel.textColor = UIColor.white
        dailyGainLabel.layer.cornerRadius = 5
        dailyGainLabel.clipsToBounds = true
        dailyGainLabel.textAlignment = .center
        view.addSubview(dailyGainLabel)
        
        totalGainLabel.frame = CGRect(x: 0.65*width, y: 0.88*height+18, width: 0.3*width, height: 0.07*height)
        totalGainLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 35)
        totalGainLabel.backgroundColor = green
        totalGainLabel.textColor = UIColor.white
        totalGainLabel.layer.cornerRadius = 5
        totalGainLabel.clipsToBounds = true
        totalGainLabel.textAlignment = .center
        view.addSubview(totalGainLabel)
        
        scrollView.frame = CGRect(x: 0, y: 0.125*height+13, width: width, height: 0.675*height-23)
        
        getData()
        if checkDuringTradingHours() {
            updater = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
        }
    }
    
    func presentList(list: [[Any]]) {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        var tempItems = [[UILabel]]()
        var tempTickers = [[UIButton]]()
        
        removeListFromView()
        
        if list.count < 1 {
            return
        }
    
        scrollView.contentSize = CGSize(width: width*0.94, height: (height*0.11+21)*CGFloat(list.count) - 21)
        for i in 0...list.count-1 {
            tempItems.append([UILabel]())
            tempTickers.append([UIButton]())
        
            let ticker = UIButton()
            ticker.frame = CGRect(x: 0.03*width, y: (height*0.11+21)*CGFloat(i), width: 0.23*width, height: height*0.11)
            ticker.setTitle((list[i][0] as! String),for: .normal)
            ticker.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 30)
            ticker.backgroundColor = UIColor.black
            ticker.setTitleColor(UIColor.white, for: .normal)
            tempTickers[i].append(ticker)
            scrollView.addSubview(ticker)
            
            let price = UILabel()
            price.frame = CGRect(x: 0.25*width, y: (height*0.11+21)*CGFloat(i), width: 0.35*width, height: height*0.05)
            price.text = "\(list[i][3] as! String)"
            price.font =  UIFont(name: "EBGaramond08-Regular", size: 22)
            price.backgroundColor = UIColor.black
            price.textColor = UIColor.white
            price.textAlignment = .center
            tempItems[i].append(price)
            scrollView.addSubview(price)
            
            let shares = UILabel()
            shares.frame = CGRect(x: 0.25*width, y: (height*0.11+21)*CGFloat(i)+height*0.06, width: 0.35*width, height: height*0.05)
            shares.text = "\(list[i][4] as! String) shares"
            shares.font =  UIFont(name: "EBGaramond08-Regular", size: 22)
            shares.backgroundColor = UIColor.black
            shares.textColor = UIColor.white
            shares.textAlignment = .center
            tempItems[i].append(shares)
            scrollView.addSubview(shares)
            
            let change = UILabel()
            change.frame = CGRect(x: 0.545*width, y: (height*0.11+21)*CGFloat(i), width: 0.2*width, height: height*0.05)
            change.backgroundColor = UIColor.black
            change.text = "Change:"
            change.font = UIFont(name: "EBGaramond08-Regular", size: 18)
            change.backgroundColor = UIColor.black
            change.textColor = UIColor.white
            change.textAlignment = .right
            tempItems[i].append(change)
            scrollView.addSubview(change)
            let changeNum = UILabel()
            changeNum.frame = CGRect(x: 0.775*width, y: (height*0.11+21)*CGFloat(i), width: 0.175*width, height: height*0.05)
            changeNum.layer.cornerRadius = 5
            changeNum.clipsToBounds = true
            let changeString = (list[i][6] as! String)
            changeNum.text = changeString
            if Double(changeString.prefix(changeString.count - 1))! >= 0.0 {
                changeNum.text = "+\(changeString)"
                changeNum.backgroundColor = green
            } else {
                changeNum.backgroundColor = red
            }
            changeNum.font =  UIFont(name: "EBGaramond08-Regular", size: 18)
            changeNum.textColor = UIColor.white
            changeNum.textAlignment = .center
            tempItems[i].append(changeNum)
            scrollView.addSubview(changeNum)
            
            let totalReturn = UILabel()
            totalReturn.frame = CGRect(x: 0.545*width, y: (height*0.11+21)*CGFloat(i)+height*0.06, width: 0.2*width, height: height*0.05)
            totalReturn.backgroundColor = UIColor.black
            totalReturn.text = "Return:"
            totalReturn.font =  UIFont(name: "EBGaramond08-Regular", size: 18)
            totalReturn.backgroundColor = UIColor.black
            totalReturn.textColor = UIColor.white
            totalReturn.textAlignment = .right
            tempItems[i].append(totalReturn)
            scrollView.addSubview(totalReturn)
            let returnNum = UILabel()
            returnNum.frame = CGRect(x: 0.775*width, y: (height*0.11+21)*CGFloat(i)+height*0.06, width: 0.175*width, height: height*0.05)
            returnNum.layer.cornerRadius = 5
            returnNum.clipsToBounds = true
            let returnString = (list[i][9] as! String)
            let returnVal = Double(returnString.substring(to:returnString.index(returnString.startIndex, offsetBy: 4)))
            if returnVal as! Double >= 0.0 {
                returnNum.text = "+\(returnString)"
                returnNum.backgroundColor = green
            } else {
                returnNum.text = "\(returnString)"
                returnNum.backgroundColor = red
            }
            returnNum.font =  UIFont(name: "EBGaramond08-Regular", size: 18)
            returnNum.textColor = UIColor.white
            returnNum.textAlignment = .center
            tempItems[i].append(returnNum)
            scrollView.addSubview(returnNum)
            
            if i != list.count-1 {
                let dividerLine = UILabel()
                dividerLine.frame = CGRect(x: 0.05*width, y: (height*0.11+21)*CGFloat(i)+(height*0.11)+10, width: width*0.9, height: 1)
                dividerLine.backgroundColor = UIColor.white
                tempItems[i].append(dividerLine)
                scrollView.addSubview(dividerLine)
            }
        }
        self.view.addSubview(scrollView)
        
        scrollItemList = tempItems
        tickerList = tempTickers
        
        self.calcDailyChangePct()
        loadingIndicator.stopAnimating()
        loadingLabel.removeFromSuperview()
    }
    
    func removeListFromView() {
        for row in scrollItemList {
            for item in row {
                item.removeFromSuperview()
            }
        }
        for row in tickerList {
            for ticker in row {
                ticker.removeFromSuperview()
            }
        }
    }
    
    func getBackupStockData(ticker: String, numStock: Int) {
        let ticker_clean = ticker.replacingOccurrences(of: " ", with: "")
        let myURLString = "https://finance.yahoo.com/quote/\(ticker_clean.uppercased())"
        print()
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return
        }

        do {
            var HTMLString = try String(contentsOf: myURL, encoding: .ascii)
            let range = HTMLString.range(of: "Trsdu(0.3s) Fw(b)")
            if (range == nil) { print(ticker); print(HTMLString) }
            let endPos = HTMLString.distance(from: HTMLString.startIndex, to: range!.upperBound)
            if checkDuringTradingHours() {
                HTMLString = "\(HTMLString.prefix(endPos + 201))"
                HTMLString = "\(HTMLString.suffix(176))"
            } else {
                HTMLString = "\(HTMLString.prefix(endPos + 251))"
                HTMLString = "\(HTMLString.suffix(276))"
            }
            if (HTMLString.contains("quote-market-notice")) {
                print(HTMLString)
                print("QUOTE MARKET NOTICE ERROR AHHHHHHHHHHHHH")
            }
            
            let startPrice = HTMLString.index(of: ">")!
            let endPrice = HTMLString.index(of: "<")!
            let priceDistance = HTMLString.distance(from: HTMLString.startIndex, to: endPrice)
            let priceLength = HTMLString.distance(from: startPrice, to: endPrice)
            var priceString = HTMLString.prefix(priceDistance)
            priceString = priceString.suffix(priceLength - 1)
            print("priceString \(ticker_clean): \(priceString)")
            completeData[numStock][3] = "$\(String(format: "%.2f", Double(priceString)!))"
        
            var changeString = Substring()
            if HTMLString.contains("quote-market-notice") {
                changeString = HTMLString.suffix(90)
                if changeString.suffix(50).contains("%") {
                    changeString = HTMLString.suffix(50)
                }
                //changeString = changeString.prefix(40)
            } else {
                changeString = HTMLString.suffix(40)
            }
            //var 
            // Trsdu(0.3s) Fw(500)
            print("CHANGESTRING EARLY: \(changeString)")
            let startChange = changeString.index(of: "(")!
            let endChange = changeString.index(of: ")")!
            let changeDistance = changeString.distance(from: changeString.startIndex, to: endChange)
            let changeLength = changeString.distance(from: startChange, to: endChange)
            changeString = changeString.prefix(changeDistance)
            changeString = changeString.suffix(changeLength - 1)
            print("changeString \(ticker): \(changeString)")
            
            let changeNoPct = changeString.prefix(changeString.count - 1)
            if Double(changeNoPct)! >= 0 {
                completeData[numStock][6] = "+\(String(format: "%.2f", Double(changeNoPct)!))%"
            }
            completeData[numStock][6] = "\(String(format: "%.2f", Double(changeNoPct)!))%"
            
        } catch let error {
            print("Error: \(error)")
        }
    } 
    
    func checkDuringTradingHours() -> Bool {
        let cal = Calendar.current
        let now = Date()
        
        let timeDiffNY = (TimeZone.current.secondsFromGMT() / 3600) + 4
        print("TIMEDIFFNY: \(timeDiffNY)")
        
        let openMarket = cal.date(bySettingHour: 9, minute: 30, second: 0, of: now)!
        let closeMarket = cal.date(bySettingHour: 16, minute: 0, second: 0, of: now)!
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentMin = Calendar.current.component(.minute, from: Date())
        let currentSec = Calendar.current.component(.second, from: Date())
        
        let NYHour = currentHour - timeDiffNY
        print("NYHOURS: \(NYHour)")
        
        var NYTime = cal.date(bySettingHour: currentHour, minute: currentMin, second: currentSec, of: now)!
        if NYHour < 0 {
            let yesterday =  Calendar.current.date(byAdding: .day, value: -1, to: now)!
            NYTime = cal.date(bySettingHour: 24 + NYHour, minute: currentMin, second: currentSec, of: yesterday)!
        } else if NYHour >= 24 {
            let tomorrow =  Calendar.current.date(byAdding: .day, value:  1, to: now)!
            NYTime = cal.date(bySettingHour: NYHour - 24, minute: currentMin, second: currentSec, of: tomorrow)!
        } else {
            NYTime = cal.date(bySettingHour: NYHour, minute: currentMin, second: currentSec, of: now)!
        }
        return (openMarket <= NYTime && NYTime <= closeMarket)
    }
    
    func calcDailyChangePct() {
        var totalDailyChange = 0.0
        var totalLongChange = 0.0
        var totalShortChange = 0.0
        print()
        for row in longList {
            let changeString = row[6] as! String
            let changeNum = Double(changeString.prefix(changeString.count - 1))!
            let pctValue = 1 + (changeNum / 100)
            
            var sharesOwned = row[4] as! String
            sharesOwned = sharesOwned.replacingOccurrences(of: ",", with: "")
            var currentPrice = row[3] as! String
            currentPrice = currentPrice.replacingOccurrences(of: ",", with: "")
            currentPrice = currentPrice.replacingOccurrences(of: "$", with: "")
            let currValueNum = Double(sharesOwned)! * Double(currentPrice)!
            
            let openValue = currValueNum / pctValue
            let valueChange = currValueNum - openValue
            
            totalLongChange += valueChange
            print("\(row[0] as! String):    \(valueChange)")
        }
        for row in shortList {
            let changeString = row[6] as! String
            let changeNum = Double(changeString.prefix(changeString.count - 1))!
            let pctValue = 1 + (changeNum / 100)
            
            var sharesOwned = row[4] as! String
            sharesOwned = sharesOwned.replacingOccurrences(of: ",", with: "")
            var currentPrice = row[3] as! String
            currentPrice = currentPrice.replacingOccurrences(of: ",", with: "")
            currentPrice = currentPrice.replacingOccurrences(of: "$", with: "")
            let currValueNum = Double(sharesOwned)! * Double(currentPrice)!
            
            let openValue = currValueNum / pctValue
            let valueChange = currValueNum - openValue
            
            totalShortChange -= valueChange
            print("\(row[0] as! String):    \(valueChange)")
        }
        print("LONGCHANGE: \(totalLongChange)")
        print("SHORTCHANGE: \(totalShortChange)")
        totalDailyChange = totalLongChange + totalDailyChange
        print("TOTALCHANGE: \(totalLongChange)")
        
        var totalAssetsString = totalAssets.replacingOccurrences(of: "$", with: "")
        totalAssetsString = totalAssetsString.replacingOccurrences(of: ",", with: "")
        let totalAssetsNum = Double(totalAssetsString)!
        
        totalDailyChangePct = 100 * totalDailyChange / totalAssetsNum
        print("DailyChange%:  \(totalDailyChangePct)")
        
        if totalDailyChangePct >= 0.0 {
            dailyGainLabel.text = "+\(String(format: "%.2f", totalDailyChangePct))%"
            dailyGainLabel.backgroundColor = self.green
        } else {
            dailyGainLabel.text = "\(String(format: "%.2f", totalDailyChangePct))%"
            dailyGainLabel.backgroundColor = self.red
        }
    }
    
    func getFormattedTimeString() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return "\(formatter.string(from: date)):00"
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func getData() {
        print("Got here GET DATA 1")
        let spreadsheetId = "1FUYLvdT2lTmNXQODnfX0SyMbqbHg9geu_qozBmQfbCE" // Portfolio
        let range = "C7:O"
        print("Got here GET DATA 2")
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:range)
        print("Got here GET DATA 3")
        DispatchQueue.global(qos: .background).async {
            print(self.service.executeQuery(query, delegate: self, didFinish: #selector(self.displayResultWithTicket(ticket:finishedWithObject:error:))))
        }
        print("Got here GET DATA 4")
    }
    
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

    // Process the response and display output
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket, finishedWithObject result : GTLRSheets_ValueRange, error : NSError?) {
        print("Got here DISPLAYRESULTWITHTICKET")

        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            updater.invalidate()
            return
        }
        
        completeData = result.values!
        
        for i in 0...completeData.count - 1 {
            let ticker = (completeData[i][0] as! String)
            print("\nROW: \(completeData[i])")
            if ticker == "Total " {
                break
            }
            if (!ticker.contains("Short") && !ticker.contains("Cash") && !ticker.contains("Total")) {
                getBackupStockData(ticker: ticker, numStock: i)
            }
        }
        
        var longBool = true
        var tempLongList = [[Any]]()
        var tempShortList = [[Any]]()

        for row in completeData {
            if !(row[0] as! String).contains("Cash") && !(row[0] as! String).contains("Total") {
                if (row[0] as! String).contains("Short") {
                    longBool = false
                } else {
                    if longBool {
                        tempLongList.append(row)
                    } else {
                        tempShortList.append(row)
                    }
                    print("\(row[0] as! String): \(row[6] as! String) \n")
                }
            }
            if (row[0] as! String) == "Cash" {
                totalCash = row[2] as! String
            }
            if (row[0] as! String) == "Total " {
                totalAssets = row[2] as! String
                dailyAUMGain = row[6] as! String
                totalAUMGain = row[9] as! String
                print("AUMGAIN: \(totalAUMGain)")
                print("AUMGAIN2: \(row[10] as! String)")
                break
            }
        }
        longList = tempLongList
        shortList = tempShortList
        
        totalCashLabel.text = "Cash:   \(totalCash)"
        totalAUMLabel.text = "AUM:   \(totalAssets)"
        var dailyAUMGainVal = Double(dailyAUMGain.substring(to:dailyAUMGain.index(dailyAUMGain.startIndex, offsetBy: 4)))
        var totalAUMGainVal = Double(totalAUMGain.substring(to:totalAUMGain.index(totalAUMGain.startIndex, offsetBy: 4)))
        
        if totalAUMGain == "Loading..." {
            totalAUMGainVal = 0.1
        }
        if totalAUMGainVal as! Double > 0.0 {
            totalGainLabel.text = "+\(totalAUMGain)"
            totalGainLabel.backgroundColor = green 
        } else {
            totalGainLabel.text = "\(totalAUMGain)"
            totalGainLabel.backgroundColor = red
        }
        
        if showLongs {
            presentList(list: longList)
        } else {
            presentList(list: shortList)
        }

    }
    
    @objc func buttonClicked(_ sender: AnyObject?) {
        if sender === longButton {
            print("long")
            if showLongs { return }
            makeButtonLight(button: longButton)
            makeButtonDark(button: shortButton)
            showLongs = true
            presentList(list: longList)
        }
        if sender === shortButton {
            print("short")
            if !showLongs { return }
            makeButtonLight(button: shortButton)
            makeButtonDark(button: longButton)
            showLongs = false
            presentList(list: shortList)
        }
        if sender === backButton {
            print("back")
            updater.invalidate()
            let menuController = MenuController()
            self.present(menuController, animated: true, completion: nil)
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
