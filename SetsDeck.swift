//
//  SetsDeck.swift
//  Sets
//
//  Created by William Myers on 5/16/18.
//  Copyright © 2018 William Myers. All rights reserved.
//

import Foundation

struct SetsDeck {
    private(set) var cards: [Card]
    
    mutating func draw() -> Card? {
        if cards.count > 0 {
            return cards.remove(at: (cards.count.arc4random))
        } else {
            return nil
        }
    }
    
    init() {
        var newDeck = [Card]()
        for shape in Shape.all {
            for color in Color.all {
                for number in Number.all {
                    for fill in Fill.all {
                        let card = Card(withNumber: number, withColor: color, withShape: shape, withFill: fill)
                        newDeck.append(card)
                    }
                }
            }
        }
        cards = newDeck
    }
}
