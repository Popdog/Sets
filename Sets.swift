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
    private(set) var score: Int
    private(set) var cards = [Card: CardStatus]()
    private lazy var pointsForAMatch = {
        3
    }
    private let penaltyForAMismatch = 5
    
    func choose(card: Card) {
        switch cards[card]! {
        case .isSelected:
            cards[card] = .onTable
        case .onTable:
            cards[card] = .isSelected
        default:
            break
        }
        var selected: [Card] = []
        for (cardKey, cardStatus) in cards {
            switch cardStatus {
            case .isSelected:
                selected.append(cardKey)
            case .isMismatched:
                cards[cardKey] = .onTable
            default:
                break
            }
        }
        if selected.count == 3 {
            if formASet(firstCard: selected[0], secondCard: selected[1], thirdCard: selected[2]) {
                cards[selected[0]] = .isMatched; cards[selected[1]] = .isMatched; cards[selected[2]] = .isMatched
                score += pointsForAMatch()
                deal(cards: 3)
            } else {
                score -= penaltyForAMismatch
                cards[selected[0]] = .isMismatched; cards[selected[1]] = .isMismatched; cards[selected[2]] = .isMismatched
            }
        }
    }
    func deal(cards numberOfCards: Int) {
        var availableCards: [Card] = []
        for (cardKey, cardStatus) in cards {
            switch cardStatus {
            case .inDeck:
                availableCards.append(cardKey)
            case .isMismatched:
                cards[cardKey] = .onTable
            default:
                break
            }
        }
        if availableCards.count >= numberOfCards {
            for _ in 0..<numberOfCards {
                let randomIndex = availableCards.count.arc4random
                cards[availableCards[randomIndex]] = .onTable
                availableCards.remove(at: randomIndex)
            }
        }
    }
    init() {
        deck = []
        score = 0
    }
    func newGame() {
        deck = createDeck()
        deck = deck.shuffle
        cards = [:]
        for card in deck {
            cards[card] = CardStatus.inDeck
        }
        deal(cards: INITIAL_CARDS_DEALT)
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
enum CardStatus {
    case inDeck, onTable, isSelected, isMatched, isMismatched
}
