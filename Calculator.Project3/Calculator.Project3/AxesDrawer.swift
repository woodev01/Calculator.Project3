//
//  AxesDrawer.swift
//  Calculator.Project3
//
//  Created by Evan on 4/13/16.
//  Copyright © 2016 Evan. All rights reserved.
//

import UIKit

class AxesDrawer
{
    private struct Constants {
        static let HashmarkSize: CGFloat = 6
    }
    
    var color = UIColor.blackColor()
    var minimumPointsPerHashmark: CGFloat = 40
    var contentScaleFactor: CGFloat = 1
    
    convenience init(color: UIColor, contentScaleFactor: CGFloat) {
        self.init()
        self.color = color
        self.contentScaleFactor = contentScaleFactor
    }
    
    convenience init(color: UIColor) {
        self.init()
        self.color = color
    }
    
    convenience init(contentScaleFactor: CGFloat) {
        self.init()
        self.contentScaleFactor = contentScaleFactor
    }
    
    
    func drawAxesInRect(bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat)
    {
        CGContextSaveGState(UIGraphicsGetCurrentContext())
        color.set()
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: bounds.minX, y: align(origin.y)))
        path.addLineToPoint(CGPoint(x: bounds.maxX, y: align(origin.y)))
        path.moveToPoint(CGPoint(x: align(origin.x), y: bounds.minY))
        path.addLineToPoint(CGPoint(x: align(origin.x), y: bounds.maxY))
        path.stroke()
        drawHashmarksInRect(bounds, origin: origin, pointsPerUnit: abs(pointsPerUnit))
        CGContextRestoreGState(UIGraphicsGetCurrentContext())
    }
    
    private func drawHashmarksInRect(bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat)
    {
        if ((origin.x >= bounds.minX) && (origin.x <= bounds.maxX)) || ((origin.y >= bounds.minY) && (origin.y <= bounds.maxY))
        {
            var unitsPerHashmark = minimumPointsPerHashmark / pointsPerUnit
            if unitsPerHashmark < 1 {
                unitsPerHashmark = pow(10, ceil(log10(unitsPerHashmark)))
            } else {
                unitsPerHashmark = floor(unitsPerHashmark)
            }
            
            let pointsPerHashmark = pointsPerUnit * unitsPerHashmark

            var startingHashmarkRadius: CGFloat = 1
            if !CGRectContainsPoint(bounds, origin) {
                let leftx = max(origin.x - bounds.maxX, 0)
                let rightx = max(bounds.minX - origin.x, 0)
                let downy = max(origin.y - bounds.minY, 0)
                let upy = max(bounds.maxY - origin.y, 0)
                startingHashmarkRadius = min(min(leftx, rightx), min(downy, upy)) / pointsPerHashmark + 1
            }

            let bboxSize = pointsPerHashmark * startingHashmarkRadius * 2
            var bbox = CGRect(center: origin, size: CGSize(width: bboxSize, height: bboxSize))

            let formatter = NSNumberFormatter()
            formatter.maximumFractionDigits = Int(round(-log10(Double(unitsPerHashmark))))
            formatter.minimumIntegerDigits = 1

            while !CGRectContainsRect(bbox, bounds)
            {
                let label = formatter.stringFromNumber((origin.x-bbox.minX)/pointsPerUnit)!
                if let leftHashmarkPoint = alignedPoint(x: bbox.minX, y: origin.y, insideBounds:bounds) {
                    drawHashmarkAtLocation(leftHashmarkPoint, .Top("-\(label)"))
                }
                if let rightHashmarkPoint = alignedPoint(x: bbox.maxX, y: origin.y, insideBounds:bounds) {
                    drawHashmarkAtLocation(rightHashmarkPoint, .Top(label))
                }
                if let topHashmarkPoint = alignedPoint(x: origin.x, y: bbox.minY, insideBounds:bounds) {
                    drawHashmarkAtLocation(topHashmarkPoint, .Left(label))
                }
                if let bottomHashmarkPoint = alignedPoint(x: origin.x, y: bbox.maxY, insideBounds:bounds) {
                    drawHashmarkAtLocation(bottomHashmarkPoint, .Left("-\(label)"))
                }
                bbox.insetInPlace(dx: -pointsPerHashmark, dy: -pointsPerHashmark)
            }
        }
    }
    
    private func drawHashmarkAtLocation(location: CGPoint, _ text: AnchoredText)
    {
        var dx: CGFloat = 0, dy: CGFloat = 0
        switch text {
        case .Left: dx = Constants.HashmarkSize / 2
        case .Right: dx = Constants.HashmarkSize / 2
        case .Top: dy = Constants.HashmarkSize / 2
        case .Bottom: dy = Constants.HashmarkSize / 2
        }
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: location.x-dx, y: location.y-dy))
        path.addLineToPoint(CGPoint(x: location.x+dx, y: location.y+dy))
        path.stroke()
        
        text.drawAnchoredToPoint(location, color: color)
    }
    
    private enum AnchoredText
    {
        case Left(String)
        case Right(String)
        case Top(String)
        case Bottom(String)
        
        static let VerticalOffset: CGFloat = 3
        static let HorizontalOffset: CGFloat = 6
        
        func drawAnchoredToPoint(location: CGPoint, color: UIColor) {
            let attributes = [
                NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote),
                NSForegroundColorAttributeName : color
            ]
            var textRect = CGRect(center: location, size: text.sizeWithAttributes(attributes))
            switch self {
            case Top: textRect.origin.y += textRect.size.height / 2 + AnchoredText.VerticalOffset
            case Left: textRect.origin.x += textRect.size.width / 2 + AnchoredText.HorizontalOffset
            case Bottom: textRect.origin.y -= textRect.size.height / 2 + AnchoredText.VerticalOffset
            case Right: textRect.origin.x -= textRect.size.width / 2 + AnchoredText.HorizontalOffset
            }
            text.drawInRect(textRect, withAttributes: attributes)
        }
        
        var text: String {
            switch self {
            case Left(let text): return text
            case Right(let text): return text
            case Top(let text): return text
            case Bottom(let text): return text
            }
        }
    }
    
    private func alignedPoint(x x: CGFloat, y: CGFloat, insideBounds: CGRect? = nil) -> CGPoint?
    {
        let point = CGPoint(x: align(x), y: align(y))
        if let permissibleBounds = insideBounds {
            if (!CGRectContainsPoint(permissibleBounds, point)) {
                return nil
            }
        }
        return point
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * contentScaleFactor) / contentScaleFactor
    }
}

extension CGRect
{
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x-size.width/2, y: center.y-size.height/2, width: size.width, height: size.height)
    }
}