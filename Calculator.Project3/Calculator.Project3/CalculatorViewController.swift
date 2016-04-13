//
//  ViewController.swift
//  Calculator.Project1
//
//  Created by Evan on 4/6/16.
//  Copyright © 2016 Evan. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {


    @IBOutlet weak var DisplayValue: UILabel!
    @IBOutlet weak var StackValue: UILabel!
    
    var brain = CalculatorBrain()
    
    var checkForNumStart: Bool = false
    var checkForAlreadyAFloat: Bool = false
    
    @IBAction func numKeys(sender: UIButton) {
        var keyValue = sender.currentTitle!
        if(keyValue == ".") {
            if checkForNumStart {
                if checkForAlreadyAFloat {
                    keyValue = ""
                } else {
                    checkForAlreadyAFloat = true
                }
            }
        }
        if checkForNumStart {
            DisplayValue.text = DisplayValue.text! + keyValue
        } else {
            DisplayValue.text = keyValue
            checkForNumStart = true
        }
    }
    
    
    @IBAction func operatorKeys(sender: UIButton) {
        if checkForNumStart {
            enterKey()
        }
        if let operation = sender.currentTitle {
            displayedValue = brain.performOperation(operation)
            StackValue.text = brain.description
        }
    }
    
    @IBAction func setVariable(sender: UIButton) {
        let variable = sender.currentTitle!.characters.last!
        if displayedValue != nil {
            brain.variableValues["\(variable)"] = displayedValue
            displayedValue = brain.evaluate()
        }
        
        checkForNumStart = false
    }
    
    
    @IBAction func pushVariable(sender: UIButton) {
        if checkForNumStart {
            enterKey()
        }
        displayedValue = brain.pushOperand(sender.currentTitle!)
        
    }
    
    
    @IBAction func enterKey() {
        displayedValue = brain.pushOperand(displayedValue!)
        StackValue.text = brain.description
        
        checkForNumStart = false
        checkForAlreadyAFloat = false
    }
    
    
    @IBAction func clearKey() {
        DisplayValue.text = "0"
        StackValue.text = " "
        brain = CalculatorBrain()
        checkForNumStart = false
        checkForAlreadyAFloat = false
    }
    
    
    
    
    var displayedValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(DisplayValue.text!)!.doubleValue
        }
        set {
            if let val = newValue {
                DisplayValue.text = "\(val)"
                checkForNumStart = false
                checkForAlreadyAFloat = false
            } else {
                DisplayValue.text = " "
            }
        }
    }
}

