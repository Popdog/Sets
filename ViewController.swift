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
    private var cardDisplays: [CardDisplay] = []
    
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
        cardDisplays = []
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
            if let cardViewIndex = getIndexOfCardDisplay(displaying: cardKey, in: cardDisplays) {
                switch cardStatus {
                case .isSelected:
                    cardDisplays[cardViewIndex].displayState = .showSelectedCard(card: cardKey)
                case .isMismatched:
                    cardDisplays[cardViewIndex].displayState = .showMismatch(card: cardKey)
                case .isMatched:
                    let cardState = cardDisplays[cardViewIndex].displayState
                        switch cardState {
                        case .showCard:
                            cardDisplays[cardViewIndex].displayState = .showMatch(card: cardKey)
                        case .showSelectedCard:
                            cardDisplays[cardViewIndex].displayState = .showMatch(card: cardKey)
                        case .showMatch:
                            if let removedIndex = playArea.cardViews.index(of: cardDisplays[cardViewIndex].view) {
                                matchedCardIndices.append(removedIndex)
                            }
                            cardDisplays.remove(at: getIndexOfCardDisplay(displaying: cardKey, in: cardDisplays)!)
                            playArea.remove(view: cardDisplays[cardViewIndex].view)
                        default:
                            break
                        }
                case .onTable:
                    cardDisplays[cardViewIndex].displayState = .showCard(card: cardKey)
                }
            } else {
                switch cardStatus {
                case .onTable:
                    let newCardView: CardView
                    if matchedCardIndices.count > 0 {
                        newCardView = playArea.addCard(card: cardKey, at: matchedCardIndices.removeFirst())
                    } else {
                        newCardView = playArea.addCard(card: cardKey, at: playArea.cardViews.count)
                    }
                    let newCardDisplay = CardDisplay(view: newCardView, displayState: .showCard(card: cardKey))
                    cardDisplays.append(newCardDisplay)
                    let tap = cardTapGesture(target: self, action: #selector(selectCard))
                    tap.card = cardKey
                    newCardView.addGestureRecognizer(tap)
                default:
                    break
                }
            }
            for cardDisplay in cardDisplays {
                let outlineColor: UIColor
                switch cardDisplay.displayState {
                case .showSelectedCard:
                    outlineColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
                case .showMatch:
                    outlineColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                case .showMismatch:
                    outlineColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                default:
                    outlineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                }
                playArea.updateCard(in: cardDisplay.view, number: nil, color: nil, fill: nil, shape: nil, outline: outlineColor)
            }
        }
        playArea.setNeedsDisplay()
        playArea.setNeedsLayout()
        scoreLabel.text = "Score: \(game.score)"
        print("CardDisplay Cards:")
        for cardDisplay in cardDisplays {
            print(cardDisplay.displayState.getCard!.identifier)
        }
        print("********")
    }
    
    @objc private func selectCard(sender: cardTapGesture) {
        game.choose(card: sender.card)
        updateViewFromModel()
    }
    
    private func getIndexOfCardDisplay(displaying card: Card, in cardDisplays: [CardDisplay]) -> Int? {
        for index in cardDisplays.indices {
            if let displayedCard = cardDisplays[index].displayState.getCard {
                if displayedCard == card {
                    return index
                }
            }
        }
        return nil
    }
}

struct CardDisplay {
    let view: CardView
    var displayState: DisplayState
    init(view: CardView, displayState: DisplayState) {
        self.view = view
        self.displayState = displayState
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
