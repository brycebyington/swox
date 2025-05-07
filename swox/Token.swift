//
//  Token.swift
//  swox
//
//  Created by Bryce Byington on 5/5/25.
//

class Token: CustomStringConvertible {
    var description: String {
        return "\(type) \(lexeme) \(String(describing: literal))"
    }

    final var type: TokenType
    final var lexeme: String
    final var literal: Any?
    final var line: Int

    init(type: TokenType, lexeme: String, literal: Any?, line: Int) {
        self.type = type
        self.lexeme = lexeme
        self.literal = literal
        self.line = line
    }
}
