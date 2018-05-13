//
//  Card.swift
//  Sets
//
//  Created by William Myers on 5/8/18.
//  Copyright © 2018 William Myers. All rights reserved.
//

import Foundation

struct Card: Hashable {
    let number: Int
    let color: Int
    let shape: Int
    let shading: Int
    let identifier: Int
    
    private static var identifierFactory = 0
    
    private static func getUniqueIdentifier() -> Int {
        Card.identifierFactory += 1
        return Card.identifierFactory
    }
    
    var hashValue: Int { return identifier}
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init(with number: Int, with color: Int, with shape: Int, with shading: Int) {
        self.number = number
        self.color = color
        self.shape = shape
        self.shading = shading
        identifier = Card.getUniqueIdentifier()
    }
}

enum CardLocation {
    case inDeck, onTable, inDiscard
}
