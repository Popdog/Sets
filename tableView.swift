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
    
    func addCardView(cardView: CardView, at index: Int) {
        UIView.animate(withDuration: 0.5, animations: {
            self.grid.cellCount += 1
            cardView.outlineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cardView.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            self.cardViews.insert(cardView, at: index)
            cardView.frame = self.grid[index]!.insetBy(dx: self.cardInset(), dy: self.cardInset())
            self.displayCards()
        }, completion: { finished in
            UIView.transition(with: cardView,
                              duration: 0.25,
                              options: [.transitionFlipFromLeft],
                              animations: {
                                cardView.isFaceUp = true
                                cardView.setNeedsDisplay()
            })
        })
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
            UIView.animate(withDuration: 0.5, animations: {
                self.grid.cellCount -= 1
                self.cardViews.remove(at: index)
                self.displayCards()
            })
        }
    }
    
    func replace(viewToReplace: CardView, with viewToInsert: CardView) {
        if let index = cardViews.index(of: viewToReplace) {
            cardViews.remove(at: index)
            UIView.animate(withDuration: 0.5, animations: {
                viewToInsert.outlineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                viewToInsert.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
                self.cardViews.insert(viewToInsert, at: index)
                viewToInsert.frame = self.grid[index]!.insetBy(dx: self.cardInset(), dy: self.cardInset())
            }, completion: { finished in
                UIView.transition(with: viewToInsert,
                                  duration: 0.25,
                                  options: [.transitionFlipFromLeft],
                                  animations: {
                                    viewToInsert.isFaceUp = true
                                    viewToInsert.setNeedsDisplay()
                })
            })
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
    
    @objc func shuffleCardViews() {
        cardViews = cardViews.shuffle
        displayCards()
    }
}
