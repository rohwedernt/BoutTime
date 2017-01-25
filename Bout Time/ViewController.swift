//
//  ViewController.swift
//  Bout Time
//
//  Created by Nathan Rohweder on 1/2/17.
//  Copyright © 2017 Nathan Rohweder. All rights reserved.
//

import UIKit
import GameKit

var roundsPerGame = 5
var correctOrders = 0
var reordersCompleted = 0

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
    var checkStateTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let array = try PlistConverter.arrayOfDictionaries(fromFile: "HistoricalEvents", ofType: "plist")
            let loadEvents = try EventUnarchiver.assembleEvents(arrayOfDictionaries: array)
            events = loadEvents
        } catch let error {
            fatalError("\(error)")
        }
        Event1Down.setImage(#imageLiteral(resourceName: "up_full_selected.png"), for: UIControlState.highlighted)
        Event2Up.setImage(#imageLiteral(resourceName: "up_half_selected.png"), for: UIControlState.highlighted)
        Event2Down.setImage(#imageLiteral(resourceName: "down_half_selected.png"), for: UIControlState.highlighted)
        Event3Up.setImage(#imageLiteral(resourceName: "up_half_selected.png"), for: UIControlState.highlighted)
        Event3Down.setImage(#imageLiteral(resourceName: "down_half_selected.png"), for: UIControlState.highlighted)
        Event4Up.setImage(#imageLiteral(resourceName: "up_full_selected.png"), for: UIControlState.highlighted)
        
        checkStateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)

        
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

    func displayNewRound() {
        
        Event1.isEnabled = false
        Event2.isEnabled = false
        Event3.isEnabled = false
        Event4.isEnabled = false
        Event1Down.isEnabled = true
        Event2Up.isEnabled = true
        Event2Down.isEnabled = true
        Event3Up.isEnabled = true
        Event3Down.isEnabled = true
        Event4Up.isEnabled = true
        Event1Year.isHidden = true
        Event2Year.isHidden = true
        Event3Year.isHidden = true
        Event4Year.isHidden = true
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
    
    func showYear(forEventNumber: Int, forEventLabel: UILabel) {
        forEventLabel.text = String("\(currentRound[forEventNumber].year) A.D.")
        forEventLabel.isHidden = false
    }
    
    func endRound() {
        checkStateTimer.invalidate()
        setLabelOpacity(alpha: 0.9)
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
            performSegue(withIdentifier: "ShowResults", sender: nil)
        } else {
        reordersCompleted = reordersCompleted + 1
        let y1 = currentRound[0].year
        let y2 = currentRound[1].year
        let y3 = currentRound[2].year
        let y4 = currentRound[3].year
        if (y1 > y2 && y2 > y3 && y3 > y4) {
            // Answer Correct
            correctOrders = correctOrders + 1
            RoundButton.setImage(#imageLiteral(resourceName: "next_round_success.png"), for: UIControlState.normal)
            endRound()
        } else {
            // Answer Incorrect
            RoundButton.setImage(#imageLiteral(resourceName: "next_round_fail.png"), for: UIControlState.normal)
            endRound()
        }
        }
    }
        
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        checkAnswer()
    }
    
    enum WebError: Error {
        case invalidResource
        case conversionFailure
        case invalidSelection
    }
    
    @IBAction func launchWebview(_ sender: UIButton) throws {
        WebviewBar.isHidden = false
        Webview.isHidden = false
        switch sender {
        case _ where sender === Event1:
            guard let url = URL(string: currentRound[0].URL) else {
                throw WebError.invalidResource
            }
            let request = URLRequest(url: url)
            Webview.loadRequest(request)
        case _ where sender === Event2:
            guard let url = URL(string: currentRound[1].URL) else {
                throw WebError.invalidResource
            }
            let request = URLRequest(url: url)
            Webview.loadRequest(request)
        case _ where sender === Event3:
            guard let url = URL(string: currentRound[2].URL) else {
                throw WebError.invalidResource
            }
            let request = URLRequest(url: url)
            Webview.loadRequest(request)
        case _ where sender === Event4:
            guard let url = URL(string: currentRound[3].URL) else {
                throw WebError.invalidResource
            }
            let request = URLRequest(url: url)
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
