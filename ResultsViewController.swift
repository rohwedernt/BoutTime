//
//  ScoreViewController.swift
//  Bout Time
//
//  Created by Nathan Rohweder on 1/16/17.
//  Copyright © 2017 Nathan Rohweder. All rights reserved.
//

import Foundation
import UIKit

class ResultsViewController: UIViewController {
    @IBOutlet weak var YourScore: UILabel!
    @IBOutlet weak var GameScore: UILabel!
    @IBOutlet weak var PlayAgain: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        YourScore.text = "Your Score"
        GameScore.text = "\(correctOrders)/\(roundsPerGame + 1)"
        correctOrders = 0
        reordersCompleted = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
