//
//  ACWIWebView.swift
//  BIG
//
//  Created by Jeffrey Chen on 8/7/18.
//  Copyright © 2018 Jeffrey Chen. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class ACWIWebView: WKWebView, WKNavigationDelegate {

    var requestURL = ""
    var performanceController = PerformanceController()
    
    var stringData = [String]()
    var data = [[Any]]()
    
    init(pfController: PerformanceController) {
        //let asdf = CGRect(x: 0, y: 0, width: pfController.view.frame.width, height: pfController.view.frame.height)
        super.init(frame: CGRect(), configuration: WKWebViewConfiguration())
        self.navigationDelegate = self
        
        requestURL = "https://www.nasdaq.com/symbol/acwi/historical"
        
        self.performanceController = pfController
        pfController.view.addSubview(self)
        
        self.load(URLRequest(url: URL(string: requestURL)!))
    }

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: WKWebViewConfiguration() )
        self.navigationDelegate = self
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Loaded ACWI Web View...")
        var timeSpanVal = 0
        if performanceController.graphDays == 5 {
            timeSpanVal = 0
        } else if performanceController.graphDays == 20 {
            timeSpanVal = 1
        } else if performanceController.graphDays == 365 {
            timeSpanVal = 4
        } else if performanceController.graphDays == 1095 {
            timeSpanVal = 7
        } else if performanceController.graphDays == 1825 {
            timeSpanVal = 9
        }
        let selectRequest = "document.getElementById(\"ddlTimeFrame\").selectedIndex = \(timeSpanVal)"
        webView.evaluateJavaScript(selectRequest, completionHandler: nil)
        let downloadRequest = "document.getElementById(\"lnkDownLoad\").click()"
        webView.evaluateJavaScript(downloadRequest, completionHandler: getHTML)
    }
    
    func getHTML(result: Any?, error: Error?) {
        let getHTMLString = "document.documentElement.outerHTML.toString()"
        self.evaluateJavaScript(getHTMLString, completionHandler: { (html: Any?, error: Error?) in
            var HTMLString = html as! String
            if HTMLString.contains("HistoricalQuotes<") {
                print()
                print()
                let startRange = HTMLString.range(of: "volume</td><td>open</td><td>high</td><td>low</td></tr><tr><td>")!
                let suffixDist = HTMLString.distance(from: startRange.upperBound, to: HTMLString.endIndex)
                HTMLString = String ( HTMLString.suffix(suffixDist) )
                
                while HTMLString.count > 0 {
                    if HTMLString == "</td></tr></tbody></table></body></html>" {
                        break
                    } else {
                        if !HTMLString.contains("</td></tr><tr><td>") { 
                            self.stringData.append(HTMLString)
                            break 
                        }
                        let divRange = HTMLString.range(of: "</td></tr><tr><td>")!
                        let dist = HTMLString.distance(from: HTMLString.startIndex, to: divRange.upperBound)
                        self.stringData.append( String(HTMLString.prefix(dist)) )
                        HTMLString = String( HTMLString.suffix(HTMLString.count - dist) )
                    }
                }
                self.convertHTMLToCSV()
            }
        })
    }
    
    func convertHTMLToCSV() {
        for rowString in stringData {
            var tempArr = [Any]()
            var tempRowString = rowString
            for _ in 0...4 {
                let divRange = tempRowString.range(of: "</td><td>")!
                let prefixDist = tempRowString.distance(from: tempRowString.startIndex, to: divRange.lowerBound)
                let datum = String( tempRowString.prefix(prefixDist) )
                if datum.contains("/"){
                    tempArr.append( datum )
                } else if datum.contains(":") {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd"
                    tempArr.append(formatter.string(from: Date()))
                } else {
                    if datum.contains(".") {
                        tempArr.append( Double(datum)! )
                    } else {
                        tempArr.append( Double("\(datum).00") )
                    }
                }
                
                let suffixDist = tempRowString.distance(from: divRange.upperBound, to: tempRowString.endIndex)
                tempRowString = String( tempRowString.suffix(suffixDist) )
            }
            let endRange = tempRowString.range(of: "<")!
            let lastDist = tempRowString.distance(from: tempRowString.startIndex, to: endRange.lowerBound)
            tempRowString = String( tempRowString.prefix(lastDist) )
            tempArr.append( Double(tempRowString)! )
            data.append(tempArr)
        }
        transferToPerformanceController()
    }
    
    func transferToPerformanceController() {
        for row in data {
            let i = getDateIndex(ACWIDate: row[0] as! String)
            if i != -999 {
                PerformanceController.acwiArr[i] = row[1] as! Double
            }
        }
        fillMissingDates()
        //flattenMissingDates()
    }
    
    func flattenMissingDates() {
        var tempACWI = [Double]()
        for (i, acwi) in PerformanceController.acwiArr.enumerated() {
            if acwi == 0.0 {
                if i != 0 && i != PerformanceController.acwiArr.count - 1 {
                    let sum = PerformanceController.acwiArr[i - 1] + PerformanceController.acwiArr[1 + 1]
                    tempACWI.append(sum / 2)
                    print("FLATTENED: \(i): \(sum / 2)")
                } else if i != 0 {
                    tempACWI.append(PerformanceController.acwiArr[1])
                    print("FLATTENED: \(i)")
                } else if i != PerformanceController.acwiArr.count - 1 {
                    tempACWI.append(PerformanceController.acwiArr[i - 1])
                    print("FLATTENED: \(i)")
                }
            } else {
                tempACWI.append(acwi)
            }
        }
        PerformanceController.acwiArr = tempACWI
        print("Flattened missing data")
    }
    
    func fillMissingDates() {
        var acwiDates = [String]()
        for row in data {
            acwiDates.append(row[0] as! String)
        }
        
        // setup array forwhich dates are missing from acwiWebView date array
        var missingDates = [Date]()
        let ACWIDate = DateFormatter()
        ACWIDate.dateFormat = "yyyy/MM/dd"
        for date in PerformanceController.dates {
            if !acwiDates.contains(convertNAVDateToACWI(date: date)) {
                print("MISSING     \(date)")
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                missingDates.append(formatter.date(from: date)!)
            }
        }
        
        // setup array for which acwiArr spots are at 0.0 value
        var missingACWI = [Int]()
        for (i, acwi) in PerformanceController.acwiArr.enumerated() {
            if acwi == 0.0 {
                missingACWI.append(i)
            }
        }
        
        print("MISSING DATE: \(missingDates.count)     MISSING ACWI: \(missingACWI.count)")
        
        // fix each in the missingDates
        for (i, date) in missingDates.enumerated() {
            var newDate = date
            for _ in 0...7 {
                newDate = Calendar.current.date(byAdding: .day, value: -1, to: newDate)!
                let newDateString = ACWIDate.string(from: newDate)
                
                var fixed = false
                for row in data {
                    if row[0] as! String == newDateString {
                        fixed = true
                        PerformanceController.acwiArr[missingACWI[i]] = row[1] as! Double
                        print("FILLED \(ACWIDate.string(from:date)):  \(PerformanceController.acwiArr[i])")
                        break
                    }
                }
                
                if fixed {
                    break
                }
            }
        }
        print("Missing dates filled")
        print()
        PerformanceController.ACWIloaded = true
        performanceController.loadNAVVisuals()
    }
    
    func getDateIndex(ACWIDate: String) -> Int {
        for (i, date) in PerformanceController.dates.enumerated() {
            //print("Date: \(convertNAVDateToACWI(date: date))    ACWIDate: \(ACWIDate)")
            if convertNAVDateToACWI(date: date) == ACWIDate {
                return i
            }
        }
        return -999
    }
    
    func convertNAVDateToACWI(date: String) -> String {
        let month = String(date.prefix(2))
        let day = String(date.prefix(5)).suffix(2)
        let year = String(date.suffix(4))
        return "\(year)/\(month)/\(day)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}











