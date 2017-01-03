//
//  EventModel.swift
//  Bout Time
//
//  Created by Nathan Rohweder on 1/2/17.
//  Copyright © 2017 Nathan Rohweder. All rights reserved.
//

import Foundation

enum InventoryError: Error {
    case invalidResource
    case conversionFailure
    case invalidSelection
}

class PlistConverter {
    static func converter(fromFile name: String, ofType type: String) throws -> [(String, String)] {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw InventoryError.invalidResource
        }
        
        guard let arrayOfTuples = NSArray(contentsOfFile: path) as? [(String, String)] else {
            throw InventoryError.conversionFailure
        }
        
        return arrayOfTuples
    }
}


class InventoryUnarchiver {
    static func eventInventory(fromArray array: [(String, String)]) throws -> [(String, String)] {
        
        //var inventory: [VendingSelection:VendingItem] = [:]
        
        for (key, value) in array {
            if let itemDictionary = value as? [String: Any], let price = itemDictionary["price"] as? Double, let quantity = itemDictionary["quantity"] as? Int {
                let item = Item(price: price, quantity: quantity)
                
                guard let selection = VendingSelection(rawValue: key) else {
                    throw InventoryError.invalidSelection
                }
                inventory.updateValue(item, forKey: selection)
            }
        }
        
        return inventory
    }
}
