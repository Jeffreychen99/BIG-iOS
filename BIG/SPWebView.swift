//
//  SPWebView.swift
//  BIG
//
//  Created by Jeffrey Chen on 8/7/18.
//  Copyright © 2018 Jeffrey Chen. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class SPWebView: WKWebView, WKNavigationDelegate {

    var requestURL = ""
    var performanceController = PerformanceController()
    
    var stringData = [String]()
    var data = [[Any]]()
    
    var updater = Timer()
    
    init(pfController: PerformanceController) {
        //let asdf = CGRect(x: 0, y: 0, width: pfController.view.frame.width, height: pfController.view.frame.height)
        super.init(frame: CGRect(), configuration: WKWebViewConfiguration())
        self.navigationDelegate = self
        
        requestURL = "https://quotes.wsj.com/index/SPX/historical-prices"
        
        self.performanceController = pfController
        pfController.view.addSubview(self)
        
        self.load(URLRequest(url: URL(string: requestURL)!))
    }

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: WKWebViewConfiguration() )
        self.navigationDelegate = self
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Loaded S&P500 Web View...")
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let graphDate = formatter.date(from: PerformanceController.dates[0])!
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: graphDate)!
        
        let selectRequest = "document.getElementById(\"selectDateFrom\").value = \"\(formatter.string(from: startDate))\""
        webView.evaluateJavaScript(selectRequest, completionHandler: nil)
        
        let downloadRequest = "document.getElementById(\"datPickerButton\").click()"
        webView.evaluateJavaScript(downloadRequest, completionHandler: nil)
        //getHTML(result: nil, error: nil)
        updater = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getHTMLTimer), userInfo: nil, repeats: true)
    }
    
    @objc func getHTMLTimer() {
        getHTML(result: nil, error: nil)
    }
    
    func getHTML(result: Any?, error: Error?) {
        let getHTMLString = "document.documentElement.outerHTML.toString()"
        self.evaluateJavaScript(getHTMLString, completionHandler: { (html: Any?, error: Error?) in
            let month = PerformanceController.dates[0].prefix(2)
            let day = PerformanceController.dates[0].prefix(5).suffix(2)
            let year = PerformanceController.dates[0].suffix(2)
            let WSJDate = "\(month)/\(day)/\(year)"
            if (html as! String).contains(WSJDate) {
                self.convertHTMLToCSV(HTMLString: html as! String)
            } else {
                print("WSJ S&P NOT YET UPDATED... \(WSJDate)")
                //print(html as! String)
                //self.getHTML(result: nil, error: nil)
            }
        })
    }
    
    func convertHTMLToCSV(HTMLString: String) {
        updater.invalidate()
        var HTML = HTMLString
        var startRange = HTML.range(of: "<div class=\"scrollBox\"> <table class=\"cr_dataTable\"> <tbody> <tr> <td>")
        if startRange == nil { startRange = HTML.range(of: "<div id=\"historical_data_table\"><div class=\"scrollBox\">") }
        let suffixDist = HTML.distance(from: startRange!.upperBound, to: HTML.endIndex)
        HTML = String( HTML.suffix(suffixDist) )
        
        var endRange = HTML.range(of: "</div></div> <div class=\"nav-right\">")
        if endRange == nil { print("************** Endrange **************"); print(HTML); endRange = HTML.range(of: "</tr> </tbody> </table>") }
        let prefixDist = HTML.distance(from: HTML.startIndex, to: endRange!.lowerBound)
        HTML = String( HTML.prefix(prefixDist) )
        
        let firstRange = HTML.range(of: "<td>")
        let firstDist = HTML.distance(from: firstRange!.upperBound, to: HTML.endIndex)
        HTML = String( HTML.suffix(firstDist) )
        //print(HTML)
        
        var tempData = [[Any]]()
        while HTML.count >= 0 {
            var arr = [Any]()
            for i in 0...4 {
                let endLine = HTML.range(of: "</td>")
                let lineDist = HTML.distance(from: HTML.startIndex, to: endLine!.lowerBound)
                let datum = String( HTML.prefix(lineDist) )
                //print("THIS IS DATUM: \(datum)   DIVDIST: \(divDist)")
                if i == 0 {
                    let date = datum as! String
                    let modDate = "\(date.prefix(date.count - 2))20\(date.suffix(2))"
                    arr.append(modDate)
                } else {
                    arr.append( Double(datum)! )
                }
                let nextLine = HTML.range(of: "<td>")
                if nextLine == nil { break }
                let nextDist = HTML.distance(from: nextLine!.upperBound, to: HTML.endIndex)
                HTML = String( HTML.suffix(nextDist) )
            }
            if HTML.contains("<td>") {
                print("S&P Data-line: \(arr[0])  \(arr[4])")
                tempData.append(arr)
            } else {
                HTML = ""
                break
            }
        }
        data = tempData
        transferToPerformanceController()
    }
    
    /**func convertHTMLToCSV(HTMLString: String) { // THIS IS THE VERSION WITHOUT TIMER
        var HTML = HTMLString
        var startRange = HTML.range(of: "<div class=\"scrollBox\"> <table class=\"cr_dataTable\"> <tbody> <tr> <td>")
        if startRange == nil { startRange = HTML.range(of: "<div id=\"historical_data_table\"><div class=\"scrollBox\">") }
        let suffixDist = HTML.distance(from: startRange!.upperBound, to: HTML.endIndex)
        HTML = String( HTML.suffix(suffixDist) )
        
        var endRange = HTML.range(of: "</div></div> <div class=\"nav-right\">")
        if endRange == nil { print("************** Endrange **************"); endRange = HTML.range(of: "</tr> </tbody> </table>") }
        let prefixDist = HTML.distance(from: HTML.startIndex, to: endRange!.lowerBound)
        HTML = String( HTML.prefix(prefixDist) )
        print(HTML)
        
        var tempData = [[Any]]()
        while HTML.count >= 0 {
            var arr = [Any]()
            for i in 0...3 {
                var divRange = HTML.range(of: "</td> <td>")
                if divRange == nil { divRange = HTML.range(of: "</tr>") } // MAYBE?
                let divDist = HTML.distance(from: HTML.startIndex, to: divRange!.lowerBound)
                
                let datum = String( HTML.prefix(divDist) )
                //print("THIS IS DATUM: \(datum)   DIVDIST: \(divDist)")
                if i == 0 {
                    let date = datum as! String
                    let modDate = "\(date.prefix(date.count - 2))20\(date.suffix(2))"
                    arr.append(modDate)
                } else {
                    arr.append( Double(datum)! )
                }
                let remainderDist = HTML.distance(from: divRange!.upperBound, to: HTML.endIndex)
                HTML = String( HTML.suffix(remainderDist) )
            }
            var lineDivide = HTML.range(of: "</td> </tr> <tr> <td>")
            if lineDivide == nil { lineDivide = HTML.range(of: "</td> </tr> <tr style=\"display: none;\"> <td>") }
            if lineDivide == nil { 
                arr.append( Double( String( HTML.prefix(HTML.count - 6) ) )! )
                tempData.append(arr)
                HTML = ""
                //getNextPage()   //MAKE SURE THIS WORKS CORRECTLY
                break
            } else {
                let lastDivDist = HTML.distance(from: HTML.startIndex, to: lineDivide!.lowerBound)
                arr.append( Double( String(HTML.prefix(lastDivDist)) )!)
                let lineDivDist = HTML.distance(from: lineDivide!.upperBound, to: HTML.endIndex)
                HTML = String( HTML.suffix(lineDivDist) )
                tempData.append(arr)
            }
        }
        data = tempData
        transferToPerformanceController()
    }*/
    
    func transferToPerformanceController() {
        updater.invalidate()
        print()
        print("Transfering S&P500")
        var spDates = [String]()
        for row in data {
            spDates.append(row[0] as! String)
        }
        var index = 0
        for date in PerformanceController.dates {
            for row in data {
                if date == row[0] as! String {
                    PerformanceController.spArr[index] = row[4] as! Double
                    index += 1
                }
            }
        }
        for (i, SP) in PerformanceController.spArr.enumerated() {
            if SP <= 1400.0 {
                print("Missing S&P Found: \(PerformanceController.dates[i])")
                for row in data {
                    if PerformanceController.dates[i] == row[0] as! String {
                        print("Missing Filled: \(PerformanceController.dates[i])  \(row[4] as! Double)")
                        PerformanceController.spArr[index] = row[4] as! Double
                        break
                    }
                }
            }
        }
        if !spDates.contains(PerformanceController.dates.last!) {
            let length = PerformanceController.spArr.count
            PerformanceController.spArr[length - 1] = PerformanceController.spArr[length - 2]
        }
        
        PerformanceController.SPloaded = true
        performanceController.loadNAVVisuals()
        print("S&P500 Finished Loading")
        print()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}











