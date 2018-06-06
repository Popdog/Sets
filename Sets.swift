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
    private(set) var deck = SetsDeck()
    private(set) var score: Int
    private(set) var cards = [Card: CardStatus]()
    private lazy var pointsForAMatch = {
        3
    }
    private var matchInPreviousTouch = false
    private let penaltyForAMismatch = 5
    private(set) var table: [Card] = []
    private(set) var selected: [Card] = []
    private(set) var mismatched: [Card] = []
    private(set) var matched: [Card] = []
    var deckIsEmpty: Bool {
        if cards.count == 81 {
            return true
        } else {
            return false
        }
    }
    
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
        for (cardKey, cardStatus) in cards {
            switch cardStatus {
            case .isMismatched:
                cards[cardKey] = .onTable
            default:
                break
            }
        }
        if deck.cards.count >= numberOfCards {
            for _ in 0..<numberOfCards {
                cards[deck.draw()!] = .onTable
            }
        }
    }
    init() {
        score = 0
    }
    func newGame() {
        deck = SetsDeck()
        cards = [:]
        deal(cards: INITIAL_CARDS_DEALT)
        score = 0
        matchInPreviousTouch = false
    }
}

func formASet(firstCard: Card, secondCard: Card, thirdCard: Card) -> Bool {
    return true
    let colorIndex = (firstCard.color == secondCard.color && secondCard.color == thirdCard.color) || (firstCard.color != secondCard.color && firstCard.color != thirdCard.color && secondCard.color != thirdCard.color)
    let shapeIndex = (firstCard.shape == secondCard.shape && secondCard.shape == thirdCard.shape) || (firstCard.shape != secondCard.shape && firstCard.shape != thirdCard.shape && secondCard.shape != thirdCard.shape)
    let numberIndex = (firstCard.number == secondCard.number && secondCard.number == thirdCard.number) || (firstCard.number != secondCard.number && firstCard.number != thirdCard.number && secondCard.number != thirdCard.number)
    let fillIndex = (firstCard.fill == secondCard.fill && secondCard.fill == thirdCard.fill) || (firstCard.fill != secondCard.fill && firstCard.fill != thirdCard.fill && secondCard.fill != thirdCard.fill)

    return (colorIndex && shapeIndex && numberIndex && fillIndex)
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
    case onTable, isSelected, isMatched, isMismatched
}
