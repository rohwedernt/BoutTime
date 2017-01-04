//
//  ViewController.swift
//  Bout Time
//
//  Created by Nathan Rohweder on 1/2/17.
//  Copyright © 2017 Nathan Rohweder. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var NextRound: UIButton!
    @IBOutlet weak var GameInstruction: UIButton!
    @IBOutlet weak var Event1: UILabel!
    @IBOutlet weak var Event2: UILabel!
    @IBOutlet weak var Event3: UILabel!
    @IBOutlet weak var Event4: UILabel!

    var entirePlist: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NextRound.isHidden = true
        GameInstruction.setTitle("Shake to complete", for: UIControlState.normal)
        do {
            let array = try PlistConverter.arrayOfDictionaries(fromFile: "HistoricalEvents", ofType: "plist")
            let events = try EventUnarchiver.eventList(arrayOfDictionaries: array)
            entirePlist = events
        } catch let error {
            fatalError("\(error)")
        }
        
        
        print(entirePlist)
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
}

