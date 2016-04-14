//
//  GraphViewController.swift
//  Calculator.Project3
//
//  Created by Evan on 4/13/16.
//  Copyright © 2016 Evan. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource, UIPopoverPresentationControllerDelegate {
    

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "zoom:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "move:"))
            let tap = UITapGestureRecognizer(target: self, action: "center:")
            tap.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tap)
            
            if !resetOrigin {
                graphView.origin = origin
            }
            graphView.scale = scale
        }
    }
    
    private struct Keys {
        static let Scale = "GraphViewController.Scale"
        static let Origin = "GraphViewController.Origin"
        
        static let SegueIdentifier = "Show Statistics"
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private var resetOrigin: Bool {
        get {
            if let _ = defaults.objectForKey(Keys.Origin) as? [CGFloat] {
                return false
            }
            return true
        }
    }
    
    var scale: CGFloat {
        get { return defaults.objectForKey(Keys.Scale) as? CGFloat ?? 50.0 }
        set { defaults.setObject(newValue, forKey: Keys.Scale) }
    }
    
    private var origin: CGPoint {
        get {
            var origin = CGPoint()
            if let originArray = defaults.objectForKey(Keys.Origin) as? [CGFloat] {
                origin.x = originArray.first!
                origin.y = originArray.last!
            }
            return origin
        }
        set {
            defaults.setObject([newValue.x, newValue.y], forKey: Keys.Origin)
        }
    }
    
    func zoom(gesture: UIPinchGestureRecognizer) {
        graphView.zoomIn(gesture)
        if gesture.state == .Ended {
            scale = graphView.scale
            origin = graphView.origin
        }
    }
    
    func move(gesture: UIPanGestureRecognizer) {
        graphView.moveIt(gesture)
        if gesture.state == .Ended {
            origin = graphView.origin
        }
    }
    
    func center(gesture: UITapGestureRecognizer) {
        graphView.centerIt(gesture)
        if gesture.state == .Ended {
            origin = graphView.origin
        }
    }
    
    func y(x: CGFloat) -> CGFloat? {
        brain.variableValues["M"] = Double(x)
        if let y = brain.evaluate() {
            return CGFloat(y)
        }
        return nil
    }
    
    private var brain = CalculatorBrain()
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return brain.program
        }
        set {
            brain.program = newValue
        }
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
}