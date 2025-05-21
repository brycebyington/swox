//
//  RuntimeError.swift
//  swox
//
//  Created by Bryce Byington on 5/21/25.
//

class RuntimeError: Error {
    final let token: Token
    let message: String

    init(_ token: Token, _ message: String) {
        self.token = token
        self.message = message
    }
}
