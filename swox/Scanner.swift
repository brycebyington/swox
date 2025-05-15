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

    func split(splitter: String) -> [String] {
        return components(separatedBy: splitter)
    }

    /// Returns  a new string without whitespaces
    func trim() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    private static let keywords: [String: TokenType] = [
        "and": .AND,
        "class": .CLASS,
        "else": .ELSE,
        "false": .FALSE,
        "for": .FOR,
        "fun": .FUN,
        "if": .IF,
        "nil": .NIL,
        "or": .OR,
        "print": .PRINT,
        "return": .RETURN,
        "super": .SUPER,
        "this": .THIS,
        "true": .TRUE,
        "var": .VAR,
        "while": .WHILE
    ]
    
    func scanTokens() -> [Token] {
        while !isAtEnd() {
            /// We are at the beginning of the next lexeme
            start = current
            scanToken()
        }
        
        tokens.append(Token(type: .EOF, lexeme: "", literal: nil, line: line))
        return tokens
    }
    
    /// Scan a single token
    private func scanToken() {
        let c: Character = advance()
        switch c {
        case "(":
            addToken(type: .LEFT_PAREN)
        case ")":
            addToken(type: .RIGHT_PAREN)
        case "{":
            addToken(type: .LEFT_BRACE)
        case "}":
            addToken(type: .RIGHT_BRACE)
        case ",":
            addToken(type: .COMMA)
        case ".":
            addToken(type: .DOT)
        case "-":
            addToken(type: .MINUS)
        case "+":
            addToken(type: .PLUS)
        case ";":
            addToken(type: .SEMICOLON)
        case "*":
            addToken(type: .STAR)
        case "!":
            match(expected: "=") ?
                addToken(type: .BANG_EQUAL) :
                addToken(type: .BANG)
        case "=":
            match(expected: "=") ?
                addToken(type: .EQUAL_EQUAL) :
                addToken(type: .EQUAL)
        case "<":
            if match(expected: "=") {
                addToken(type: .LESS_EQUAL)
            } else {
                addToken(type: .LESS)
            }
        case ">":
            if match(expected: "=") {
                addToken(type: .GREATER_EQUAL)
            } else {
                addToken(type: .GREATER)
            }
        case "/":
            if match(expected: "/") {
                /// A comment goes until the end of the line
                while peek() != "\n", !isAtEnd() {
                    _ = advance()
                }
            } else {
                addToken(type: .SLASH)
            }
        case " ", "\r", "\t":
            /// Ignore whitespace
            break
        case "\n":
            line += 1
        case "\"":
            string()
        case _ where isDigit(c: c):
            number()
        case _ where isAlpha(c: c):
            identifier()
        default:
            Lox.error(line: line, message: "Unexpected character")
        }
    }
    
    /// Determine identifiers
    private func identifier() {
        while isAlphaNumeric(c: peek()) {
            _ = advance()
        }
        
        let text = source.subString(from: start, to: current)
        var type = Scanner.keywords[text]
        /// After scanning an identifer, check for matches in `keywords`
        if type == nil {
            /// If no matches are found, the token is an `IDENTIFIER`
            type = .IDENTIFIER
        }
        
        addToken(type: type!)
    }
    
    /// Return true if character is a letter A-z
    private func isAlpha(c: Character) -> Bool {
        return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || c == "_"
    }
    
    /// Return true if character is a letter or number
    private func isAlphaNumeric(c: Character) -> Bool {
        return isAlpha(c: c) || isDigit(c: c)
    }
    
    /// Consume entire digit literal including fractional part
    private func number() {
        while isDigit(c: peek()) {
            _ = advance()
        }
        
        if peek() == ".", isDigit(c: peekNext()) {
            _ = advance()
            
            while isDigit(c: peek()) {
                _ = advance()
            }
        }
        
        addToken(type: .NUMBER, literal: Double(source.subString(from: start, to: current)))
    }
    
    /// Look past the decimal point (two characters ahead)
    private func peekNext() -> Character {
        if current + 1 >= source.count { return "\0" }
        return source.charAt(at: current + 1)
    }
    
    /// Return true if the character is a digit 0-9
    private func isDigit(c: Character) -> Bool {
        return c >= "0" && c <= "9"
    }
    
    /// Consume characters until ending double quote
    private func string() {
        while peek() != "\"", !isAtEnd() {
            if peek() == "\n" {
                line += 1
            }
            _ = advance()
        }
        
        if isAtEnd() {
            Lox.error(line: line, message: "Unterminated string")
            return
        }
        
        /// The closing `"`
        _ = advance()
        
        /// Trim the surrounding quotes
        let fromIndex = start + 1
        let toIndex = current - 1
        
        /// Strip the surrounding quotes to produce the string literal
        let value: String = source.subString(from: fromIndex, to: toIndex)
        addToken(type: .STRING, literal: value)
    }
    
    /// Lookahead function that does not consume a character
    private func peek() -> Character {
        if isAtEnd() { return "\0" }
        return source.charAt(at: current)
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
