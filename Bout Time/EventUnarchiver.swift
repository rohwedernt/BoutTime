//
//  EventUnarchiver.swift
//  Bout Time
//
//  Created by Nathan Rohweder on 1/16/17.
//  Copyright © 2017 Nathan Rohweder. All rights reserved.
//

import Foundation

class EventUnarchiver {
    static func assembleEvents(arrayOfDictionaries: [[String:String]]) throws -> [Event] {
        
        var eventList: [Event] = []
        for dict in arrayOfDictionaries {
            if let event = dict["Event"], let year = dict["Year"], let url = dict["URL"] {
                // FIXME: force conversion could fail for year value
                let historyEvent = Event(event: event, year: Int(year)!, URL: url)
                eventList.append(historyEvent)
            }
        }
        return eventList
    }
}
