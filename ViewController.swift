//
//  ViewController.swift
//  Sets
//
//  Created by William Myers on 5/8/18.
//  Copyright © 2018 William Myers. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var game = Sets()
    private var cardButtonArray: [CardButton] = []
    var cardsToDisplay: [Card] = []
    
    let cardText = (number: [1, 2, 3],
                    color: [#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)],
                    shape: ["▲","●","■"])
    
    // This is the rework
    
    @IBOutlet var cardButtons: [UIButton]!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func newGame(_ sender: UIButton) {
        game.newGame()
        cardButtonArray = []
        for cardButton in cardButtons {
            let newCardButton = CardButton(button: cardButton)
            cardButtonArray.append(newCardButton)
        }
        updateViewFromModel()
    }
    
    @IBAction func dealCards(_ sender: UIButton) {
        var occupiedButtons = 0
        let cardsToDeal = 3
        for cardButton in cardButtonArray {
            switch cardButton.displayState {
            case .showCard:
                occupiedButtons += 1
            case .showMismatch:
                occupiedButtons += 1
            case .showSelectedCard:
                occupiedButtons += 1
            default:
                break
            }
        }
        if cardsToDeal <= (cardButtons.count - occupiedButtons) {
            game.deal(cards: cardsToDeal)
        }
        updateViewFromModel()
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        let index = getIndex(of: nil, of: sender, in: cardButtonArray)
        if index != nil, cardButtonArray[index!].card != nil {
            game.choose(card: cardButtonArray[index!].card!)
        }
        updateViewFromModel()
    }
    
    func updateViewFromModel() {
        for index in cardButtonArray.indices { // Check for changes in state of displayed cards
            if cardButtonArray[index].card != nil { // If card should not be displayed
                if !game.displayedCards.contains(cardButtonArray[index].card!) {
                    cardButtonArray[index].removeCard() // Remove the card and set the button to hidden
                } else {
                    cardButtonArray[index].displayState = .showCard(card: cardButtonArray[index].card!)
                }
            }
        }
        for index in game.displayedCards.indices { //Check model to see if any new cards need to be displayed
            if getIndex(of: game.displayedCards[index], of: nil, in: cardButtonArray) == nil { // If a card is not currently assigned to a button
                let randomIndex = getIndexOfAvailableButton(from: cardButtonArray) // Randomly select an available CardButton
                if randomIndex != nil {
                    cardButtonArray[randomIndex!].addCard(card: game.displayedCards[index]) // Store the card in the CardButton
                }
            }
        }
        for index in game.selectedCards.indices {
            let selectedIndex = getIndex(of: game.selectedCards[index], of: nil, in: cardButtonArray)
            if selectedIndex != nil {
                 cardButtonArray[selectedIndex!].displayState = .showSelectedCard(card: cardButtonArray[selectedIndex!].card!)
            }
        }
        for index in game.matchedCards.indices {
            let matchedIndex = getIndex(of: game.matchedCards[index], of: nil, in: cardButtonArray)
            if matchedIndex != nil {
                cardButtonArray[matchedIndex!].displayState = .showMatch(card: cardButtonArray[matchedIndex!].card!)
            }
        }
        for index in game.mismatchedCards.indices {
            let mismatchedIndex = getIndex(of: game.mismatchedCards[index], of: nil, in: cardButtonArray)
            if mismatchedIndex != nil {
                cardButtonArray[mismatchedIndex!].displayState = .showMismatch(card: cardButtonArray[mismatchedIndex!].card!)
            }
        }
        
        for index in cardButtonArray.indices {
            setBorder(width: 0.0, color: #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0), for: index)
            cardButtonArray[index].button.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            switch cardButtonArray[index].displayState {
            case .hidden:
                cardButtonArray[index].button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                cardButtonArray[index].button.setAttributedTitle(NSAttributedString(string: "", attributes: nil), for: UIControlState.normal)
            case .showCard:
                cardButtonArray[index].button.setAttributedTitle(getAttributedString(for: index), for: UIControlState.normal)
            case .showSelectedCard:
                setBorder(width: 5.0, color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), for: index)
                cardButtonArray[index].button.setAttributedTitle(getAttributedString(for: index), for: UIControlState.normal)
            case .showMatch:
                setBorder(width: 5.0, color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), for: index)
                cardButtonArray[index].button.setAttributedTitle(getAttributedString(for: index), for: UIControlState.normal)
            case .showMismatch:
                setBorder(width: 5.0, color: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), for: index)
                cardButtonArray[index].button.setAttributedTitle(getAttributedString(for: index), for: UIControlState.normal)
            }
        }
        scoreLabel.text = "Score: \(game.score)"
    }
    
    func setBorder(width borderWidth: CGFloat, color borderColor: CGColor, for index: Int) {
        cardButtonArray[index].button.layer.borderWidth = borderWidth
        cardButtonArray[index].button.layer.borderColor = borderColor
        cardButtonArray[index].button.layer.cornerRadius = 8.0
    }
    
    private func getCardButton(of card: Card?, of button: UIButton?, in buttonArray: [CardButton]) -> CardButton? {
        for index in buttonArray.indices {
            if card != nil, buttonArray[index].card != nil, card! == buttonArray[index].card! {
                return buttonArray[index]
            } else if button != nil, button! == buttonArray[index].button {
                return buttonArray[index]
            }
        }
        return nil
    }
    private func getAttributedString(for index: Int) -> NSAttributedString? {
        if(cardButtonArray[index].card != nil) {
            let numberIndex = cardButtonArray[index].card!.number
            let colorIndex = cardButtonArray[index].card!.color
            let shadingIndex = cardButtonArray[index].card!.shading
            let shapeIndex = cardButtonArray[index].card!.shape
            let attributes: [NSAttributedStringKey:Any]
            switch shadingIndex {
            case 0:
                attributes = [
                    .strokeWidth : -2.0,
                    .strokeColor : cardText.color[colorIndex],
                    .foregroundColor : cardText.color[colorIndex].withAlphaComponent(0.15)
                ]
            case 1:
                attributes = [
                    .strokeWidth : -2.0,
                    .strokeColor : cardText.color[colorIndex],
                    .foregroundColor : cardText.color[colorIndex].withAlphaComponent(1.0)
                ]
            default:
                attributes = [
                    .strokeWidth : 3.0,
                    .strokeColor : cardText.color[colorIndex],
                ]
            }
            var cardString = ""
            for _ in 0..<cardText.number[numberIndex] {
                cardString += cardText.shape[shapeIndex]
            }
            return NSAttributedString(string: cardString, attributes: attributes)
        }
        return nil
    }
}

private func getIndexOfAvailableButton(from cardButtonArray: [CardButton]) -> Int? {
    var availableCardButtons: [CardButton] = []
    for cardButton in cardButtonArray {
        if cardButton.card == nil {
            availableCardButtons.append(cardButton)
        }
    }
    return cardButtonArray.index(of: availableCardButtons[availableCardButtons.count.arc4random])
}

private func getIndex(of card: Card?, of button: UIButton?, in cardButtonArray: [CardButton]) -> Int? {
    for index in cardButtonArray.indices {
        if card != nil, cardButtonArray[index].card != nil, cardButtonArray[index].card! == card! {
            return index
        } else if button != nil, cardButtonArray[index].button == button! {
            return index
        }
    }
    return nil
}

private struct CardButton: Equatable {
    let button: UIButton
    var card: Card?
    var displayState: DisplayState
    
    mutating func removeCard() {
        self.card = nil
        self.displayState = .hidden
    }
    
    mutating func addCard(card: Card) {
        self.card = card
        self.displayState = .showCard(card: self.card!)
    }
    
    init(button: UIButton) {
        self.button = button
        card = nil
        displayState = .hidden
    }
    
    static func ==(lhs: CardButton, rhs: CardButton) -> Bool {
        return lhs.button == rhs.button
    }
}

private enum DisplayState {
    case showCard(card: Card)
    case showSelectedCard(card: Card)
    case showMatch(card: Card)
    case showMismatch(card: Card)
    case hidden
}
