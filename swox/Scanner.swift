//
//  Scanner.swift
//  swox
//
//  Created by Bryce Byington on 5/5/25.
//

extension String {
    /// Returns a character at an integer (zero-based) position
    /// Credit to `devnull255` for this function!
    func charAt(at: Int) -> Character {
        let charIndex = index(startIndex, offsetBy: at)
        return self[charIndex]
    }

    func subString(from: Int, to: Int) -> String {
        let startIndex = index(self.startIndex, offsetBy: from)
        let endIndex = index(self.startIndex, offsetBy: to)
        return String(self[startIndex ..< endIndex])
    }
}

class Scanner {
    private final var source: String
    private final var tokens = [Token]()
    /// Offsets, that index into the string
    private var start: Int = 0
    private var current: Int = 0
    /// What source line `current` is on, to tie tokens to their location
    private var line: Int = 1
    
    init(source: String) {
        self.source = source
    }
    
    /// To-do: Add variables and function declarations
    func scanTokens() -> [Token] {
        while !isAtEnd() {
            /// We are at the beginning of the next lexeme
            start = current
            scanToken()
        }
        
        tokens.append(Token(type: TokenType.EOF, lexeme: "", literal: nil, line: line))
        return tokens
    }
    
    /// Scan a single token
    private func scanToken() {
        let c: Character = advance()
        switch c {
        case "(":
            addToken(type: TokenType.LEFT_PAREN)
        case ")":
            addToken(type: TokenType.RIGHT_PAREN)
        case "{":
            addToken(type: TokenType.LEFT_BRACE)
        case "}":
            addToken(type: TokenType.RIGHT_BRACE)
        case ",":
            addToken(type: TokenType.COMMA)
        case ".":
            addToken(type: TokenType.DOT)
        case "-":
            addToken(type: TokenType.MINUS)
        case "+":
            addToken(type: TokenType.PLUS)
        case ";":
            addToken(type: TokenType.SEMICOLON)
        case "*":
            addToken(type: TokenType.STAR)
        case "!":
            match(expected: "=") ?
                addToken(type: TokenType.BANG_EQUAL) :
                addToken(type: TokenType.BANG)
        case "=":
            match(expected: "=") ?
                addToken(type: TokenType.EQUAL_EQUAL) :
                addToken(type: TokenType.EQUAL)
        case "<":
            if match(expected: "=") {
                addToken(type: TokenType.LESS_EQUAL)
            } else {
                addToken(type: TokenType.LESS)
            }
        case ">":
            if match(expected: "=") {
                addToken(type: TokenType.GREATER_EQUAL)
            } else {
                addToken(type: TokenType.GREATER)
            }
        default:
            Lox.error(line: line, message: "Unexpected character")
        }
    }
    
    /// Only consume the current character if a match is found
    private func match(expected: Character) -> Bool {
        if isAtEnd() { return false }
        if source.charAt(at: current) != expected { return false }
        current += 1
        return true
    }
    
    /// Returns true if all characters have been consumed
    private func isAtEnd() -> Bool {
        return current >= source.count
    }
    
    /// Consumes next character in source and returns it
    private func advance() -> Character {
        let char = source.charAt(at: current)
        current += 1
        return char
    }
    
    /// Get text of current lexeme and create new token
    private func addToken(type: TokenType) {
        addToken(type: type, literal: nil)
    }
    
    private func addToken(type: TokenType, literal: Any?) {
        let text = source.subString(from: start, to: current)
        tokens.append(Token(type: type, lexeme: text, literal: literal, line: line))
    }
}
