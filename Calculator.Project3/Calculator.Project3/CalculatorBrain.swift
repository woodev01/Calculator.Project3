//
//  CalculatorBrain.swift
//  Calculator.Project2
//
//  Created by Evan on 4/11/16.
//  Copyright © 2016 Evan. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var opStack = [Op]()                                //Array<Op>()
    var variableValues = [String:Double]()
    private var knownOps = [String:Op]()                     //Dictionary<String, Op>()
    
    var description: String {
        get {
            func desGetter(ops: [Op]) -> (String, [Op]) {
                var opList = ops
                var acc = ""
                var nAcc = ""
                var nVal = [Op]()
                if !ops.isEmpty {
                    let op = opList.removeLast()
                    switch op {
                    case .Operand(let operand):
                        acc = operand.description
                        
                        return (acc, opList)
                        
                    case .Variable(let variable):
                        acc = acc + variable
                        
                        return (acc, opList)
                    case .UnaryOperation(let symbol, _):
                        (nAcc, nVal) = desGetter(opList)
                        acc = symbol + "(" + nAcc + ")"
                        return (acc, nVal)
                    case .BinaryOperation(let symbol, _):
                        var nAcc2 = ""
                        var nVal2 = [Op]()
                        (nAcc, nVal) = desGetter(opList)
                        (nAcc2, nVal2) = desGetter(nVal)
                        acc = "(" + nAcc + symbol + nAcc2 + ")"
                        return (acc, nVal2)
                    case .NullaryOperation(let symbol, _):
                        return (symbol, opList)

                    }
                }
                return("?", ops)
            }
            let ops = opStack
            var acc = ""
            
            (acc, _) = desGetter(ops)
            
            return acc + "="
        }
    }
    
    private enum Op : CustomStringConvertible {
    
        case Operand(Double)
        case Variable(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case NullaryOperation(String, () -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let variable):
                    return "\(variable)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .NullaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("-") { $1 - $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("Sin", sin))
        learnOp(Op.UnaryOperation("Cos", cos))
        learnOp(Op.NullaryOperation("π", { M_PI }))
        
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let variable):
                if let value = variableValues[variable] {
                    return (value, remainingOps)
                } else {
                    return (nil, remainingOps)
                }
            case .UnaryOperation(_ , let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_ , let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .NullaryOperation(_, let operation):
                return(operation(), remainingOps)
            }
        }
        return(nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
}