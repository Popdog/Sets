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
    
    override func viewDidLoad() { // Initialize playArea
        super.viewDidLoad()
        if let table = self.playArea {
            table.grid = Grid(layout: .aspectRatio(0.75), frame: table.bounds)
        }
    }
    @IBAction func shuffleViews(_ sender: UIRotationGestureRecognizer) {
        switch sender.state {
        case .ended:
            playArea.shuffleCardViews()
        default:
            break
        }
    }
    
    @IBOutlet weak var newGameButton: UIButton! { //Add border and shadow to newGameButton
        didSet{
            newGameButton.addShadow(withColor: UIView.shadowColor, withRadius: UIView.shadowRadius, withOffset: UIView.shadowOffset, withOpacity: UIView.shadowOpacity)
            newGameButton.addBorder(withColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), withWidth: 2.0)
            newGameButton.layer.cornerRadius = 8.0
        }
    }
    @IBOutlet weak var dealButton: UIButton! { //Add border and shadow to dealButton
        didSet{
            dealButton.addShadow(withColor: UIView.shadowColor, withRadius: UIView.shadowRadius, withOffset: UIButton.shadowOffset, withOpacity: UIView.shadowOpacity)
            dealButton.addBorder(withColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), withWidth: 2.0)
            dealButton.layer.cornerRadius = 8.0
        }
    }
    
    @IBOutlet weak var scoreLabel: UILabel! {
        didSet{
            scoreLabel.addShadow(withColor: UIView.shadowColor, withRadius: UIView.shadowRadius, withOffset: UIButton.shadowOffset, withOpacity: UIView.shadowOpacity)
            scoreLabel.addBorder(withColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), withWidth: 2.0)
            scoreLabel.layer.cornerRadius = 4.0
        }
    }
    
    @IBAction func newGame(_ sender: UIButton) { // On starting a new game...
        cardViewLookup = [] //Empty the card view lookup array
        playArea.removeAll() //Remove all card views from the play area
        game.newGame() //Start a new game
        updateViewFromModel() //Refresh the view
    }
    @IBAction func dealCards(_ sender: UIButton) { //Deal three cards (constant cardsToDeal = 3)
        game.deal(cards: ViewController.cardsToDeal)
        updateViewFromModel()
        playArea.setNeedsDisplay()
    }
    func updateViewFromModel() {//Updates the view to reflect the state of the game
        var matchedCardViews: [CardView] = [] //Array to hold matched cards that need to be removed
        var replacements: [Card] = [] //Array that will hold cards to replace matched cards
        for (cardKey, cardStatus) in game.cards { //Look through all of the cards in play
            if cardStatus == .isMatched, let indexOfCard = getIndex(ofCard: cardKey, ofCardView: nil, in: cardViewLookup) { //If a card is matched...
                switch cardViewLookup[indexOfCard].1 {
                case .showMatch: //And it is currently being displayed as a match
                    matchedCardViews.append(cardViewLookup[indexOfCard].0) //Then it needs to be removed from view
                default:
                    break
                }
            }
        }
        for (cardKey, cardStatus) in game.cards { //Look through all cards again, this time handling all other cases
            if let indexOfCard = getIndex(ofCard: cardKey, ofCardView: nil, in: cardViewLookup) { //If the card is already being displayed...
                switch cardStatus {
                case .isSelected: //... and the card is selected, display it as selected
                    cardViewLookup[indexOfCard].1 = .showSelectedCard(card: cardKey)
                case .isMismatched: //... and the card is mismatched, display it as mismatched
                    cardViewLookup[indexOfCard].1 = .showMismatch(card: cardKey)
                case .isMatched://... and the card is matched...
                    switch cardViewLookup[indexOfCard].1 {//... display it as matched
                    case .showCard:
                        cardViewLookup[indexOfCard].1 = .showMatch(card: cardKey)
                    case .showSelectedCard:
                        cardViewLookup[indexOfCard].1 = .showMatch(card: cardKey)
                    default:
                        break
                    }
                case .onTable: //... and the card is on the table (unselected, unmatched, not ismatched)
                    cardViewLookup[indexOfCard].1 = .showCard(card: cardKey)
                }
            } else { //If the card is not currently displayed on a view...
                switch cardStatus {
                case .onTable://... if it is on the table (in the model)...
                    if matchedCardViews.count > 0 { //...and there is a matched card which needs to be replaced
                        replacements.append(cardKey)//... add the card as a replacement for a matched card
                    } else { //... and there are not matched cards to replace...
                        let newCardView = playArea.addCard(card: cardKey, at: playArea.cardViews.count)
                        cardViewLookup.append((newCardView, DisplayState.showCard(card: cardKey)))
                        let tap = cardTapGesture(target: self, action: #selector(selectCard))
                        tap.card = cardKey
                        newCardView.addGestureRecognizer(tap)//...then create a new view and add it at the end of the table
                    }
                default:
                    break
                }
            }
        }
        for view in matchedCardViews { //For every matched card which needs to be removed
            let indexToReplace = playArea.cardViews.index(of: view)! //Get the card's index in the playArea
            cardViewLookup.remove(at: getIndex(ofCard: nil, ofCardView: view, in: cardViewLookup)!)
            playArea.remove(view: view) //Remove the matched card from the playArea
            if replacements.count > 0 { //If there is a card available to replace the matched card with
                let card = replacements.removeFirst()
                let newCardView = playArea.addCard(card: card, at: indexToReplace) //Create a new view and insert it in the matched card's place
                cardViewLookup.append((newCardView, DisplayState.showCard(card: card)))
                let tap = cardTapGesture(target: self, action: #selector(selectCard))
                tap.card = card
                newCardView.addGestureRecognizer(tap)
            }
        }
        for cardView in playArea.cardViews { //Update every card view's border according to its status
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
        playArea.setNeedsDisplay()
        playArea.setNeedsLayout()
        scoreLabel.text = "Score: \(game.score)"
    }
    
    @objc private func selectCard(sender: cardTapGesture) { //Method to select a card when the user taps it
        game.choose(card: sender.card)
        updateViewFromModel()
    }
    
    private func getIndex(ofCard card: Card?, ofCardView view: CardView?, in lookupArray: [(CardView, DisplayState)]) -> Int? { //Returns the index of a (CardView,DisplayState) tuple from a lookUp array based on a given Card OR a given CardView
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

enum DisplayState { //Different display states a card can have
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

extension UIView {
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
