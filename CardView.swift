//
//  CardView.swift
//  Sets
//
//  Created by William Myers on 5/16/18.
//  Copyright © 2018 William Myers. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {
    var number: Number = .one
    var shape: Shape = .squiggle
    var fill: Fill = .striped
    var color: Color = .purple
    var outlineColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let shapeInset: CGFloat = 5.0
    static let stripeWidth: CGFloat = 3.0
    
    override func draw(_ rect: CGRect) {
        let outlinePath = UIBezierPath.init(roundedRect: bounds, cornerRadius: (bounds.maxX - bounds.minX)/4)
        outlineColor.setStroke()
        outlinePath.lineWidth = (bounds.maxX - bounds.minX) / 20
        outlinePath.stroke()
        
        let path = createPath(in: Grid(layout: .dimensions(rowCount: 3, columnCount: 1), frame: bounds))
        var strokeColor: UIColor

        switch color {
        case .green:
            strokeColor = UIColor.green
        case .purple:
            strokeColor = UIColor.purple
        case .red:
            strokeColor = UIColor.red
        }
        strokeColor.setStroke()
        path.stroke()
        
        switch fill {
        case .solid:
            strokeColor.setFill()
            path.fill()
        case .striped:
            path.addClip()
            let stripePath = addStripes(in: rect)
            stripePath.stroke()
        case .empty:
            break
        }

    }
    
    func createPath(in grid: Grid) -> UIBezierPath {
        var path = UIBezierPath()
        let pathsToDraw = number.rawValue
        for index in 0..<pathsToDraw {
            switch shape {
            case .oval:
                path = addOval(to: path, in: grid[index]!.insetBy(dx: CardView.shapeInset, dy: CardView.shapeInset))
            case .diamond:
                path = addDiamond(to: path, in: grid[index]!.insetBy(dx: CardView.shapeInset, dy: CardView.shapeInset))
            case .squiggle:
                path = addSquiggle(to: path, in: grid[index]!.insetBy(dx: CardView.shapeInset, dy: CardView.shapeInset))
            }
        }
        return path
    }
    
    func addDiamond(to path: UIBezierPath, in gridRect: CGRect) -> UIBezierPath {
        let left = CGPoint(x: gridRect.minX, y: gridRect.midY)
        let right = CGPoint(x: gridRect.maxX, y: gridRect.midY)
        let topCenter = CGPoint(x: gridRect.midX, y: gridRect.maxY)
        let bottomCenter = CGPoint(x: gridRect.midX, y: gridRect.minY)
        path.move(to: left)
        path.addLine(to: topCenter)
        path.addLine(to: right)
        path.addLine(to: bottomCenter)
        path.addLine(to: left)
        
        return path
    }
    
    func addOval(to path: UIBezierPath, in gridRect: CGRect) -> UIBezierPath {
        let ovalPath = UIBezierPath.init(roundedRect: gridRect, cornerRadius: (gridRect.maxX - gridRect.minX) / 4)
        path.append(ovalPath)
        return path
    }
    
    func addSquiggle(to path: UIBezierPath, in gridRect: CGRect) -> UIBezierPath {
        let upperLeft = CGPoint(x: gridRect.minX, y: gridRect.minY)
        let lowerRight = CGPoint(x: gridRect.maxX, y: gridRect.maxY)
        let oneQuarterX = gridRect.minX + (gridRect.maxX - gridRect.minX)/4
        let threeQuarterX = gridRect.minX + 3*(gridRect.maxX - gridRect.minX)/4
        path.move(to: upperLeft)
        path.addCurve(to: lowerRight, controlPoint1: CGPoint(x: oneQuarterX, y: gridRect.midY), controlPoint2: CGPoint(x: threeQuarterX, y: gridRect.minY   ))
        path.addCurve(to: upperLeft, controlPoint1: CGPoint(x: threeQuarterX, y: gridRect.midY), controlPoint2: CGPoint(x: oneQuarterX, y: gridRect.maxY))
        return path
    }
    
    func addStripes(in gridRect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        var xCoord = gridRect.minX
        path.move(to: CGPoint(x: xCoord, y: gridRect.maxY))
        while xCoord < gridRect.maxX {
            path.addLine(to: CGPoint(x: xCoord, y: gridRect.minY))
            xCoord += CardView.stripeWidth
            path.move(to: CGPoint(x: xCoord, y: gridRect.maxY))
        }
        return path
    }
}
