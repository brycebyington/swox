//
//  Interpreter.swift
//  swox
//
//  Created by Bryce Byington on 5/21/25.
//

class Interpreter: Visitor {
    typealias Return = Any?
    
    /// Convert the literal tree node into a runtime value.
    public func visitLiteralExpr(_ expr: Literal) -> Any? {
        return expr.value
    }
    
    /// Result of using explicit parenthesis in an expression. Recursively evaluate sub-expressions inside the parentheses.
    public func visitGroupingExpr(_ expr: _Grouping) -> Any? {
        do {
            return try evaluate(expr.expression)
        } catch let error as RuntimeError {
            Lox.runtimeError(error: error)
            return nil
        } catch {
            fatalError("Unexpected error: \(error)")
        }
    }
    
    /// Evaluate the operand expression and apply the unary operator to the result.
    public func visitUnaryExpr(_ expr: Unary) -> Any? {
        let right = try! evaluate(expr.right)
        
        switch expr._operator.type {
        case .BANG: return !isTruthy(right)
            
        case .MINUS:
            try! checkNumberOperand(expr._operator, right!)
            /// Negate the result of the subexpression. Typecast `right` as Double.
            return -(right as! Double)
            
        default:
            break
        }
        
        return nil
    }
    
    // MARK: - Temporary Visitor Conformance

    public func visitAssignExpr(_ expr: Assign) -> Any? {
        fatalError("visitAssignExpr(_:) not implemented")
    }

    public func visitLogicalExpr(_ expr: Logical) -> Any? {
        fatalError("visitLogicalExpr(_:) not implemented")
    }

    public func visitSetExpr(_ expr: _Set) -> Any? {
        fatalError("visitSetExpr(_:) not implemented")
    }

    public func visitGetExpr(_ expr: Get) -> Any? {
        fatalError("visitGetExpr(_:) not implemented")
    }

    public func visitCallExpr(_ expr: Call) -> Any? {
        fatalError("visitCallExpr(_:) not implemented")
    }

    public func visitSuperExpr(_ expr: Super) -> Any? {
        fatalError("visitSuperExpr(_:) not implemented")
    }

    public func visitThisExpr(_ expr: This) -> Any? {
        fatalError("visitThisExpr(_:) not implemented")
    }

    public func visitVariableExpr(_ expr: _Variable) -> Any? {
        fatalError("visitVariableExpr(_:) not implemented")
    }
    
    /// Check the object's type to make sure that it is a number.
    private func checkNumberOperand(_ _operator: Token, _ operand: Any) throws {
        if type(of: operand) == Double.self { return }
        throw RuntimeError(_operator, "Operand must be a number.")
    }
    
    /// Check multiple objects' types
    private func checkNumberOperands(_ _operator: Token, _ left: Any, _ right: Any) throws {
        if type(of: left) == Double.self && type(of: right) == Double.self { return }
        throw RuntimeError(_operator, "Operands must be numbers.")
    }
    
    /// `false` and `nil` are falsey, everything else is truthy.
    private func isTruthy(_ object: Any?) -> Bool {
        if object == nil { return false }
        if type(of: object) == Bool.self { return object as! Bool }
        return true
    }
    
    /// Not going to lie, I cheated on this one. Wasn't quite as simple as just writing `a.equals(b)`.
    private func isEqual(_ a: Any?, _ b: Any?) -> Bool {
        switch (a, b) {
        case (nil, nil):
            return true
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        default:
            return false
        }
    }
    
    /// Convert a Lox value to a string
    private func stringify(_ object: Any?) -> String {
        if object == nil { return "nil" }
        
        if type(of: object) == Double.self {
            var text = object as! String
            if text.hasSuffix(".0") {
                text = text.subString(from: 0, to: text.count - 2)
            }
            return text
        }
        return object as! String
    }
    
    /// Helper method which sends the expression back into the interpreter's visitor implementation.
    private func evaluate(_ expr: Expr) throws -> Any? {
        return try expr.accept(self)
    }
    
    /// Arithmetic operators
    public func visitBinaryExpr(_ expr: Binary) throws -> Any? {
        let left = try! evaluate(expr.left)
        let right = try! evaluate(expr.right)
        
        switch expr._operator.type {
        case .GREATER:
            try! checkNumberOperands(expr._operator, left!, right!)
            return (left as! Double) > (right as! Double)
        case .GREATER_EQUAL:
            try! checkNumberOperands(expr._operator, left!, right!)
            return (left as! Double) >= (right as! Double)
        case .LESS:
            try! checkNumberOperands(expr._operator, left!, right!)
            return (left as! Double) < (right as! Double)
        case .LESS_EQUAL:
            try! checkNumberOperands(expr._operator, left!, right!)
            return (left as! Double) <= (right as! Double)
        case .BANG_EQUAL: return !isEqual(left, right)
        case .EQUAL_EQUAL: return isEqual(left, right)
        case .MINUS:
            try! checkNumberOperands(expr._operator, left!, right!)
            return (left as! Double) - (right as! Double)
        case .SLASH:
            try! checkNumberOperands(expr._operator, left!, right!)
            return (left as! Double) / (right as! Double)
        case .STAR:
            try! checkNumberOperands(expr._operator, left!, right!)
            return (left as! Double) * (right as! Double)
        case .PLUS:
            /// Numerical addition
            if let l = left as? Double, let r = right as? Double {
                return l + r
            }
            /// String concatenation
            if let l = left as? String, let r = right as? String {
                return l + r
            }
            /// Throw error if trying to add non-compatible operands
            throw RuntimeError(expr._operator, "Operands must be two numbers or strings.")
        default: break
        }
        return nil
    }
    
    func interpret(_ expression: Expr) {
        do {
            let value = try evaluate(expression)
            print(String(describing: value))
        } catch {
            guard let error = error as? RuntimeError else {
                fatalError("Unexpected error: \(error)")
            }
            Lox.runtimeError(error: error)
        }
    }
}
