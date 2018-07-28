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

class IndependentWebView: UIWebView, UIWebViewDelegate {

    var gotCSV = false
    var requestURL = ""
    var price = 0.00
    var dayNum = 0
    
    init(url: String, num: Int) {
        super.init(frame: CGRect())
        self.dayNum = num
        self.delegate = self
        requestURL = url
        self.loadRequest(URLRequest(url: URL(string: requestURL)!))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }
    
    func getPrice() -> Double {
        return price
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if gotCSV {
            getHTML(completion: convertHTMLToCSV)
            return
        }
        gotCSV = !gotCSV
        
        let emailRequest = "document.getElementsByTagName(\"input\")[3].value = \"\(userEmail)\""
        let passwordRequest = "document.getElementsByTagName(\"input\")[4].value = \"\(password)\""
        webView.stringByEvaluatingJavaScript(from: emailRequest)
        webView.stringByEvaluatingJavaScript(from: passwordRequest)
        let submitRequest = "document.forms[0].submit()"
        webView.stringByEvaluatingJavaScript(from: submitRequest)
        
    }
    
    func getHTML(completion: (String)->Void) {
        let getHTML = "document.documentElement.outerHTML.toString()"
        completion(String( self.stringByEvaluatingJavaScript(from: getHTML)! ))
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
        //NAVLabel.text = "$\(String(format: "%.2f", Double(navHTML)!))"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

















