//
//  ViewController.swift
//  Bout Time
//
//  Created by Nathan Rohweder on 1/2/17.
//  Copyright © 2017 Nathan Rohweder. All rights reserved.
//

import UIKit
import GameKit

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
    @IBOutlet weak var GameScore: UILabel!
    @IBOutlet weak var YourScore: UILabel!
    @IBOutlet weak var PlayAgain: UIButton!
    
    var events: [Event] = []
    var eventIndex: Int = 0
    var currentRound: [Event] = []
    var usedEvents: [Event] = []
    var timerLength: Int = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)

        
        do {
            let array = try PlistConverter.arrayOfDictionaries(fromFile: "HistoricalEvents", ofType: "plist")
            let loadEvents = try EventUnarchiver.assembleEvents(arrayOfDictionaries: array)
            events = loadEvents
        } catch let error {
            fatalError("\(error)")
        }
        GameScore.isHidden = true
        YourScore.isHidden = true
        PlayAgain.isHidden = true
        setDisplayStart()
        displayEvents()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateCounter() {
        if timerLength > 0 {
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
    
    func setLabelAlpha(alpha: CGFloat) {
        Event1.alpha = alpha
        Event2.alpha = alpha
        Event3.alpha = alpha
        Event4.alpha = alpha
    }
    
    func setDisplayStart() {
        Event1Down.setImage(#imageLiteral(resourceName: "up_full_selected.png"), for: UIControlState.highlighted)
        Event2Up.setImage(#imageLiteral(resourceName: "up_half_selected.png"), for: UIControlState.highlighted)
        Event2Down.setImage(#imageLiteral(resourceName: "down_half_selected.png"), for: UIControlState.highlighted)
        Event3Up.setImage(#imageLiteral(resourceName: "up_half_selected.png"), for: UIControlState.highlighted)
        Event3Down.setImage(#imageLiteral(resourceName: "down_half_selected.png"), for: UIControlState.highlighted)
        Event4Up.setImage(#imageLiteral(resourceName: "up_full_selected.png"), for: UIControlState.highlighted)
        Event1.isEnabled = false
        Event2.isEnabled = false
        Event3.isEnabled = false
        Event4.isEnabled = false
        Webview.isHidden = true
        WebviewBar.isHidden = true
        let loadRound = currentRoundEvents()
        currentRound = loadRound
        setLabelAlpha(alpha: 1.0)
        GameTimer.isHidden = false
        timerLength = 60
        GameTimer.text = String(timerLength)
        RoundButton.isHidden = true
        GameInstruction.text = "Shake to complete"
        Event1Year.isHidden = true
        Event2Year.isHidden = true
        Event3Year.isHidden = true
        Event4Year.isHidden = true

    }
    
    func setDisplayEnd() {
        setLabelAlpha(alpha: 0.8)
        Event1.isEnabled = true
        Event2.isEnabled = true
        Event3.isEnabled = true
        Event4.isEnabled = true
        Event1.isHidden = false
        Event1Down.isHidden = false
        WebviewBar.isHidden = true
        Webview.isHidden = true
        GameInstruction.text = "Tap events to learn more"
        GameTimer.isHidden = true
        RoundButton.isHidden = false
        Event1Year.isHidden = false
        Event1Year.text = String("\(currentRound[0].year) A.D.")
        Event2Year.isHidden = false
        Event2Year.text = String("\(currentRound[1].year) A.D.")
        Event3Year.isHidden = false
        Event3Year.text = String("\(currentRound[2].year) A.D.")
        Event4Year.isHidden = false
        Event4Year.text = String("\(currentRound[3].year) A.D.")
    }
    
    func setDisplayScore() {
        YourScore.isHidden = false
        GameScore.isHidden = false
        PlayAgain.isHidden = false
        YourScore.text = "Your Score"
        GameScore.text = "\(correctOrders)/\(roundsPerGame)"
        Event1.isHidden = true
        Event2.isHidden = true
        Event3.isHidden = true
        Event4.isHidden = true
        Event1Down.isHidden = true
        Event2Up.isHidden = true
        Event2Down.isHidden = true
        Event3Up.isHidden = true
        Event3Down.isHidden = true
        Event4Up.isHidden = true
        RoundButton.isHidden = true
        GameTimer.isHidden = true
        GameInstruction.isHidden = true
        WebviewBar.isHidden = true
        Webview.isHidden = true
        Event1Year.isHidden = true
        Event2Year.isHidden = true
        Event3Year.isHidden = true
        Event4Year.isHidden = true
    }
    
    @IBAction func playAgain(_ sender: UIButton) {
        if sender === PlayAgain {
            setDisplayStart()
            displayEvents()
        }
    }
    
    func displayEvents() {
        Event1.setTitle(currentRound[0].event, for: UIControlState.normal)
        Event2.setTitle(currentRound[1].event, for: UIControlState.normal)
        Event3.setTitle(currentRound[2].event, for: UIControlState.normal)
        Event4.setTitle(currentRound[3].event, for: UIControlState.normal)
    }
    
    func rearrange(fromIndex: Int, toIndex: Int) -> [Event] {
        let element = currentRound.remove(at: fromIndex)
        currentRound.insert(element, at: toIndex)
        
        return currentRound
    }

    @IBAction func shiftEvents(_ sender: UIButton) {
        switch sender {
        case _ where sender === Event1Down || sender === Event2Up:
            currentRound = rearrange(fromIndex: 0, toIndex: 1)
            displayEvents()
        case _ where sender === Event2Down || sender === Event3Up:
            currentRound = rearrange(fromIndex: 1, toIndex: 2)
            displayEvents()
        case _ where sender === Event3Down || sender === Event4Up:
            currentRound = rearrange(fromIndex: 2, toIndex: 3)
            displayEvents()
        default: print("Not a valid button")
        }
    }

    func checkAnswer() {
        if reordersCompleted == roundsPerGame
        {
            // Game is over
            setDisplayScore()
        } else {
        reordersCompleted = reordersCompleted + 1
        let y1: Int = currentRound[0].year
        let y2: Int = currentRound[1].year
        let y3: Int = currentRound[2].year
        let y4: Int = currentRound[3].year
        timerLength = 1000
        if (y1 > y2 && y2 > y3 && y3 > y4) {
            correctAnswer()
        } else {
            incorrectAnswer()
        }
        }
    }
        
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        checkAnswer()
    }
        
    func correctAnswer() {
        setDisplayEnd()
        correctOrders = correctOrders + 1
    }
        
    func incorrectAnswer() {
        setDisplayEnd()
        RoundButton.setImage(#imageLiteral(resourceName: "next_round_fail.png"), for: UIControlState.normal)
    }
    
    func displayScore() {
        reordersCompleted = 0
        correctOrders = 0
        setDisplayScore()
    }
    
    @IBAction func moreInfo(_ sender: UIButton) {
        displayWebView()
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
            setDisplayEnd()
            default: print("Not a valid button")
        }
    }
    
    func displayWebView() {
        WebviewBar.isHidden = false
        Webview.isHidden = false
        Webview.alpha = 1.0
        Event1.isHidden = true
        Event1Down.isHidden = true
        
    }
    
    @IBAction func nextRound(_ sender: UIButton) {
        if sender === RoundButton {
                    setDisplayStart()
                    displayEvents()
        }
    }

}
