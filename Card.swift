//
//  Card.swift
//  Sets
//
//  Created by William Myers on 5/8/18.
//  Copyright © 2018 William Myers. All rights reserved.
//

import Foundation

struct Card: Hashable, CustomStringConvertible {
    var description: String {return "\(number) \(fill) \(color) \(shape)(s)"}
    
    let number: Number
    let color: Color
    let shape: Shape
    let fill: Fill
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
    
    init(withNumber number: Number, withColor color: Color, withShape shape: Shape, withFill fill: Fill) {
        self.number = number
        self.color = color
        self.shape = shape
        self.fill = fill
        identifier = Card.getUniqueIdentifier()
    }
}

enum CardLocation {
    case inDeck, onTable, inDiscard
}

enum Number: Int, Equatable {
    case one = 1
    case two = 2
    case three = 3
    
    static var all = [Number.one, Number.two, Number.three]
}

enum Shape: String {
    case squiggle
    case oval
    case diamond
    
    static var all = [Shape.squiggle, Shape.oval, Shape.diamond]
}

enum Fill: String {
    case solid
    case striped
    case empty
    
    static var all = [Fill.solid, Fill.striped, Fill.empty]
}

enum Color: String {
    case red
    case green
    case purple
    
    static var all = [Color.red, Color.green, Color.purple]
}
