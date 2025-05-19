//
//  Parser.swift
//  swox
//
//  Created by Bryce Byington on 5/18/25.
//

class Parser {
    private struct ParseError: Error {}
    
    private final var tokens: [Token]
    private var current: Int = 0
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    /// Matches any expression at any precedence level. Matching to `equality` covers everything, since it has the lowest precedence.
    private func expression() throws -> Expr {
        return try equality()
    }
    
    /// Equal to and not equal to
    private func equality() throws -> Expr {
        var expr: Expr = try comparison()
        
        while match(types: .BANG_EQUAL, .EQUAL_EQUAL) {
            let _operator: Token = previous()
            let right: Expr = try comparison()
            expr = Binary(left: expr, _operator: _operator, right: right)
        }
        
        return expr
    }
    
    /// Less than (or equal to), greater than (or equal to)
    private func comparison() throws -> Expr {
        var expr: Expr = try term()
        
        while match(types: .GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL) {
            let _operator: Token = previous()
            let right: Expr = try term()
            expr = Binary(left: expr, _operator: _operator, right: right)
        }
        
        return expr
    }
    
    /// Addition and subtraction
    private func term() throws -> Expr {
        var expr: Expr = try factor()
        
        while match(types: .MINUS, .PLUS) {
            let _operator: Token = previous()
            let right: Expr = try factor()
            expr = Binary(left: expr, _operator: _operator, right: right)
        }
        
        return expr
    }
    
    /// Multiplication and division
    private func factor() throws -> Expr {
        var expr: Expr = try unary()
        
        while match(types: .SLASH, .STAR) {
            let _operator: Token = previous()
            let right: Expr = try unary()
            expr = Binary(left: expr, _operator: _operator, right: right)
        }
        
        return expr
    }
    
    /// If `!` or `-`, get token and recursively call `unary()` again to parse the operand
    private func unary() throws -> Expr {
        if match(types: .BANG, .MINUS) {
            let _operator: Token = previous()
            let right: Expr = try unary()
            return Unary(_operator: _operator, right: right)
        }
        
        return try primary()
    }
    
    /// All literals and grouping expressions
    private func primary() throws -> Expr {
        if match(types: .FALSE) { return Literal(value: false) }
        if match(types: .TRUE) { return Literal(value: true) }
        if match(types: .NIL) { return Literal(value: nil) }
        
        if match(types: .NUMBER, .STRING) {
            return Literal(value: previous().literal)
        }
        
        if match(types: .LEFT_PAREN) {
            let expr: Expr = try expression()
            _ = try consume(type: .RIGHT_PAREN, message: "Expect ')' after expression.")
            return _Grouping(expression: expr)
        }
        
        throw error(peek(), "Expect expression.")
    }
    
    /// Returns true and consumes a token if the current token has any of the given types.
    private func match(types: TokenType...) -> Bool {
        for type in types {
            if check(type) {
                _ = advance()
                return true
            }
        }
        
        return false
    }
    
    /// Checks if the next token is of an expected type.
    private func consume(type: TokenType, message: String) throws -> Token {
        if check(type) {
            return advance()
        }
        throw error(peek(), message)
    }
    
    /// Returns true if the current token is of the given type. Does not consume the token.
    private func check(_ type: TokenType) -> Bool {
        if isAtEnd() {
            return false
        }
        return peek().type == type
    }
    
    /// Consumes the current token and returns it
    private func advance() -> Token {
        if !isAtEnd() {
            current += 1
        }
        return previous()
    }
    
    /// Checks if there are no more tokens to parse
    private func isAtEnd() -> Bool {
        return peek().type == .EOF
    }
    
    /// Returns the current token that hasn't been consumed yet
    private func peek() -> Token {
        return tokens[current]
    }
    
    /// Returns the most recently consumed token
    private func previous() -> Token {
        return tokens[current - 1]
    }
    
    /// Throwable function that reports an error
    private func error(_ token: Token, _ message: String) -> Error {
        Lox.error(token: token, message: message)
        return ParseError()
    }
    
    /// Discard tokens until statement boundary.
    private func synchronize() {
        _ = advance()
        
        while !isAtEnd() {
            if previous().type == .SEMICOLON { return }
            
            switch peek().type {
            case .CLASS, .FUN, .VAR, .FOR, .IF, .WHILE, .PRINT, .RETURN:
                return
            default: _ = advance()
            }
        }
    }
    
    func parse() -> Expr? {
        do {
            return try expression()
        }
        catch {
            return nil
        }
    }
}
