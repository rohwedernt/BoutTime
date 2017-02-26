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
    @IBOutlet weak var Event3: UIButton!
    @IBOutlet weak var Event4: UIButton!
    @IBOutlet weak var Event2: UIButton!
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
    var firstRequest: URLRequest?
    var secondRequest: URLRequest?
    var thirdRequest: URLRequest?
    var fourthRequest: URLRequest?
    
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
        displayNewRound()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Update timer in UI
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
    
    // Pull random event and append to usable array
    func currentRoundEvents() -> [Event] {
        var appendEvents: [Event] = []
        let shuffledEvents = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: events)
        var numberOfEvents = 0
        for e in shuffledEvents {
            if numberOfEvents < 4 {
                // FIXME: force unwrap
                appendEvents.append(e as! Event)
                usedEvents.append(e as! Event)
                numberOfEvents += 1
            }
        }
        return appendEvents
    }
    
    // Opacity change to signify round's end
    func setLabelOpacity(alpha: CGFloat) {
        Event1.alpha = alpha
        Event2.alpha = alpha
        Event3.alpha = alpha
        Event4.alpha = alpha
    }

    // Display config for beginning of round
    func displayNewRound() {
        checkStateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
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
    
    // Place events in UI based on their order in the array
    func placeEvents() {
        Event1.setTitle(currentRound[0].event, for: UIControlState.normal)
        Event2.setTitle(currentRound[1].event, for: UIControlState.normal)
        Event3.setTitle(currentRound[2].event, for: UIControlState.normal)
        Event4.setTitle(currentRound[3].event, for: UIControlState.normal)
        do {
            try extractURLs()
        } catch {
            print("URL not found")
        }
    }
    
    // Display config for showing correct year at end of each round
    func showYear(forEventNumber: Int, forEventLabel: UILabel) {
        forEventLabel.text = String("\(currentRound[forEventNumber].year) A.D.")
        forEventLabel.isHidden = false
    }
    
    // Display config for end of round
    func endRound() {
        WebviewBar.isHidden = true
        Webview.alpha = 0.0
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
    
    // function to rearrange events in the array that shiftEvents() uses
    func rearrangeEvents(fromIndex: Int, toIndex: Int) -> [Event] {
        let element = currentRound.remove(at: fromIndex)
        currentRound.insert(element, at: toIndex)
        
        return currentRound
    }

    // Display events in preferred order based on button selected
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
    
    // Check answer when shake motion completes
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        checkAnswer()
    }
    
    
    enum WebviewError: Error {
        case invalidResource
        case conversionFailure
        case invalidSelection
    }
    
    func extractURLs() throws {
        guard let firstURL = URL(string: String(currentRound[0].URL)) else {
            throw WebviewError.invalidResource
        }
        firstRequest = URLRequest(url: firstURL)
        guard let secondURL = URL(string: String(currentRound[0].URL)) else {
            throw WebviewError.invalidResource
        }
        secondRequest = URLRequest(url: secondURL)
        guard let thirdURL = URL(string: String(currentRound[0].URL)) else {
            throw WebviewError.invalidResource
        }
        thirdRequest = URLRequest(url: thirdURL)
        guard let fourthURL = URL(string: String(currentRound[0].URL)) else {
            throw WebviewError.invalidResource
        }
        fourthRequest = URLRequest(url: fourthURL)
    }
    
    // Launch correct webview url based on button selected
    @IBAction func launchWebview(_ sender: UIButton) {
        WebviewBar.isHidden = false
        Webview.isHidden = false
        Webview.alpha = 1.0
        switch sender {
        case _ where sender === Event1:
            Webview.loadRequest(firstRequest!)
        case _ where sender === Event2:
            Webview.loadRequest(secondRequest!)
        case _ where sender === Event3:
            Webview.loadRequest(thirdRequest!)
        case _ where sender === Event4:
            Webview.loadRequest(fourthRequest!)
        case _ where sender === WebviewBar:

            endRound()
            default: print("Not a valid button")
        }
    }
    
    // Display new round if next round button is selected
    @IBAction func nextRound(_ sender: UIButton) {
        if sender === RoundButton {
                    displayNewRound()
        }
    }
}
