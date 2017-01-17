//
//  PlistConverter.swift
//  Bout Time
//
//  Created by Nathan Rohweder on 1/16/17.
//  Copyright © 2017 Nathan Rohweder. All rights reserved.
//

import Foundation

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
