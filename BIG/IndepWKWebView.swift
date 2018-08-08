//
//  IndepWKWebView.swift
//  BIG
//
//  Created by Jeffrey Chen on 8/7/18.
//  Copyright © 2018 Jeffrey Chen. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class IndepWKWebView: WKWebView, WKNavigationDelegate {

    var gotCSV = false
    var requestURL = ""
    var price = 0.00
    var dayNum = 0
    var performanceController = PerformanceController()
    
    init(url: String, num: Int, pfController: PerformanceController) {
        //let asdf = CGRect(x: 0, y: 0, width: pfController.view.frame.width, height: pfController.view.frame.height)
        super.init(frame: CGRect(), configuration: WKWebViewConfiguration())
        self.navigationDelegate = self
        
        self.dayNum = num
        self.requestURL = url
        
        self.performanceController = pfController
        pfController.view.addSubview(self)
        
        self.load(URLRequest(url: URL(string: requestURL)!))
    }

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: WKWebViewConfiguration() )
        self.navigationDelegate = self
    }
    
    func getPrice() -> Double {
        return price
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let emailRequest = "document.getElementsByTagName(\"input\")[3].value = \"\(userEmail)\""
        let passwordRequest = "document.getElementsByTagName(\"input\")[4].value = \"\(password)\""
        webView.evaluateJavaScript(emailRequest, completionHandler: nil)
        webView.evaluateJavaScript(passwordRequest, completionHandler: nil)
        let submitRequest = "document.forms[0].submit()"
        webView.evaluateJavaScript(submitRequest, completionHandler: getHTML)
    }
    
    func getHTML(result: Any?, error: Error?) {
        let getHTMLString = "document.documentElement.outerHTML.toString()"
        
        self.evaluateJavaScript(getHTMLString, completionHandler: { (html: Any?, error: Error?) in
            if (html as! String).contains("Value of One Unit:") {
                self.convertHTMLToCSV(fullHTML: html as! String)
            }
        })
    }
    
    func convertHTMLToCSV(fullHTML: String) {
        let valueRange = fullHTML.range(of: "Value of One Unit:")!
        let endPos = fullHTML.distance(from: valueRange.upperBound, to: fullHTML.endIndex)
        var navHTML = String(fullHTML.suffix(endPos))
        navHTML = navHTML.replacingOccurrences(of: "</td><td>", with: "")
        
        let decimalRange = navHTML.range(of: "</td></tr>")!
        let distance = navHTML.distance(from: navHTML.startIndex, to: decimalRange.lowerBound)
        navHTML = String(navHTML.prefix(distance))
        price = Double(navHTML)!
        if dayNum != -999 {
            PerformanceController.navArr[dayNum] = price
        }
        print("HERE: \(price)    \(dayNum)")
        performanceController.view.addSubview(self)
        //NAVLabel.text = "$\(String(format: "%.2f", Double(navHTML)!))"
        checkLoadNAVVisuals()
    }
    
    func checkLoadNAVVisuals() {
        if self.dayNum == -999 {
            PerformanceController.NAVLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 75)
            PerformanceController.NAVLabel.text = "$\(String(format: "%.2f", getPrice()))"
            PerformanceController.currentDayNAVLoaded = true
            return
        }
        
        if dayNum >= PerformanceController.navDates.count {
            print("loaded NAV Visuals")
            PerformanceController.alreadyLoaded = true
            self.performanceController.loadNAVVisuals()
            return
        } else {
            dayNum += 1
            if dayNum >= PerformanceController.navDates.count {
                print("loaded NAV Visuals")
                PerformanceController.alreadyLoaded = true
                self.performanceController.loadNAVVisuals()
                return
            } 
            let dateString = PerformanceController.navDates[dayNum]
            requestURL = "https://www.bivio.com/get-csv/berkeley/accounting/reports/valuation.csv?date=\(dateString)"
            self.load(URLRequest(url: URL(string: requestURL)!))
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
