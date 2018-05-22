//
//  tableView.swift
//  Sets
//
//  Created by William Myers on 5/17/18.
//  Copyright © 2018 William Myers. All rights reserved.
//

import UIKit

@IBDesignable
class tableView: UIView {
    var grid = Grid(layout: .aspectRatio(0.75))
    var cardViews: [CardView] = []
    lazy var cardInset = {
        CGFloat(-0.2*(Double(self.grid.cellCount) - 81.0))
    }
    
    override func draw(_ rect: CGRect) {
        grid.frame = bounds
        displayCards()
    }
    
    func addCard(card: Card, at index: Int) -> CardView {
        let index = grid.cellCount
        grid.cellCount += 1
        let newCard = CardView(frame: grid[index]!.insetBy(dx: cardInset(), dy: cardInset()))
        newCard.backgroundColor = UIColor.clear
        newCard.color = card.color
        newCard.number = card.number
        newCard.fill = card.fill
        newCard.shape = card.shape
        newCard.outlineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cardViews.insert(newCard, at: index)
        self.addSubview(newCard)
        displayCards()
        return newCard
    }
    
    func updateCard(in view: CardView, number: Number?, color: Color?, fill: Fill?, shape: Shape?, outline: UIColor?) {
        if let index = cardViews.index(of: view) {
            if let newNumber = number { cardViews[index].number = newNumber }
            if let newColor = color { cardViews[index].color = newColor }
            if let newFill = fill { cardViews[index].fill = newFill }
            if let newShape = shape { cardViews[index].shape = newShape }
            if let newOutline = outline { cardViews[index].outlineColor = newOutline }
        }
    }
    
    func remove(view: CardView) {
        if let index = cardViews.index(of: view) {
            grid.cellCount -= 1
            cardViews[index].removeFromSuperview()
            cardViews.remove(at: index)
            displayCards()
        }
    }
    
    func displayCards() {
        for index in cardViews.indices {
            cardViews[index].frame = grid[index]!.insetBy(dx: cardInset(), dy: cardInset())
            cardViews[index].setNeedsDisplay()
        }
    }
    
    func removeAll() {
        for view in cardViews {
            view.removeFromSuperview()
            cardViews.remove(at: cardViews.index(of: view)!)
        }
        grid.cellCount = 0
    }
}
