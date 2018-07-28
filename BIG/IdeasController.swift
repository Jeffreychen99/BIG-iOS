//
//  IdeasController.swift
//  BIG
//
//  Created by Jeffrey Chen on 6/5/18.
//  Copyright © 2018 Jeffrey Chen. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

import Alamofire

class IdeasController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets]
    private let service = GTLRSheetsService()
    
    let green = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
    let red = UIColor(red: 0.8, green: 0, blue: 0, alpha: 1)
    
    var showLongs = true
    
    let longButton = UIButton()
    let shortButton = UIButton()
    let backButton = UIButton()
    
    var name = String()
    var abbreviatedName = String()
    var yourIdeasLabel = UILabel()
    var listOptions: [String] = ["Your Ideas", "All Ideas"]
    let ideasPicker = UIPickerView()
    
    let statusOptions = ["Idea", "Memo", "In Fund"]
    let sectorOptions = [   "Basic Materials", "Consumer Cyclical", "Financial Services", "Real Estate", "Consumer Defensive",
                            "Healthcare", "Utilities", "Communication Services", "Energy", "Industrials", "Technology"   ]
                            
    var sectorPicker = UIPickerView()
    var selectedSector = "Basic Materials"
    
    let addButton = UIButton()
    let subtractButton = UIButton()
    
    let searchField = UITextField()
    
    let scrollView = UIScrollView()
    var scrollItemList = [[UILabel]]()
    var statusList = [UIPickerView]()
    var tickerList = [[UIButton]]()
    
    var ideasList = [[Any]]()
    var userIdeasList = [[Any]]()
    var yourIdeas = true
    
    var filterText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        shortButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
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
        
        ideasPicker.delegate = self
        ideasPicker.dataSource = self
        ideasPicker.backgroundColor = UIColor.black
        ideasPicker.transform = CGAffineTransform(rotationAngle: -90 * (.pi/180))
        ideasPicker.frame = CGRect(x: 0.15*width, y: 0.125*height+3, width: width*0.65, height: 0.09*height-3)
        view.addSubview(ideasPicker)
        
        subtractButton.frame = CGRect(x: 0.05*width, y: 0.14*height+1.5, width: width*0.12, height: 0.06*height)
        subtractButton.backgroundColor = UIColor.white
        subtractButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 50)
        subtractButton.layer.cornerRadius = 10
        subtractButton.setTitleColor(backBlue, for: .normal)
        subtractButton.setTitle("-",for: .normal)
        subtractButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        subtractButton.addTarget(self, action: #selector(self.downsizeButton(_:)), for: .touchDown)
        subtractButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpInside)
        subtractButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpOutside)
        view.addSubview(subtractButton)
        
        addButton.frame = CGRect(x: 0.83*width, y: 0.14*height+1.5, width: width*0.12, height: 0.06*height)
        addButton.backgroundColor = UIColor.white
        addButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 50)
        addButton.layer.cornerRadius = 10
        addButton.setTitleColor(backBlue, for: .normal)
        addButton.setTitle("+",for: .normal)
        addButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(self.downsizeButton(_:)), for: .touchDown)
        addButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(self.upsizeButton(_:)), for: .touchUpOutside)
        view.addSubview(addButton)
        
        let midLine = UILabel()
        midLine.frame = CGRect(x: 0.03*width, y: 0.215*height, width: width*0.94, height: 3)
        midLine.backgroundColor = UIColor.white
        view.addSubview(midLine)
        
        let searchBackground = UILabel()
        searchBackground.frame = CGRect(x: 0.15*width + height*0.06, y: 0.235*height, width: width*0.6, height: height*0.06)
        searchBackground.backgroundColor = UIColor.gray
        searchBackground.layer.cornerRadius = searchBackground.frame.height/2
        searchBackground.clipsToBounds = true
        view.addSubview(searchBackground)
        
        searchField.frame = CGRect(x: 0.2*width + height*0.06, y: 0.235*height, width: width*0.5, height: height*0.06)
        searchField.backgroundColor = UIColor.gray
        searchField.textColor = UIColor.white
        searchField.attributedPlaceholder = NSAttributedString(string: "Search by Ticker", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        searchField.addTarget(self, action: #selector(IdeasController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        searchField.autocorrectionType = .no
        searchField.returnKeyType = UIReturnKeyType.done
        view.addSubview(searchField)
        
        let searchImage = UIImage(named: "searchicon.png")
        let searchImageView = UIImageView(image: searchImage)
        searchImageView.frame = CGRect(x: width*0.1, y: height*0.235, width: height*0.06, height: height*0.06)
        self.view.addSubview(searchImageView)
        
        let footerLine = UILabel()
        footerLine.frame = CGRect(x: 0.03*width, y: 0.315*height, width: width*0.94, height: 3)
        footerLine.backgroundColor = UIColor.white
        view.addSubview(footerLine)
        
        let tickerCol = UILabel()
        tickerCol.frame = CGRect(x: 0.03*width, y: 0.325*height, width: width*0.25, height: 0.05*height)
        tickerCol.font =  UIFont(name: "EBGaramond08-Regular", size: 20)
        tickerCol.text = "Ticker:"
        tickerCol.textColor = UIColor.white
        tickerCol.textAlignment = .center
        view.addSubview(tickerCol)
        
        let col2 = UILabel()
        col2.frame = CGRect(x: 0.31*width, y: 0.325*height, width: width*0.2, height: 0.05*height)
        col2.font =  UIFont(name: "EBGaramond08-Regular", size: 20)
        col2.text = "Status:"
        col2.textColor = UIColor.white
        col2.textAlignment = .center
        view.addSubview(col2)
        
        let col3 = UILabel()
        col3.frame = CGRect(x: 0.54*width, y: 0.325*height, width: width*0.2, height: 0.05*height)
        col3.font =  UIFont(name: "EBGaramond08-Regular", size: 20)
        col3.text = "Price:"
        col3.textColor = UIColor.white
        col3.textAlignment = .center
        view.addSubview(col3)

        let col4 = UILabel()
        col4.frame = CGRect(x: 0.77*width, y: 0.325*height, width: width*0.2, height: 0.05*height)
        col4.font =  UIFont(name: "EBGaramond08-Regular", size: 20)
        //col4.text = "Change:"
        col4.text = "Target:"
        col4.textColor = UIColor.white
        col4.textAlignment = .center
        view.addSubview(col4)
        
        let footerLine2 = UILabel()
        footerLine2.frame = CGRect(x: 0.03*width, y: 0.375*height, width: width*0.94, height: 3)
        footerLine2.backgroundColor = UIColor.white
        view.addSubview(footerLine2)
        
        scrollView.frame = CGRect(x: 0, y: 0.38*height+13, width: width, height: 0.57*height-13)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        searchField.delegate = self
        
        getData()
    }
    
    func presentList(list: [[Any]]) {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        var tempItems = [[UILabel]]()
        var tempStatuses = [UIPickerView]()
        var tempTickers = [[UIButton]]()
        
        removeListFromView()
        
        var increment = CGFloat(0.105)*height
        if yourIdeas == false {
            increment = CGFloat(0.135)*height
        }
    
        print("LIST: \(list.count)")
        scrollView.contentSize = CGSize(width: width*0.94, height: (increment+21)*CGFloat(list.count) - 21)
        
        if list.count == 0 { return }
                
        var index = 0
        
        for i in 0...list.count-1 {
            let validCompare = (list[i][1] as! String).count > filterText.count
            if (filterText == "" || (validCompare && (list[i][1] as! String).lowercased().range(of: filterText.lowercased()) != nil)
                || (list[i][1] as! String).lowercased() == filterText.lowercased()) {
                var temporaryArr = [UILabel]()
                var temporaryTickersArr = [UIButton]()
        
                let ticker = UIButton()
                ticker.frame = CGRect(x: 0.03*width, y: (increment+21)*CGFloat(index), width: 0.25*width, height: height*0.08)
                ticker.setTitle((list[i][1] as! String),for: .normal)
                ticker.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 30)
                ticker.setTitleColor(UIColor.white, for: .normal)
                temporaryTickersArr.append(ticker)
                scrollView.addSubview(ticker)
                
                let statusPicker = UIPickerView()
                statusPicker.frame = CGRect(x: 0.31*width, y: (increment+21)*CGFloat(index)-height*0.0075, width: 0.2*width, height: height*0.095)
                statusPicker.dataSource = self
                statusPicker.delegate = self
                scrollView.addSubview(statusPicker)
                var statusNum = 0
                if (list[i][5] as! String == "Memo") { statusNum = 1 }
                if (list[i][5] as! String == "In Fund") { statusNum = 2 }
                statusPicker.selectRow(statusNum, inComponent: 0, animated: true)
                tempStatuses.append(statusPicker)
                
            
                let price = UILabel()
                price.frame = CGRect(x: 0.54*width, y: (increment+21)*CGFloat(index), width: 0.2*width, height: height*0.08)
                price.text = "\(list[i][7] as! String)"
                price.font =  UIFont(name: "EBGaramond08-Regular", size: 22)
                price.textColor = UIColor.white
                price.textAlignment = .center
                temporaryArr.append(price)
                scrollView.addSubview(price)
            
                let change = UILabel()
                change.frame = CGRect(x: 0.77*width, y: 0.01*height + (increment+21)*CGFloat(index), width: 0.2*width, height: height*0.06)
                change.layer.cornerRadius = 5
                change.clipsToBounds = true
                change.text = "\(list[i][6] as! String)"
                if (list[i][6] as! String == "") {
                    change.text = "N/A"
                }
                change.font =  UIFont(name: "EBGaramond08-Regular", size: 22)
                change.textColor = UIColor.white
                change.textAlignment = .center
                temporaryArr.append(change)
                scrollView.addSubview(change)
            
                let industry = UILabel()
                industry.frame = CGRect(x: 0.03*width, y: (increment+21)*CGFloat(index)+height*0.08, width: 0.94*width, height: height*0.025)
                industry.text = "Industry:   \(list[i][3] as! String)"
                industry.font =  UIFont(name: "EBGaramond08-Regular", size: 18)
                industry.textColor = UIColor.white
                industry.textAlignment = .center
                industry.layer.borderColor = UIColor.white.cgColor
                temporaryArr.append(industry)
                scrollView.addSubview(industry)
            
                if yourIdeas == false {
                    let officer = UILabel()
                    officer.frame = CGRect(x: 0.03*width, y: (increment+21)*CGFloat(index)+height*0.11, width: 0.94*width, height: height*0.025)
                    officer.text = "Officer:   \(list[i][0] as! String)"
                    officer.font =  UIFont(name: "EBGaramond08-Regular", size: 18)
                    officer.textColor = UIColor.white
                    officer.textAlignment = .center
                    officer.layer.borderColor = UIColor.white.cgColor
                    temporaryArr.append(officer)
                    scrollView.addSubview(officer)
                }
            
                if i != list.count-1 {
                    let dividerLine = UILabel()
                    dividerLine.frame = CGRect(x: 0.05*width, y: (increment+21)*CGFloat(index)+(increment)+10, width: width*0.9, height: 1)
                    dividerLine.backgroundColor = UIColor.white
                    temporaryArr.append(dividerLine)
                    scrollView.addSubview(dividerLine)
                }
                tempItems.append(temporaryArr)
                tempTickers.append(temporaryTickersArr)
                index += 1
            }
        }
        //scrollView.contentSize = CGSize(width: width*0.94, height: (increment+21)*CGFloat(tempItems.count / 2) - 21)
        view.addSubview(scrollView)
        
        scrollItemList = tempItems
        statusList = tempStatuses
        tickerList = tempTickers
        
        /**for i in 0...scrollItemList.count - 1 {
            print("COUNT: \(scrollItemList[i].count)")
            if scrollItemList[i].count != 0 {
                getBackupStockData(ticker: list[(i-1) / 2][1] as! String, numStock: i)
            }
        }*/
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
        for status in statusList {
            status.removeFromSuperview()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === ideasPicker {
            return listOptions.count
        } else if pickerView === sectorPicker {
            return sectorOptions.count
        }
        return statusOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === ideasPicker {
            return listOptions[row]
        } else if pickerView === sectorPicker {
            return sectorOptions[row]
        } else {
            return statusOptions[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if pickerView === ideasPicker {
            return self.view.frame.width*0.3
        } else if pickerView === sectorPicker {
            return self.view.frame.height*0.04
        }
        return self.view.frame.height*0.03
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if pickerView === ideasPicker {
            return self.view.frame.height*0.09 - 3
        } else if pickerView === sectorPicker {
            return self.view.frame.width*0.75
        }
        return self.view.frame.width*0.2
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        let view = UIView()
        if pickerView === ideasPicker {
            view.frame = CGRect(x: 0, y: 0, width: width*0.3, height: 0.09*height-3)
        
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            label.numberOfLines = 2
            label.font = UIFont.systemFont(ofSize: 25)
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.text = listOptions[row]
            view.addSubview(label)
        
            view.transform = CGAffineTransform(rotationAngle: 90 * (.pi/180))
        } else if pickerView === sectorPicker {
            view.frame = CGRect(x: 0, y: 0, width: width*0.75, height: 0.05*height)
        
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            label.numberOfLines = 2
            label.font =  UIFont(name: "EBGaramond08-Regular", size: 22)
            label.textColor = UIColor.black
            label.textAlignment = .center
            label.text = sectorOptions[row]
            view.addSubview(label)
        } else {
            view.frame = CGRect(x: 0, y: 0, width: width*0.2, height: 0.03*height)
        
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            label.numberOfLines = 1
            label.font =  UIFont(name: "EBGaramond08-Regular", size: 22)
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.text = statusOptions[row]
            view.addSubview(label)
        }
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = listOptions[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "EBGaramond08-Regular", size: 15)!,NSAttributedStringKey.foregroundColor:UIColor.white])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView === ideasPicker {
            if (row == 0) {
                yourIdeas = true
            } else  {
                yourIdeas = false
            }
            print("yourIdeas: \(yourIdeas)")
            getData()
        } else if pickerView === sectorPicker {
            selectedSector = sectorOptions[row]
        } else {
            for i in 0...statusList.count - 1 {
                if statusList[i] === pickerView {
                    print(tickerList[i][0].titleLabel!.text!)
                    changeStockStatus(rowNum: findStockRow(ticker: tickerList[i][0].titleLabel!.text!), status: statusOptions[row])
                }
            }
        }
    }
    
    func changeStockStatus(rowNum: Int, status: String) {
        let sheetID = "1Soz0VuMGLn1pXam2qwQ3tyhOPhTNkicXOGdSAkOyrf4"
        let currentRow = rowNum + 2
        var range = "Longs!F\(currentRow)"
        if !showLongs {
            range = "Shorts!F\(currentRow)"
        }
        let requestParams = [ "values": [ [status] ] ]
        let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken!
        let header = ["Authorization":"Bearer \(accessToken)"]
        let requestURL = "https://sheets.googleapis.com/v4/spreadsheets/\(sheetID)/values/\(range)?valueInputOption=USER_ENTERED"
        Alamofire.request(requestURL, method: .put, parameters: requestParams, encoding: JSONEncoding.default, headers: header)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        filterText = textField.text as! String
        getData()
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        print("Done Pressed")
        self.view.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
    
    func getData() {
        let spreadsheetId = "1Soz0VuMGLn1pXam2qwQ3tyhOPhTNkicXOGdSAkOyrf4" // Portfolio
        var range = "Longs!A2:I"
        if !showLongs {
            range = "Shorts!A2:I"
        }
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
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "name") != nil {
            let temp = (userDefaults.object(forKey: "name") as! NSString!)
            name = temp!.substring(to: temp!.length)
        }
        
        var tempUserList = [[Any]]()
        var tempIdeasList = [[Any]]()
        
        
        for row in data {
            tempIdeasList.append(row)
            if namesEqual(fullName: name, abbreviated: row[0] as! String) {
                tempUserList.append(row)
                abbreviatedName = row[0] as! String
            } else {
                if name == "Nicholas Palmer" && (row[0] as! String) == "Nick P." {
                    tempUserList.append(row)
                }
            }
        }
        
        userIdeasList = tempUserList
        ideasList = tempIdeasList
        
        if yourIdeas {
            print("userIdeas: \(userIdeasList.count)")
            presentList(list: userIdeasList)
        } else {
            print("ideasList: \(ideasList.count)")
            presentList(list: ideasList)
        }
    }
    
    /**func getBackupStockData(ticker: String, numStock: Int) {
        let ticker_clean = ticker.replacingOccurrences(of: " ", with: "")
        let myURLString = "https://finance.yahoo.com/quote/\(ticker_clean.uppercased())"
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return
        }

        do {
            var HTMLString = try String(contentsOf: myURL, encoding: .ascii)
            let range = HTMLString.range(of: "Trsdu(0.3s) F")
            let endPos = HTMLString.distance(from: HTMLString.startIndex, to: range!.upperBound)
            HTMLString = "\(HTMLString.prefix(endPos + 201))"
            HTMLString = "\(HTMLString.suffix(176))"
            
            let startPrice = HTMLString.index(of: ">")!
            let endPrice = HTMLString.index(of: "<")!
            let priceDistance = HTMLString.distance(from: HTMLString.startIndex, to: endPrice)
            let priceLength = HTMLString.distance(from: startPrice, to: endPrice)
            var priceString = HTMLString.prefix(priceDistance)
            priceString = priceString.suffix(priceLength - 1)
            print("priceString \(ticker_clean): \(priceString)")
            scrollItemList[numStock][1].text = "$\(priceString)"
            
            var changeString = HTMLString.suffix(40)
            let startChange = changeString.index(of: "(")!
            let endChange = changeString.index(of: ")")!
            let changeDistance = changeString.distance(from: changeString.startIndex, to: endChange)
            let changeLength = changeString.distance(from: startChange, to: endChange)
            if (changeLength - 1 < 0) {
                print("changeString: \(changeString)")
            }
            changeString = changeString.prefix(changeDistance)
            changeString = changeString.suffix(changeLength - 1)
            print("changeString \(ticker): \(changeString)")
            scrollItemList[numStock][2].text = "\(changeString)"
            if Double(changeString.prefix(changeString.count - 1))! >= 0.0 {
                scrollItemList[numStock][2].backgroundColor = green
            } else {
                scrollItemList[numStock][2].backgroundColor = red
            }
            
        } catch let error {
            print("Error: \(error)")
        }
    } */
    
    func namesEqual(fullName: String, abbreviated: String) -> Bool {
        var equal = true
        let fullArr = Array(fullName)
        let abbreviatedArr = Array(abbreviated)
        for i in 0...abbreviated.count-1 {
            if i == fullName.count - 1 || (i == abbreviated.count-1 && abbreviatedArr[i] == " "){
                break
            }
            if abbreviatedArr[i] != fullArr[i] && abbreviatedArr[i] != "." {
                equal = false
                break
            }
        }
        return equal
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
        if sender === longButton {
            print("long")
            if showLongs { return }
            makeButtonLight(button: longButton)
            makeButtonDark(button: shortButton)
            showLongs = true
            getData()
        }
        if sender === shortButton {
            print("short")
            if !showLongs { return }
            makeButtonLight(button: shortButton)
            makeButtonDark(button: longButton)
            showLongs = false
            getData()
        }
        if sender === backButton {
            //self.present(loginParent!, animated: true, completion: nil)
            print("back")
            let menuController = MenuController()
            self.present(menuController, animated: true, completion: nil)
        }
        if sender === addButton {
            addStock()
        }
        if sender === subtractButton {
            subtractStock()
        }
    }
    
    func changeStatusAlert(numStock: Int) {    
        let ticker = tickerList[numStock][0].titleLabel!.text!
        let alert = UIAlertController(title: "\(ticker)", message: "Change Status of Stock", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addStock() {
        let alert = UIAlertController(title: "New Stock", message: "Pick a sector:\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        let width = alert.view.frame.width
        let height = alert.view.frame.height

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addTextField { (textField) in textField.placeholder = "Enter Ticker" 
        }
        alert.addTextField { (textField) in textField.placeholder = "Enter Company Name" }
        alert.addTextField { (textField) in textField.placeholder = "Enter Industry" }
        
        sectorPicker = UIPickerView(frame: CGRect(x: 0, y: 60, width: 260, height: 162))
        sectorPicker.dataSource = self
        sectorPicker.delegate = self
        alert.view.addSubview(sectorPicker)
        
        alert.addTextField { (textField) in textField.placeholder = "Enter Price Target   (Optional)" }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let tickerField = alert!.textFields![0]
            let companyField = alert!.textFields![1]
            let industryField = alert!.textFields![2]
            let priceTargetField = alert!.textFields![3]
            for field in alert!.textFields! {
                if field != priceTargetField && field.text == "" {
                    self.raiseLackInfoAlert()
                    return
                }
            }
            self.writeStockToSheet( ticker: tickerField.text!, company: companyField.text!, industry: industryField.text!, 
                                    sector: self.selectedSector, priceTarget: priceTargetField.text!)
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func raiseSuccessfulAddAlert() {
        let alert = UIAlertController(title: "Done!", message: "Stock was successfully added", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in self.getData() }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func raiseLackInfoAlert() {
        let alert = UIAlertController(title: "Error", message: "Not all required fields were filled", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func writeStockToSheet(ticker: String, company: String, industry: String, sector: String, priceTarget: String) {
        let newStock = [   "\(self.abbreviatedName)", ticker.uppercased(), company, industry, sector, "Idea", priceTarget, 
                            "=GOOGLEFINANCE(B\(100),\"price\")", "=G\(100)/H\(100)-1"]
        ideasList.append(newStock)
        sortIdeas()
        let newRow = findStockRow(ticker: ticker.uppercased())
        ideasList[newRow][7] = "=GOOGLEFINANCE(B\(newRow + 2),\"price\")"
        ideasList[newRow][8] = "=G\(newRow + 2)/H\(newRow + 2)-1"
        usleep(1000000)
        print(ideasList.count)
        for i in 0...ideasList.count - 1 {
            ideasList[i][7] = "=GOOGLEFINANCE(B\(i + 2),\"price\")"
            if ideasList[i].count > 8 {
                ideasList[i][8] = "=G\(i + 2)/H\(i + 2)-1"
            }
        }
        rewriteMasterList()
        //usleep(1000000)
        //getData()
        raiseSuccessfulAddAlert()
    }
    
    func rewriteMasterList() {
        let sheetID = "1Soz0VuMGLn1pXam2qwQ3tyhOPhTNkicXOGdSAkOyrf4"
        let currentRow = ideasList.count + 3
        var range = "Longs!A2:I\(currentRow)"
        if !showLongs {
            range = "Shorts!A2:I\(currentRow)"
        }
        let requestParams = [ "values": ideasList ]
        let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken!
        let header = ["Authorization":"Bearer \(accessToken)"]
        let requestURL = "https://sheets.googleapis.com/v4/spreadsheets/\(sheetID)/values/\(range)?valueInputOption=USER_ENTERED"
        Alamofire.request(requestURL, method: .put, parameters: requestParams, encoding: JSONEncoding.default, headers: header)
    }
    
    func subtractStock() {
        let alert = UIAlertController(title: "Remove Stock", message: "To be removed from the Masterlist", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addTextField { (textField) in textField.placeholder = "Enter Ticker" }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let tickerField = alert!.textFields![0]
            if tickerField.text == "" {
                self.raiseLackInfoAlert()
                return
            }
            self.removeStockFromSheet(ticker: tickerField.text!)
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func removeStockFromSheet(ticker: String) {
        let currentRow = findStockRow(ticker: ticker)
        print("RemoveFromRow: \(currentRow)")
        if currentRow == -1 {
            raiseNotFoundAlert()
            return
        }
        print(ideasList[currentRow])
        ideasList.remove(at: currentRow)
        sortIdeas()
        usleep(1000000)
        for i in 0...ideasList.count - 1 {
            ideasList[i][7] = "=GOOGLEFINANCE(B\(i + 2),\"price\")"
            if ideasList[i].count > 8 {
                ideasList[i][8] = "=G\(i + 2)/H\(i + 2)-1"
            }
        }
        ideasList.append([   "", "", "", "", "", "", "", "", ""   ])
        rewriteMasterList()
        //usleep(1000000)
        //getData()
        raiseSuccessfulSubtractAlert()
    }
    
    func findStockRow(ticker: String) -> Int {
        for i in 0...ideasList.count-1 {
            if ideasList[i][1] as! String == ticker {
                return i
            }
        }
        return -1
    }
    
    func raiseSuccessfulSubtractAlert() {
        let alert = UIAlertController(title: "Done!", message: "Stock was successfully removed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in self.getData() }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func raiseNotFoundAlert() {
        let alert = UIAlertController(title: "Error", message: "Ticker was not found", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sortIdeas() {
        ideasList.sort { 
            if $0[0] as! String == "" { return false }
            if $0[0] as! String != $1[0] as! String {
                return ($0[0] as! String) < ($1[0] as! String)
            } else {
                return ($0[1] as! String) < ($1[1] as! String)
            }
        }
    }
    
    func numToLetter(numCol: Int) -> String {
        if numCol < 0 { return "" }
        if numCol < 26 {
            let startingValue = Int(("A" as UnicodeScalar).value)
            return "\(Character(UnicodeScalar(numCol + startingValue)!))"
        }
        let startingValue = Int(("A" as UnicodeScalar).value)
        let first = Character(UnicodeScalar((numCol % 26) + startingValue)!)
        return "\(numToLetter(numCol: (numCol / 26)-1))\(first)"
    }
    
    @objc func dismissKeyboard() {
        print("Tap Exit")
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
















