//
//  ViewController.swift
//  Bout Time
//
//  Created by Nathan Rohweder on 1/2/17.
//  Copyright © 2017 Nathan Rohweder. All rights reserved.
//

import UIKit
import GameKit
import AudioToolbox

class ViewController: UIViewController {
    
    @IBOutlet weak var Event1: UIButton!
    @IBOutlet weak var Event2: UIButton!
    @IBOutlet weak var Event3: UIButton!
    @IBOutlet weak var Event4: UIButton!
    @IBOutlet weak var Event1Down: UIButton!
    @IBOutlet weak var Event2Up: UIButton!
    @IBOutlet weak var Event2Down: UIButton!
    @IBOutlet weak var Event3Up: UIButton!
    @IBOutlet weak var Event3Down: UIButton!
    @IBOutlet weak var Event4Up: UIButton!
    @IBOutlet weak var RoundButton: UIButton!
    @IBOutlet weak var GameTimer: UILabel!
    @IBOutlet weak var GameInstruction: UILabel!
    @IBOutlet weak var WebviewBar: UIButton!
    @IBOutlet weak var Webview: UIWebView!
    @IBOutlet weak var Event1Year: UILabel!
    @IBOutlet weak var Event2Year: UILabel!
    @IBOutlet weak var Event3Year: UILabel!
    @IBOutlet weak var Event4Year: UILabel!
    
    var events: [Event] = []
    var eventIndex: Int = 0
    var currentRound: [Event] = []
    var usedEvents: [Event] = []
    var timerLength: Int = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        
        setButtonStateHighlighted()
        
        do {
            let array = try PlistConverter.arrayOfDictionaries(fromFile: "HistoricalEvents", ofType: "plist")
            let loadEvents = try EventUnarchiver.assembleEvents(arrayOfDictionaries: array)
            events = loadEvents
        } catch let error {
            fatalError("\(error)")
        }
        
        displayNewRound()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateCounter() {
        if timerLength > 0 {
            GameTimer.textColor = UIColor(colorLiteralRed: (1.0), green: (1.0), blue: (1.0), alpha: 1.0)
            GameTimer.text = String(timerLength)
            timerLength -= 1
            if (timerLength < 10) {
                GameTimer.textColor = UIColor(colorLiteralRed: (223/235), green: (31/235), blue: (1/235), alpha: 1.0)
            }
        } else {
            checkAnswer()
        }
    }
    
    func currentRoundEvents() -> [Event] {
        var appendEvents: [Event] = []
        let shuffledEvents = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: events)
        var numberOfEvents = 0
        for e in shuffledEvents {
            if numberOfEvents < 4 {
                //if !usedEvents.contains(where: e) {
                // FIXME: force unwrap
                appendEvents.append(e as! Event)
                usedEvents.append(e as! Event)
                numberOfEvents += 1
                //}
            }
        }
        return appendEvents
    }
    
    func setLabelOpacity(alpha: CGFloat) {
        Event1.alpha = alpha
        Event2.alpha = alpha
        Event3.alpha = alpha
        Event4.alpha = alpha
    }
    
    func setButtonStateHighlighted() {
        Event1Down.setImage(#imageLiteral(resourceName: "up_full_selected.png"), for: UIControlState.highlighted)
        Event2Up.setImage(#imageLiteral(resourceName: "up_half_selected.png"), for: UIControlState.highlighted)
        Event2Down.setImage(#imageLiteral(resourceName: "down_half_selected.png"), for: UIControlState.highlighted)
        Event3Up.setImage(#imageLiteral(resourceName: "up_half_selected.png"), for: UIControlState.highlighted)
        Event3Down.setImage(#imageLiteral(resourceName: "down_half_selected.png"), for: UIControlState.highlighted)
        Event4Up.setImage(#imageLiteral(resourceName: "up_full_selected.png"), for: UIControlState.highlighted)
    }

    func displayNewRound() {
        let loadRound = currentRoundEvents()
        currentRound = loadRound
        timerLength = 60
        setLabelOpacity(alpha: 1.0)
        GameTimer.text = String(timerLength)
        GameInstruction.text = "Shake to complete"
        RoundButton.isHidden = true
        placeEvents()
    }
    
    func placeEvents() {
        Event1.setTitle(currentRound[0].event, for: UIControlState.normal)
        Event2.setTitle(currentRound[1].event, for: UIControlState.normal)
        Event3.setTitle(currentRound[2].event, for: UIControlState.normal)
        Event4.setTitle(currentRound[3].event, for: UIControlState.normal)
    }
    
    func roundEndedButtonAvailability() {
        Event1.isEnabled = true
        Event2.isEnabled = true
        Event3.isEnabled = true
        Event4.isEnabled = true
        Event1Down.isEnabled = false
        Event2Up.isEnabled = false
        Event2Down.isEnabled = false
        Event3Up.isEnabled = false
        Event3Down.isEnabled = false
        Event4Up.isEnabled = false
    }
    
    func showYear(forEventNumber: Int, forEventLabel: UILabel) {
        forEventLabel.text = String("\(currentRound[forEventNumber].year) A.D.")
        forEventLabel.isHidden = false
    }
    
    func endRound() {
        setLabelOpacity(alpha: 0.9)
        roundEndedButtonAvailability()
        GameInstruction.text = "Tap events to learn more"
        RoundButton.isHidden = false
        showYear(forEventNumber: 0, forEventLabel: Event1Year)
        showYear(forEventNumber: 1, forEventLabel: Event2Year)
        showYear(forEventNumber: 2, forEventLabel: Event3Year)
        showYear(forEventNumber: 3, forEventLabel: Event4Year)
    }
    
    func rearrangeEvents(fromIndex: Int, toIndex: Int) -> [Event] {
        let element = currentRound.remove(at: fromIndex)
        currentRound.insert(element, at: toIndex)
        
        return currentRound
    }

    @IBAction func shiftEvents(_ sender: UIButton) {
        switch sender {
        case _ where sender === Event1Down || sender === Event2Up:
            currentRound = rearrangeEvents(fromIndex: 0, toIndex: 1)
            placeEvents()
        case _ where sender === Event2Down || sender === Event3Up:
            currentRound = rearrangeEvents(fromIndex: 1, toIndex: 2)
            placeEvents()
        case _ where sender === Event3Down || sender === Event4Up:
            currentRound = rearrangeEvents(fromIndex: 2, toIndex: 3)
            placeEvents()
        default: print("Not a valid button")
        }
    }

    func checkAnswer() {
        if reordersCompleted == roundsPerGame
        {
            // Game is over
            //displayScore()
        } else {
        reordersCompleted = reordersCompleted + 1
        if (currentRound[0].year > currentRound[1].year &&
            currentRound[1].year > currentRound[2].year &&
            currentRound[2].year > currentRound[3].year) {
            // Answer Correct
            endRound()
            RoundButton.setImage(#imageLiteral(resourceName: "next_round_success.png"), for: UIControlState.normal)
            correctOrders = correctOrders + 1
        } else {
            // Answer Incorrect
            endRound()
            RoundButton.setImage(#imageLiteral(resourceName: "next_round_fail.png"), for: UIControlState.normal)
        }
        }
    }
        
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        checkAnswer()
    }
    
    @IBAction func launchWebview(_ sender: UIButton) {
        WebviewBar.isHidden = false
        Webview.isHidden = false
        switch sender {
        case _ where sender === Event1:
            let url = URL(string: currentRound[0].URL)
            // FIXME: force unwrap
            let request = URLRequest(url: url!)
            Webview.loadRequest(request)
        case _ where sender === Event2:
            let url = URL(string: currentRound[1].URL)
            // FIXME: force unwrap
            let request = URLRequest(url: url!)
            Webview.loadRequest(request)
        case _ where sender === Event3:
            let url = URL(string: currentRound[2].URL)
            // FIXME: force unwrap
            let request = URLRequest(url: url!)
            Webview.loadRequest(request)
        case _ where sender === Event4:
            let url = URL(string: currentRound[3].URL)
            // FIXME: force unwrap
            let request = URLRequest(url: url!)
            Webview.loadRequest(request)
        case _ where sender === WebviewBar:
            endRound()
            default: print("Not a valid button")
        }
    }
    
    @IBAction func nextRound(_ sender: UIButton) {
        if sender === RoundButton {
                    displayNewRound()
            
        }
    }
    
}
