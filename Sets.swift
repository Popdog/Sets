//
//  Sets.swift
//  Sets
//
//  Created by William Myers on 5/8/18.
//  Copyright © 2018 William Myers. All rights reserved.
//

import Foundation

let INITIAL_CARDS_DEALT = 12

class Sets {
    private(set) var deck: [Card]
    private(set) var selectedCards: [Card]
    private(set) var matchedCards: [Card]
    private(set) var displayedCards: [Card]
    private(set) var mismatchedCards: [Card]
    private(set) var score: Int
    private lazy var pointsForAMatch = {
        Int((30 - self.displayedCards.count) / 3)
    }
    private let penaltyForAMismatch = 5
    
    func choose(card: Card) {
        removeMatchedCards()
        mismatchedCards = []
        if selectedCards.contains(card) {
            selectedCards.remove(at: selectedCards.index(of: card)!)
        } else {
            selectedCards.append(card)
        }
        if selectedCards.count == 3 {
            if formASet(firstCard: selectedCards[0], secondCard: selectedCards[1], thirdCard: selectedCards[2]) {
                matchedCards += selectedCards
                score += pointsForAMatch()
            } else {
                mismatchedCards += selectedCards
                score -= penaltyForAMismatch
            }
            selectedCards = []
        }
    }
    
    func deal(cards numberOfCards: Int) {
        removeMatchedCards()
        mismatchedCards = []
        var cardsDealt = 0
        for index in deck.indices {
            if cardsDealt >= numberOfCards {
                return
            }
            if !matchedCards.contains(deck[index]), !displayedCards.contains(deck[index]) {
                displayedCards.append(deck[index])
                cardsDealt = cardsDealt + 1
            }
        }
    }
    
    private func removeMatchedCards() {
        for index in matchedCards.indices {
            if displayedCards.contains(matchedCards[index]) {
                displayedCards.remove(at: displayedCards.index(of: matchedCards[index])!)
            }
        }
    }
    
    init() {
        deck = []
        selectedCards = []
        matchedCards = []
        displayedCards = []
        mismatchedCards = []
        score = 0
    }
    
    func newGame() {
        deck = createDeck()
        deck = deck.shuffle
        displayedCards = []
        deal(cards: INITIAL_CARDS_DEALT)
        matchedCards = []
        selectedCards = []
        score = 0
    }
}

func formASet(firstCard: Card, secondCard: Card, thirdCard: Card) -> Bool {
    var areSame: (Int, Int, Int) -> Bool
    var areDistinct: (Int, Int, Int) -> Bool
    areSame = {$0 == $1 && $1 == $2}
    areDistinct = {$0 != $1 && $0 != $2 && $1 != $2}
    
    let setIndexOne = areSame(firstCard.color, secondCard.color, thirdCard.color) || areDistinct(firstCard.color, secondCard.color, thirdCard.color)
    let setIndexTwo = areSame(firstCard.number, secondCard.number, thirdCard.number) || areDistinct(firstCard.number, secondCard.number, thirdCard.number)
    let setIndexThree = areSame(firstCard.shading, secondCard.shading, thirdCard.shading) || areDistinct(firstCard.shading, secondCard.shading, thirdCard.shading)
    let setIndexFour = areSame(firstCard.shape, secondCard.shape, thirdCard.shape) || areDistinct(firstCard.shape, secondCard.shape, thirdCard.shape)
    
    return (setIndexOne && setIndexTwo && setIndexThree && setIndexFour)
}

func createDeck() -> [Card] {
    var deck = [Card]()
    for number in 0..<3 {
        for color in 0..<3 {
            for shape in 0..<3 {
                for shading in 0..<3 {
                    let card = Card(with: number, with: color, with: shape, with: shading)
                    deck += [card]
                }
            }
        }
    }
    return deck
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(-self)))
        } else {
            return 0
        }
    }
}

extension Array {
    var shuffle: Array {
        var shuffled = Array<Element>()
        var unshuffled = self
        for _ in self {
            let randomIndex = Int(arc4random_uniform(UInt32(unshuffled.count)))
            shuffled.append(unshuffled.remove(at: randomIndex))
        }
        return shuffled
    }
}
