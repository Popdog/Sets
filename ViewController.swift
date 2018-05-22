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
    var cardsToDisplay: [Card] = []
    static let cardsToDeal = 3
    private var cardViewLookup: [(CardView, DisplayState)] = []
    
    @IBOutlet weak var playArea: tableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let table = self.playArea {
            table.grid = Grid(layout: .aspectRatio(0.75), frame: table.bounds)
        }
    }
    
    @IBOutlet weak var newGameButton: UIButton! {
        didSet{
            newGameButton.addShadow(withColor: UIButton.shadowColor, withRadius: UIButton.shadowRadius, withOffset: UIButton.shadowOffset, withOpacity: UIButton.shadowOpacity)
            newGameButton.addBorder(withColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), withWidth: 2.0)
            newGameButton.layer.cornerRadius = 8.0
        }
    }
    @IBOutlet weak var dealButton: UIButton! {
        didSet{
            dealButton.addShadow(withColor: UIButton.shadowColor, withRadius: UIButton.shadowRadius, withOffset: UIButton.shadowOffset, withOpacity: UIButton.shadowOpacity)
            dealButton.addBorder(withColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), withWidth: 2.0)
            dealButton.layer.cornerRadius = 8.0
        }
    }
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func newGame(_ sender: UIButton) {
        cardViewLookup = []
        playArea.removeAll()
        game.newGame()
        updateViewFromModel()
    }
    @IBAction func dealCards(_ sender: UIButton) {
        game.deal(cards: ViewController.cardsToDeal)
        updateViewFromModel()
        playArea.setNeedsDisplay()
    }
    func updateViewFromModel() {
        var matchedCardIndices: [Int] = []
        for (cardKey, cardStatus) in game.cards {
            if let indexOfCard = getIndex(ofCard: cardKey, ofCardView: nil, in: cardViewLookup) {
                switch cardStatus {
                case .isSelected:
                    cardViewLookup[indexOfCard].1 = .showSelectedCard(card: cardKey)
                case .isMismatched:
                    cardViewLookup[indexOfCard].1 = .showMismatch(card: cardKey)
                case .isMatched:
                    switch cardViewLookup[indexOfCard].1 {
                    case .showCard:
                        cardViewLookup[indexOfCard].1 = .showMatch(card: cardKey)
                    case .showSelectedCard:
                        cardViewLookup[indexOfCard].1 = .showMatch(card: cardKey)
                    case .showMatch:
                        if let indexOfCardToRemove = playArea.cardViews.index(of: cardViewLookup[indexOfCard].0) {
                            matchedCardIndices.append(indexOfCardToRemove)
                        }/*
                        playArea.remove(view: cardViewLookup[indexOfCard].0)
                        cardViewLookup.remove(at: indexOfCard)*/
                    default:
                        break
                    }
                case .onTable:
                    cardViewLookup[indexOfCard].1 = .showCard(card: cardKey)
                }
            } else {
                switch cardStatus {
                case .onTable:
                    print(matchedCardIndices)
                    let newCardView = playArea.addCard(card: cardKey, at: playArea.cardViews.count)
                    cardViewLookup.append((newCardView, DisplayState.showCard(card: cardKey)))
                    let tap = cardTapGesture(target: self, action: #selector(selectCard))
                    tap.card = cardKey
                    newCardView.addGestureRecognizer(tap)
                default:
                    break
                }
            }
            for cardView in playArea.cardViews {
                if let indexOfCardView = getIndex(ofCard: nil, ofCardView: cardView, in: cardViewLookup) {
                    switch cardViewLookup[indexOfCardView].1 {
                    case.showCard:
                        playArea.updateCard(in: cardView, number: nil, color: nil, fill: nil, shape: nil, outline: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
                    case .showSelectedCard:
                        playArea.updateCard(in: cardView, number: nil, color: nil, fill: nil, shape: nil, outline: #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1))
                    case .showMatch:
                        playArea.updateCard(in: cardView, number: nil, color: nil, fill: nil, shape: nil, outline: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
                    case .showMismatch:
                        playArea.updateCard(in: cardView, number: nil, color: nil, fill: nil, shape: nil, outline: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1))
                    default:
                        break
                    }
                }
            }
        }
        playArea.setNeedsDisplay()
        playArea.setNeedsLayout()
        scoreLabel.text = "Score: \(game.score)"
    }
    
    @objc private func selectCard(sender: cardTapGesture) {
        game.choose(card: sender.card)
        updateViewFromModel()
    }
    
    private func getIndex(ofCard card: Card?, ofCardView view: CardView?, in lookupArray: [(CardView, DisplayState)]) -> Int? {
        for index in lookupArray.indices {
            if let cardToFind = card, let cardAtIndex = lookupArray[index].1.getCard {
                if cardToFind == cardAtIndex {return index}
            } else if let viewToFind = view {
                if lookupArray[index].0 == viewToFind {return index}
            }
        }
        return nil
    }
}

enum DisplayState {
    case showCard(card: Card)
    case showSelectedCard(card: Card)
    case showMatch(card: Card)
    case showMismatch(card: Card)
    case hidden
}

extension DisplayState {
    var getCard: Card? {
        switch self {
        case .showCard(let card):
            return card
        case .showMatch(let card):
            return card
        case .showMismatch(let card):
            return card
        case .showSelectedCard(let card):
            return card
        case .hidden:
            return nil
        }
    }
}

extension UIButton {
    static let shadowRadius: CGFloat = 2.0
    static let shadowOffset: CGSize = CGSize(width: 1.0, height: 1.0)
    static let shadowColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let shadowOpacity: Float = 0.8
    func addShadow(withColor color: CGColor, withRadius radius: CGFloat, withOffset offset: CGSize, withOpacity opacity: Float) {
        self.layer.shadowColor = color
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
    }
    func addBorder(withColor color: CGColor, withWidth width: CGFloat) {
        self.layer.borderColor = color
        self.layer.borderWidth = width
    }
}

class cardTapGesture: UITapGestureRecognizer {
    var card = Card(withNumber: .one, withColor: .purple, withShape: .squiggle, withFill: .empty)
}
