//
//  Expr.swift
//  swox
//
//  Created by Bryce Byington on 5/10/25.
//

/// I decided to manually write all of this out by hand, mostly because porting all of `GenerateAst.java`
/// to Swift proved to be tedious enough that writing `Expr` manually was faster.

class Expr {
    func accept<V: Visitor>(_ visitor: V) throws -> V.Return {
        fatalError("Error: Function must be overridden by subclass.")
    }
}

protocol Visitor {
    associatedtype Return
    func visitAssignExpr(_ expr: Assign) -> Return
    func visitBinaryExpr(_ expr: Binary) throws -> Return
    func visitCallExpr(_ expr: Call) -> Return
    func visitGetExpr(_ expr: Get) -> Return
    func visitGroupingExpr(_ expr: _Grouping) -> Return
    func visitLiteralExpr(_ expr: Literal) throws -> Return
    func visitLogicalExpr(_ expr: Logical) -> Return
    func visitSetExpr(_ expr: _Set) -> Return
    func visitSuperExpr(_ expr: Super) -> Return
    func visitThisExpr(_ expr: This) -> Return
    func visitUnaryExpr(_ expr: Unary) -> Return
    func visitVariableExpr(_ expr: _Variable) -> Return
}

final class Assign: Expr {
    let name: Token
    let value: Expr

    init(name: Token, value: Expr) {
        self.name = name; self.value = value
    }

    override func accept<V: Visitor>(_ visitor: V) throws -> V.Return {
        return visitor.visitAssignExpr(self)
    }
}

final class Binary: Expr {
    let left: Expr
    let _operator: Token
    let right: Expr

    init(left: Expr, _operator: Token, right: Expr) {
        self.left = left; self._operator = _operator; self.right = right
    }

    override func accept<V: Visitor>(_ visitor: V) throws -> V.Return {
        return try visitor.visitBinaryExpr(self)
    }
}

final class Call: Expr {
    let callee: Expr
    let paren: Token
    let arguments: [Expr]

    init(callee: Expr, paren: Token, arguments: [Expr]) {
        self.callee = callee; self.paren = paren; self.arguments = arguments
    }

    override func accept<V: Visitor>(_ visitor: V) throws -> V.Return {
        return visitor.visitCallExpr(self)
    }
}

final class Get: Expr {
    let object: Expr
    let name: Token

    init(object: Expr, name: Token) {
        self.object = object; self.name = name
    }

    override func accept<V: Visitor>(_ visitor: V) throws -> V.Return {
        return visitor.visitGetExpr(self)
    }
}

final class _Grouping: Expr {
    let expression: Expr

    init(expression: Expr) {
        self.expression = expression
    }

    override func accept<V: Visitor>(_ visitor: V) throws -> V.Return {
        return visitor.visitGroupingExpr(self)
    }
}

final class Literal: Expr {
    let value: Any?

    init(value: Any?) {
        self.value = value
    }

    override func accept<V: Visitor>(_ visitor: V) throws -> V.Return {
        return try visitor.visitLiteralExpr(self)
    }
}

final class Logical: Expr {
    let left: Expr
    let _operator: Token
    let right: Expr

    init(left: Expr, _operator: Token, right: Expr) {
        self.left = left
        self._operator = _operator
        self.right = right
    }

    override func accept<V: Visitor>(_ visitor: V) throws -> V.Return {
        return visitor.visitLogicalExpr(self)
    }
}

final class _Set: Expr {
    let object: Expr
    let name: Token
    let value: Expr

    init(object: Expr, name: Token, value: Expr) {
        self.object = object
        self.name = name
        self.value = value
    }

    override func accept<V: Visitor>(_ visitor: V) throws -> V.Return {
        return visitor.visitSetExpr(self)
    }
}

final class Super: Expr {
    let keyword: Token
    let method: Token

    init(keyword: Token, method: Token) {
        self.keyword = keyword
        self.method = method
    }

    override func accept<V: Visitor>(_ visitor: V) throws -> V.Return {
        return visitor.visitSuperExpr(self)
    }
}

final class This: Expr {
    let keyword: Token

    init(keyword: Token) {
        self.keyword = keyword
    }

    override func accept<V: Visitor>(_ visitor: V) throws -> V.Return {
        return visitor.visitThisExpr(self)
    }
}

final class Unary: Expr {
    let _operator: Token
    let right: Expr

    init(_operator: Token, right: Expr) {
        self._operator = _operator
        self.right = right
    }

    override func accept<V: Visitor>(_ visitor: V) throws -> V.Return {
        return visitor.visitUnaryExpr(self)
    }
}

final class _Variable: Expr {
    let name: Token

    init(name: Token) {
        self.name = name
    }

    override func accept<V: Visitor>(_ visitor: V) throws -> V.Return {
        return visitor.visitVariableExpr(self)
    }
}
