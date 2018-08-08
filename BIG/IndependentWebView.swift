//
//  IndependentWebView.swift
//  BIG
//
//  Created by Jeffrey Chen on 7/24/18.
//  Copyright © 2018 Jeffrey Chen. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class IndependentWebView: UIWebView, UIWebViewDelegate { //DEPRECATED, DO NOT USE

    var gotCSV = false
    var requestURL = ""
    var price = 0.00
    var dayNum = 0
    var performanceController = PerformanceController()
    
    init(url: String, num: Int, pfController: PerformanceController) {
        super.init(frame: CGRect())
        self.dayNum = num
        self.delegate = self
        requestURL = url
        self.performanceController = pfController
        //let mutableRequest = NSMutableURLRequest(url: URL(string: requestURL)!)
        //let auth = ""
        //mutableRequest.addValue(auth, forHTTPHeaderField: "asdf")
        self.loadRequest(URLRequest(url: URL(string: requestURL)!))
        //self.loadRequest(mutableRequest as URLRequest)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }
    
    func getPrice() -> Double {
        return price
    }
    
    //func webViewDidFinishLoadCustom(_ webView: UIWebView, str: String?) {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("GOT HERE 1")
        if gotCSV {
            print("GOT HERE 2")
            getHTML()
            return
        }
        gotCSV = !gotCSV
        
        let emailRequest = "document.getElementsByTagName(\"input\")[3].value = \"\(userEmail)\""
        let passwordRequest = "document.getElementsByTagName(\"input\")[4].value = \"\(password)\""
        webView.stringByEvaluatingJavaScript(from: emailRequest)
        webView.stringByEvaluatingJavaScript(from: passwordRequest)
        let submitRequest = "document.forms[0].submit()"
        webView.stringByEvaluatingJavaScript(from: submitRequest)
        //webViewDidFinishLoadCustom(webView, str: webView.stringByEvaluatingJavaScript(from: submitRequest))
    }
    
    func getHTML() {
        let getHTML = "document.documentElement.outerHTML.toString()"
        convertHTMLToCSV(fullHTML: (String( self.stringByEvaluatingJavaScript(from: getHTML)! )))
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
        
        /**for i in PerformanceController.webViewArr {
            if i.getPrice() == 0 {
                return
            }
        }*/
        print("loaded NAV Visuals")
        self.performanceController.loadNAVVisuals()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

















