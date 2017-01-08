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
    
    
    @IBOutlet weak var NextRound: UIButton!
    @IBOutlet weak var GameInstruction: UIButton!
    @IBOutlet weak var Event1: InsetLabel!
    @IBOutlet weak var Event2: InsetLabel!
    @IBOutlet weak var Event3: InsetLabel!
    @IBOutlet weak var Event4: InsetLabel!

    var events: [Event] = []
    var eventIndex: Int = 0
    var currentRound: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NextRound.isHidden = true
        GameInstruction.setTitle("Shake to complete", for: UIControlState.normal)
        
        do {
            let array = try PlistConverter.arrayOfDictionaries(fromFile: "HistoricalEvents", ofType: "plist")
            let loadEvents = try EventUnarchiver.assembleEvents(arrayOfDictionaries: array)
            events = loadEvents
        } catch let error {
            fatalError("\(error)")
        }
        
        print(events)
        let loadRound = currentRoundEvents()
        currentRound = loadRound
        
        DisplayEvents()
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func currentRoundEvents() -> [String] {
        var currentRound: [String] = []
        let event1 = GKRandomSource.sharedRandom().nextInt(upperBound: events.count)
        let event2 = GKRandomSource.sharedRandom().nextInt(upperBound: events.count)
        let event3 = GKRandomSource.sharedRandom().nextInt(upperBound: events.count)
        let event4 = GKRandomSource.sharedRandom().nextInt(upperBound: events.count)
        currentRound.append(events[event1].event)
        currentRound.append(events[event2].event)
        currentRound.append(events[event3].event)
        currentRound.append(events[event4].event)
        
        print(currentRound)
        
        return currentRound
    }
    
    func DisplayEvents() {
        Event1.text = currentRound[0]
        Event2.text = currentRound[1]
        Event3.text = currentRound[2]
        Event4.text = currentRound[3]
    }


    
}

