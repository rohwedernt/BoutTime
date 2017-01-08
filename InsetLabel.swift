//
//  InsetLabel.swift
//  Bout Time
//
//  Created by Nathan Rohweder on 1/8/17.
//  Copyright © 2017 Nathan Rohweder. All rights reserved.
//

import Foundation
import UIKit

class InsetLabel: UILabel {

    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)))
    }

}
