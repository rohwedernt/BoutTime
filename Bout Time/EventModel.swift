//
//  EventModel.swift
//  Bout Time
//
//  Created by Nathan Rohweder on 1/2/17.
//  Copyright © 2017 Nathan Rohweder. All rights reserved.
//

import Foundation

struct Event {
    var event: String
    var year: Int
    var URL: String
}

enum InventoryError: Error {
    case invalidResource
    case conversionFailure
    case invalidSelection
}

class PlistConverter {
    static func arrayOfDictionaries(fromFile name: String, ofType type: String) throws -> [[String: String]] {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw InventoryError.invalidResource
        }
        
        guard let arrayOfDictionaries = NSArray(contentsOfFile: path) as? [[String: String]] else {
            throw InventoryError.conversionFailure
        }
        
        return arrayOfDictionaries
    }
}

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
