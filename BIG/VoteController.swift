//
//  VoteController.swift
//  BIG
//
//  Created by Jeffrey Chen on 5/30/18.
//  Copyright © 2018 Jeffrey Chen. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

import Alamofire

class VoteController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets]

    private let service = GTLRSheetsService()
    
    let backButton = UIButton()
    
    var townHallsHeldLabel = UILabel()
    var votesHeldLabel = UILabel()
    var averageVotesLabel = UILabel()
    var averageRepLabel = UILabel()
    
    var currentTextField = UITextField()
    
    let townHallsField = UITextField()
    let memosField = UITextField()
    let pitchesField = UITextField()
    let updatesField = UITextField()
    
    var userVotes = UILabel()
    
    var userVotingData = [Any]()
    var averageVotingData = [Any]()
    var totalVotingData = [Any]()
    var name = ""
    
    let green = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
    let red = UIColor(red: 0.8, green: 0, blue: 0, alpha: 1)
    
    var recordData = [[Any]]()
    var voteParticipationRow = 0
    var userVoteRow = 0
    
    var rejectButton = UIButton()
    var abstainButton = UIButton()
    var passButton = UIButton()
    
    var scrollView = UIScrollView()
    var pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()

        let width = self.view.frame.width
        let height = self.view.frame.height
        self.view.backgroundColor = UIColor.black
        
        let backBlue = UIColor(red: CGFloat(0), green: CGFloat(0.5), blue: CGFloat(1), alpha: 1.0)
        
        let backArrow = UIButton()
        backArrow.frame = CGRect(x: 0.05*width, y: 0.045*height, width: width*0.05, height: height*0.07)
        backArrow.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 50)
        backArrow.backgroundColor = UIColor.black
        backArrow.setTitleColor(backBlue, for: .normal)
        backArrow.setTitle("<",for: .normal)
        backArrow.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        view.addSubview(backArrow)

        backButton.frame = CGRect(x: 0.091*width, y: 0.05*height, width: width*0.14, height: height*0.06)
        backButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 22.5)
        backButton.backgroundColor = UIColor.black
        backButton.setTitleColor(backBlue, for: .normal)
        backButton.setTitle("Back",for: .normal)
        backButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        view.addSubview(backButton)
        
        townHallsHeldLabel.frame = CGRect(x: 0.3*width, y: 0.05*height, width: width*0.32, height: height*0.06)
        townHallsHeldLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 20)
        townHallsHeldLabel.text = "Town Halls:  0"
        townHallsHeldLabel.textColor = UIColor.white
        townHallsHeldLabel.textAlignment = .left
        view.addSubview(townHallsHeldLabel)     
           
        votesHeldLabel.frame = CGRect(x: 0.65*width, y: 0.05*height, width: width*0.32, height: height*0.06)
        votesHeldLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 20)
        votesHeldLabel.text = "Votes Held:  0"
        votesHeldLabel.textColor = UIColor.white
        votesHeldLabel.textAlignment = .left
        view.addSubview(votesHeldLabel)
        
        let headerLine = UILabel()
        headerLine.frame = CGRect(x: 0.03*width, y: 0.125*height, width: width*0.94, height: 3)
        headerLine.backgroundColor = UIColor.white
        view.addSubview(headerLine)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        let THLabel = UILabel()
        THLabel.frame = CGRect(x: 0.045*width, y: 0.14*height+3, width: width*0.205, height: height*0.03)
        THLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 20)
        THLabel.text = "THs"
        THLabel.textColor = UIColor.white
        THLabel.textAlignment = .center
        view.addSubview(THLabel)
        townHallsField.frame = CGRect(x: 0.06*width, y: 0.18*height+3, width: width*0.175, height: height*0.03)
        townHallsField.textColor = UIColor.white
        townHallsField.text = "10"
        townHallsField.font = UIFont(name: "EBGaramond08-Regular", size: 22)
        townHallsField.addTarget(self, action: #selector(VoteController.textFieldDidBeginEditing(_:)), for: UIControlEvents.editingDidBegin)
        townHallsField.addTarget(self, action: #selector(VoteController.textFieldDidEndEditing(_:reason:)), for: UIControlEvents.editingDidEnd)
        townHallsField.delegate = self
        townHallsField.autocorrectionType = .no
        townHallsField.textAlignment = NSTextAlignment.center 
        townHallsField.returnKeyType = UIReturnKeyType.done
        townHallsField.addGestureRecognizer(tap)
        view.addSubview(townHallsField)
        
        let invstMemos = UILabel()
        invstMemos.frame = CGRect(x: 0.275*width, y: 0.14*height+3, width: width*0.205, height: height*0.03)
        invstMemos.font =  UIFont(name: "EBGaramond08-Regular", size: 20)
        invstMemos.text = "Memos"
        invstMemos.textColor = UIColor.white
        invstMemos.textAlignment = .center
        view.addSubview(invstMemos)
        memosField.frame = CGRect(x: 0.275*width, y: 0.18*height+3, width: width*0.205, height: height*0.03)
        memosField.textColor = UIColor.white
        memosField.text = "11"
        memosField.font = UIFont(name: "EBGaramond08-Regular", size: 22)
        memosField.addTarget(self, action: #selector(VoteController.textFieldDidBeginEditing(_:)), for: UIControlEvents.editingDidBegin)
        memosField.addTarget(self, action: #selector(VoteController.textFieldDidEndEditing(_:reason:)), for: UIControlEvents.editingDidEnd)
        memosField.delegate = self
        memosField.autocorrectionType = .no
        memosField.textAlignment = NSTextAlignment.center 
        memosField.returnKeyType = UIReturnKeyType.done
        memosField.addGestureRecognizer(tap)
        view.addSubview(memosField)
        
        let pitches = UILabel()
        pitches.frame = CGRect(x: 0.51*width, y: 0.14*height+3, width: width*0.205, height: height*0.03)
        pitches.font =  UIFont(name: "EBGaramond08-Regular", size: 20)
        pitches.text = "Pitches"
        pitches.textColor = UIColor.white
        pitches.textAlignment = .center
        view.addSubview(pitches)
        pitchesField.frame = CGRect(x: 0.51*width, y: 0.18*height+3, width: width*0.205, height: height*0.03)
        pitchesField.textColor = UIColor.white
        pitchesField.text = "12"
        pitchesField.font = UIFont(name: "EBGaramond08-Regular", size: 22)
        pitchesField.addTarget(self, action: #selector(VoteController.textFieldDidBeginEditing(_:)), for: UIControlEvents.editingDidBegin)
        pitchesField.addTarget(self, action: #selector(VoteController.textFieldDidEndEditing(_:reason:)), for: UIControlEvents.editingDidEnd)
        pitchesField.delegate = self
        pitchesField.autocorrectionType = .no
        pitchesField.textAlignment = NSTextAlignment.center 
        pitchesField.returnKeyType = UIReturnKeyType.done
        pitchesField.addGestureRecognizer(tap)
        view.addSubview(pitchesField)
        
        let updates = UILabel()
        updates.frame = CGRect(x: 0.745*width, y: 0.14*height+3, width: width*0.205, height: height*0.03)
        updates.font =  UIFont(name: "EBGaramond08-Regular", size: 20)
        updates.text = "Updates"
        updates.textColor = UIColor.white
        updates.textAlignment = .center
        view.addSubview(updates)
        updatesField.frame = CGRect(x: 0.745*width, y: 0.18*height+3, width: width*0.205, height: height*0.03)
        updatesField.textColor = UIColor.white
        updatesField.text = "13"
        updatesField.font = UIFont(name: "EBGaramond08-Regular", size: 22)
        updatesField.addTarget(self, action: #selector(VoteController.textFieldDidBeginEditing(_:)), for: UIControlEvents.editingDidBegin)
        updatesField.addTarget(self, action: #selector(VoteController.textFieldDidEndEditing(_:reason:)), for: UIControlEvents.editingDidEnd)
        updatesField.delegate = self
        updatesField.autocorrectionType = .no
        updatesField.textAlignment = NSTextAlignment.center 
        updatesField.returnKeyType = UIReturnKeyType.done
        updatesField.addGestureRecognizer(tap)
        view.addSubview(updatesField)
        
        currentTextField = townHallsField
        
        let separatorLine1 = UILabel()
        separatorLine1.frame = CGRect(x: 0.03*width, y: 0.225*height+3, width: width*0.94, height: 3)
        separatorLine1.backgroundColor = UIColor.white
        view.addSubview(separatorLine1)
        
        userVotes.frame = CGRect(x: 0.03*width, y: 0.24*height+3, width: width*0.94, height: height*0.045)
        userVotes.font =  UIFont(name: "EBGaramond08-Regular", size: 18)
        userVotes.text = "Your Votes:  0"
        userVotes.textColor = UIColor.white
        userVotes.textAlignment = .center
        view.addSubview(userVotes)
        
        let separatorLine2 = UILabel()
        separatorLine2.frame = CGRect(x: 0.03*width, y: 0.29*height+3, width: width*0.94, height: 3)
        separatorLine2.backgroundColor = UIColor.white
        view.addSubview(separatorLine2)
        
        scrollView.delegate = self
        scrollView.frame = CGRect(x: 0.03*width, y: 0.32*height, width: width*0.94, height: 0.395*height)
        
        pageControl.frame = CGRect(x: 0.03*width, y: 0.69*height, width: width*0.94, height: 0.075*height)
        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)
        
        rejectButton.frame = CGRect(x: 0.03*width, y: 0.775*height, width: width*0.28, height: height*0.075)
        rejectButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
        rejectButton.backgroundColor = red
        rejectButton.layer.cornerRadius = 5
        rejectButton.clipsToBounds = true
        rejectButton.setTitleColor(UIColor.white, for: .normal)
        rejectButton.setTitle("Reject",for: .normal)
        rejectButton.addTarget(self, action: #selector(self.chooseReject(_:)), for: .touchDown)
        rejectButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        view.addSubview(rejectButton)
        
        abstainButton.frame = CGRect(x: 0.36*width, y: 0.775*height, width: width*0.28, height: height*0.075)
        abstainButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
        abstainButton.backgroundColor = UIColor.gray
        abstainButton.layer.cornerRadius = 5
        abstainButton.clipsToBounds = true
        abstainButton.setTitleColor(UIColor.white, for: .normal)
        abstainButton.setTitle("Abstain",for: .normal)
        abstainButton.addTarget(self, action: #selector(self.chooseAbstain(_:)), for: .touchDown)
        abstainButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        view.addSubview(abstainButton)
        
        passButton.frame = CGRect(x: 0.69*width, y: 0.775*height, width: width*0.28, height: height*0.075)
        passButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
        passButton.backgroundColor = green
        passButton.layer.cornerRadius = 5
        passButton.clipsToBounds = true
        passButton.setTitleColor(UIColor.white, for: .normal)
        passButton.setTitle("Pass",for: .normal)
        passButton.addTarget(self, action: #selector(self.choosePass(_:)), for: .touchDown)
        passButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        view.addSubview(passButton)
        
        let footerLine = UILabel()
        footerLine.frame = CGRect(x: 0.03*width, y: 0.89*height, width: width*0.94, height: 3)
        footerLine.backgroundColor = UIColor.white
        view.addSubview(footerLine)
        
        averageVotesLabel = UILabel()
        averageVotesLabel.frame = CGRect(x: 0.03*width, y: 0.905*height+3, width: width*0.94, height: height*0.03)
        averageVotesLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 20)
        averageVotesLabel.text = "Average Votes per Officer:   1"
        averageVotesLabel.textColor = UIColor.white
        averageVotesLabel.textAlignment = .center
        self.view.addSubview(averageVotesLabel)
        
        averageRepLabel = UILabel()
        averageRepLabel.frame = CGRect(x: 0.03*width, y: 0.945*height+3, width: width*0.94, height: height*0.03)
        averageRepLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 20)
        averageRepLabel.text = "Average Representation per Officer:   2.5%"
        averageRepLabel.textColor = UIColor.white
        averageRepLabel.textAlignment = .center
        self.view.addSubview(averageRepLabel)
        
        let userDefaults = UserDefaults.standard
        name = userDefaults.value(forKey: "name") as! String
    
        getVoteCalc()
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        self.pageControl.numberOfPages = recordData[0].count - 1
        self.pageControl.currentPage = recordData[0].count - 2
        changePage(sender: pageControl)
        self.pageControl.tintColor = UIColor.red
        self.pageControl.pageIndicatorTintColor = UIColor.gray
        self.pageControl.currentPageIndicatorTintColor = UIColor.white
        self.view.addSubview(pageControl)
        changeButtons()
    }

    @objc func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        changeButtons()
        print("CurrentCol: \(numToLetter(numCol: pageControl.currentPage + 2))")
        print(recordData[userVoteRow])
    }
    
    func changeButtons() {
        let votingFinished = recordData[voteParticipationRow - 2][pageControl.currentPage + 1] as! String
        let userVote = "\(recordData[userVoteRow][pageControl.currentPage + 1])"
        if userVote == "1" {
            choosePass(_: passButton)
        } else if userVote == "-1" {
            chooseReject(_: rejectButton)
        } else if userVote == "0" && votingFinished != "N/A" {
            chooseAbstain(_: abstainButton)
        } else {
            resetChoiceButtons()
        }
    }

    func getVoteCalc() {
        let spreadsheetId = "1uFzXgwJmmsAqTrkEC1mil7fAvieLgU82TAlWMDmN8wo"
        let range = "Vote Calc - Summer '18!B3:M"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query, delegate: self, didFinish: #selector(displayVotesWithTicket(ticket:finishedWithObject:error:)))
    }

    func getVoteRecord() {
        let spreadsheetId = "1uFzXgwJmmsAqTrkEC1mil7fAvieLgU82TAlWMDmN8wo"
        let range = "Record - Summer '18!B2:AR"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query, delegate: self, didFinish: #selector(displayRecordWithTicket(ticket:finishedWithObject:error:)))
    }

    // Process the response and display output
    @objc func displayVotesWithTicket(ticket: GTLRServiceTicket, finishedWithObject result : GTLRSheets_ValueRange, error : NSError?) {

        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        let data = result.values!        
        if data.isEmpty {
            print("no data found")
            return
        }
        
        townHallsHeldLabel.text = "Town Halls:  \(data[1][10])"
        votesHeldLabel.text = "Votes Held:  \(data[0][10])"
        for i in 3...(data.count - 1) {
            if (data[i][0] as! String == name) {
                userVotingData = data[i]
                townHallsField.text = "\(data[i][1])"
                memosField.text = "\(data[i][2])"
                pitchesField.text = "\(data[i][3])"
                updatesField.text = "\(data[i][4])"
                userVotes.text = "Your Votes:  \(data[i][5])          Representation:  \(data[i][7])"
            }
            if (data[i][0] as! String == "Average") {
                averageVotesLabel.text = "Average Votes per Officer:     \(data[i][5])"
                averageRepLabel.text = "Average Representation per Officer:     \(data[i][7])"
                self.view.addSubview(averageVotesLabel)
                self.view.addSubview(averageRepLabel)
            }
            if (data[i][0] as! String == "Total") {
                totalVotingData = data[i]
                break
            }
        }
        getVoteRecord()
        return
    }
    
    @objc func displayRecordWithTicket(ticket: GTLRServiceTicket, finishedWithObject result : GTLRSheets_ValueRange, error : NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        let data = result.values!        
        if data.isEmpty {
            print("no data found")
            return
        }
        
        for i in 0...(data.count-1) {
            if (name == data[i][0] as! String) {
                userVoteRow = i
            }
            if (data[i][0] as! String == "Participation") {
                voteParticipationRow = i
                break
            }
        }
        recordData = data
        drawVoteTopic()
        configurePageControl()
    }
    
    func drawVoteTopic() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        if (recordData[0].count-1 < 0) {
            return
        }
        scrollView.contentSize = CGSize(width: width*0.94*CGFloat(recordData[0].count-1), height: 0.395*height)
        
        for i in 1...recordData[0].count-1 {
            print(recordData[1][i] as! String)
            
            let tickerLabel = UILabel()
            tickerLabel.frame = CGRect(x: 0.94*width*CGFloat(i-1), y: 0, width: width*0.94, height: height*0.125)
            tickerLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 75)
            tickerLabel.text = recordData[1][i] as! String
            tickerLabel.textColor = UIColor.white
            tickerLabel.textAlignment = .center
            scrollView.addSubview(tickerLabel)
            
            let dateLabel = UILabel()
            dateLabel.frame = CGRect(x: 0.94*width*CGFloat(i-1), y: 0.13*height, width: width*0.45, height: height*0.05)
            dateLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
            dateLabel.text = recordData[0][i] as! String
            dateLabel.textColor = UIColor.white
            dateLabel.textAlignment = .center
            scrollView.addSubview(dateLabel)
            
            let discussionLabel = UILabel()
            discussionLabel.frame = CGRect(x: 0.49*width + 0.94*width*CGFloat(i-1), y: 0.13*height, width: width*0.45, height: height*0.05)
            discussionLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
            discussionLabel.text = recordData[3][i] as! String
            discussionLabel.textColor = UIColor.white
            discussionLabel.textAlignment = .center
            scrollView.addSubview(discussionLabel)
            
            let recommendationLabel = UILabel()
            recommendationLabel.frame = CGRect(x: 0.94*width*CGFloat(i-1), y: 0.19*height, width: width*0.94, height: height*0.1)
            recommendationLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 30)
            recommendationLabel.text = "Recommendation:   \(recordData[2][i])"
            recommendationLabel.textColor = UIColor.white
            recommendationLabel.textAlignment = .center
            scrollView.addSubview(recommendationLabel)
            
            let voteResultLabel = UILabel()
            voteResultLabel.frame = CGRect(x: 0.05*width + 0.94*width*CGFloat(i-1), y: 0.305*height, width: width*0.84, height: height*0.075)
            voteResultLabel.font =  UIFont(name: "EBGaramond08-Regular", size: 30)
            voteResultLabel.backgroundColor = UIColor.gray
            let voteResult = recordData[voteParticipationRow - 2][i] as! String
            if voteResult == "N/A" {
                voteResultLabel.text = "Voting In Progress..."
            } else if voteResult == "Approved" {
                voteResultLabel.text = "Approved!"
                voteResultLabel.backgroundColor = green
            } else {
                voteResultLabel.text = "Rejected"
                voteResultLabel.backgroundColor = red
            }
            voteResultLabel.textColor = UIColor.white
            voteResultLabel.layer.cornerRadius = 5
            voteResultLabel.clipsToBounds = true
            voteResultLabel.textAlignment = .center
            scrollView.addSubview(voteResultLabel)
        }
        scrollView.isPagingEnabled = true
        view.addSubview(scrollView)
        print(recordData[userVoteRow])
    }
    
    @objc func chooseReject(_ sender: UIButton) {
        let width = self.view.frame.width
        let height = self.view.frame.height
        rejectButton.frame = CGRect(x: 0.03*width, y: 0.755*height, width: width*0.36, height: height*0.115)
        rejectButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 35)
        abstainButton.frame = CGRect(x: 0.44*width, y: 0.775*height, width: width*0.24, height: height*0.075)
        abstainButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
        passButton.frame = CGRect(x: 0.73*width, y: 0.775*height, width: width*0.24, height: height*0.075)
        passButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
    }
    
    @objc func chooseAbstain(_ sender: UIButton) {
        let width = self.view.frame.width
        let height = self.view.frame.height
        rejectButton.frame = CGRect(x: 0.03*width, y: 0.775*height, width: width*0.24, height: height*0.075)
        rejectButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
        abstainButton.frame = CGRect(x: 0.32*width, y: 0.755*height, width: width*0.36, height: height*0.115)
        abstainButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 35)
        passButton.frame = CGRect(x: 0.73*width, y: 0.775*height, width: width*0.24, height: height*0.075)
        passButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
    }
    
    @objc func choosePass(_ sender: UIButton) {
        let width = self.view.frame.width
        let height = self.view.frame.height
        rejectButton.frame = CGRect(x: 0.03*width, y: 0.775*height, width: width*0.24, height: height*0.075)
        rejectButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
        abstainButton.frame = CGRect(x: 0.32*width, y: 0.775*height, width: width*0.24, height: height*0.075)
        abstainButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
        passButton.frame = CGRect(x: 0.61*width, y: 0.755*height, width: width*0.36, height: height*0.115)
        passButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 40)
    }
    
    func resetChoiceButtons() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        rejectButton.frame = CGRect(x: 0.03*width, y: 0.775*height, width: width*0.28, height: height*0.075)
        rejectButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
        abstainButton.frame = CGRect(x: 0.36*width, y: 0.775*height, width: width*0.28, height: height*0.075)
        abstainButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
        passButton.frame = CGRect(x: 0.69*width, y: 0.775*height, width: width*0.28, height: height*0.075)
        passButton.titleLabel?.font =  UIFont(name: "EBGaramond08-Regular", size: 25)
    }
    
    func writeVote(vote: Int) {
        let sheetID = "1uFzXgwJmmsAqTrkEC1mil7fAvieLgU82TAlWMDmN8wo"
        let range = "Record%20-%20Summer%20'18!\(numToLetter(numCol: pageControl.currentPage + 2))\(userVoteRow + 2)"
        //range = "Record - Summer '18!\(numToLetter(numCol: pageControl.currentPage + 2))\(userVoteRow + 2)"
        let requestParams = [
            "values": [ 
                ["\(vote)"],
                ]
            ]
        let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken!
        let header = ["Authorization":"Bearer \(accessToken)"]
        let requestURL = "https://sheets.googleapis.com/v4/spreadsheets/\(sheetID)/values/\(range)?valueInputOption=USER_ENTERED"
        Alamofire.request(requestURL, method: .put, parameters: requestParams, encoding: JSONEncoding.default, headers: header)
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.currentTextField = textField
    }
     
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        checkFieldNum(textField: textField)
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        dismissKeyboard()
        return true
    }
    
    @objc func dismissKeyboard() {
        checkFieldNum(textField: currentTextField)
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func checkFieldNum(textField: UITextField) {
        let fieldNum = Int(textField.text!)
        if fieldNum == nil {
            if textField == townHallsField {
                townHallsField.text = "\(userVotingData[1])"
            } 
            if textField == memosField {
                memosField.text = "\(userVotingData[2])"
            }
            if textField == pitchesField {
                pitchesField.text = "\(userVotingData[3])"
            }
            if textField == updatesField {
                updatesField.text = "\(userVotingData[4])"
            }
        } else {
            if textField == townHallsField {
                changeParticipation(value: fieldNum!, option: 2)
                userVotingData[1] = fieldNum!
            } 
            if textField == memosField {
                changeParticipation(value: fieldNum!, option: 3)
                userVotingData[2] = fieldNum!
            }
            if textField == pitchesField {
                changeParticipation(value: fieldNum!, option: 4)
                userVotingData[3] = fieldNum!
            }
            if textField == updatesField {
                changeParticipation(value: fieldNum!, option: 5)
                userVotingData[4] = fieldNum!
            }
            usleep(500000)
            getVoteCalc()
        }
    }
    
    func changeParticipation(value: Int, option: Int) {
        // 2 == TH   3 == Memo   4 == Pitch   5 == Update
        let sheetID = "1uFzXgwJmmsAqTrkEC1mil7fAvieLgU82TAlWMDmN8wo"
        let range = "Vote%20Calc%20-%20Summer%20'18!\(numToLetter(numCol: option))\(userVoteRow + 2)"
        //range = "Record - Summer '18!\(numToLetter(numCol: pageControl.currentPage + 2))\(userVoteRow + 2)"
        let requestParams = [
            "values": [ 
                ["\(value)"],
                ]
            ]
        let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken!
        let header = ["Authorization":"Bearer \(accessToken)"]
        let requestURL = "https://sheets.googleapis.com/v4/spreadsheets/\(sheetID)/values/\(range)?valueInputOption=USER_ENTERED"
        Alamofire.request(requestURL, method: .put, parameters: requestParams, encoding: JSONEncoding.default, headers: header)
    }
    
    @objc func buttonClicked(_ sender: AnyObject?) {
        if sender === backButton {
            let menuController = MenuController()
            self.present(menuController, animated: true, completion: nil)
        }
        if sender === rejectButton {
            chooseReject(_: rejectButton)
            writeVote(vote: -1)
            recordData[userVoteRow][pageControl.currentPage + 2] = -1
            usleep(250000)
            getVoteRecord()
        }
        if sender === abstainButton {
            chooseAbstain(_: abstainButton)
            writeVote(vote: 0)
            recordData[userVoteRow][pageControl.currentPage + 2] = 0
            usleep(250000)
            getVoteRecord()
        }
        if sender === passButton {
            choosePass(_: passButton)
            writeVote(vote: 1)
            recordData[userVoteRow][pageControl.currentPage + 2] = 1
            usleep(250000)
            getVoteRecord()
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        //return UIStatusBarStyle.default   // Make dark again
    }
    
}















