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
    @IBOutlet weak var Timer: UILabel!
    @IBOutlet weak var GameInstruction: UILabel!
    @IBOutlet weak var WebviewBar: UIButton!
    @IBOutlet weak var Webview: UIWebView!

    var events: [Event] = []
    var eventIndex: Int = 0
    var currentRound: [Event] = []
    var reordersPerRound = 6
    var reordersCompleted = 0
    var correctOrders = 0
    var usedEvents: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let array = try PlistConverter.arrayOfDictionaries(fromFile: "HistoricalEvents", ofType: "plist")
            let loadEvents = try EventUnarchiver.assembleEvents(arrayOfDictionaries: array)
            events = loadEvents
        } catch let error {
            fatalError("\(error)")
        }

        setDisplayStart()
        displayEvents()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func currentRoundEvents() -> [Event] {
        var appendEvents: [Event] = []
        let eventIndex1 = GKRandomSource.sharedRandom().nextInt(upperBound: events.count)
        let eventIndex2 = GKRandomSource.sharedRandom().nextInt(upperBound: events.count)
        let eventIndex3 = GKRandomSource.sharedRandom().nextInt(upperBound: events.count)
        let eventIndex4 = GKRandomSource.sharedRandom().nextInt(upperBound: events.count)
        appendEvents.append(events[eventIndex1])
        appendEvents.append(events[eventIndex2])
        appendEvents.append(events[eventIndex3])
        appendEvents.append(events[eventIndex4])
        
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
        Timer.isHidden = false
        RoundButton.isHidden = true
        GameInstruction.text = "Shake to complete"
    }
    
    func setDisplayEnd() {
        setLabelAlpha(alpha: 0.8)
        Event1.isEnabled = true
        Event2.isEnabled = true
        Event3.isEnabled = true
        Event4.isEnabled = true
        
        GameInstruction.text = "Tap events to learn more"
        Timer.isHidden = true
        RoundButton.isHidden = false
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
        reordersCompleted + 1
        let y1: Int = currentRound[0].year
        let y2: Int = currentRound[1].year
        let y3: Int = currentRound[2].year
        let y4: Int = currentRound[3].year
        if (y1 > y2 && y2 > y3 && y3 > y4) {
            correctAnswer()
        } else {
            incorrectAnswer()
        }
    }
        
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        checkAnswer()
    }
        
    func correctAnswer() {
        setDisplayEnd()
        correctOrders + 1
    }
        
    func incorrectAnswer() {
        setDisplayEnd()
        RoundButton.setImage(#imageLiteral(resourceName: "next_round_fail.png"), for: UIControlState.normal)
    }
    
    func displayScore() {
            reordersCompleted = 0
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
                if reordersCompleted == reordersPerRound
                {
                    // Game is over
                    displayScore()
                } else {
                    // Continue game
                    setDisplayStart()
                    displayEvents()
            }
        }
    }

}
