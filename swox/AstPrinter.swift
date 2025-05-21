//
//  AstPrinter.swift
//  swox
//
//  Created by Bryce Byington on 5/12/25.
//

/// Credit to `cprovatas` for these spread operator functions!
extension Array {
    static func ... (lhs: [Self.Element], rhs: [Self.Element]) -> [Self.Element] {
        var copy = lhs
        copy.append(contentsOf: rhs)
        return copy
    }

    static func ... (lhs: Self.Element, rhs: [Self.Element]) -> [Self.Element] {
        var copy = [lhs]
        copy.append(contentsOf: rhs)
        return copy
    }

    static func ... (lhs: [Self.Element], rhs: Self.Element) -> [Self.Element] {
        var copy = lhs
        copy.append(rhs)
        return copy
    }
}

class AstPrinter: Visitor {
    typealias Return = String
    func printTree(expr: Expr) -> String {
        return try! expr.accept(self)
    }
    
    func visitAssignExpr(_ expr: Assign) -> String {
        return ""
    }
    
    func visitBinaryExpr(_ expr: Binary) -> String {
        return parenthesize(name: expr._operator.lexeme, exprs: expr.left, expr.right)
    }
    
    func visitCallExpr(_ expr: Call) -> String {
        return ""
    }
    
    func visitGetExpr(_ expr: Get) -> String {
        return ""
    }
    
    func visitGroupingExpr(_ expr: _Grouping) -> String {
        return parenthesize(name: "group", exprs: expr.expression)
    }
    
    func visitLiteralExpr(_ expr: Literal) -> String {
        if let value = expr.value {
            return String(describing: value)
        }
        return "nil"
    }
    
    func visitLogicalExpr(_ expr: Logical) -> String {
        return ""
    }
    
    func visitSetExpr(_ expr: _Set) -> String {
        return ""
    }
    
    func visitSuperExpr(_ expr: Super) -> String {
        return ""
    }
    
    func visitThisExpr(_ expr: This) -> String {
        return ""
    }
    
    func visitUnaryExpr(_ expr: Unary) -> String {
        return parenthesize(name: expr._operator.lexeme, exprs: expr.right)
    }
    
    func visitVariableExpr(_ expr: _Variable) -> String {
        return ""
    }
    
    private func parenthesize(name: String, exprs: Expr...) -> String {
        var result = "(\(name)"
        for expr in exprs {
            result += " " + (try! expr.accept(self))
        }
        result += ")"
        return result
    }
    
    /// Test function
    public static func testAstPrinter(args: [String]) {
        let expression = Binary(
            left: Unary(_operator: Token(type: .MINUS, lexeme: "-", literal: nil, line: 1),
                        right: Literal(value: 123)),
            _operator: Token(type: .STAR, lexeme: "*", literal: nil, line: 1),
            right: _Grouping(expression: Literal(value: 45.67)))
        print(AstPrinter().printTree(expr: expression))
    }
}
