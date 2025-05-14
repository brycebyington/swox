//
//  main.swift
//  swox
//
//  Created by Bryce Byington on 5/4/25.
//

import Foundation

var args = CommandLine.arguments

public class Lox {
    static var hadError: Bool = false
    
    public static func main(args: [String]) {
        if args.count > 1 {
            print("Usage: slox [script]")
            exit(64)
        } else if args.count == 1 {
            runFile(path: args[0])
        } else {
            runPrompt()
        }
    }
    
    /// Execute code from path
    private static func runFile(path: String) {
        var bytes = [UInt8]()
        bytes = try! Data(contentsOf: URL(fileURLWithPath: path)).map { UInt8($0) }
        run(source: String(bytes: bytes, encoding: .utf8)!)
        
        /// Indicate an error in the exit code
        if hadError {
            exit(65)
        }
    }
    
    /// Execute code from command line interpreter
    private static func runPrompt() {
        while true {
            print("> ", terminator: "")
            /// Read command line input until end-of-file
            guard let line = readLine() else {
                break
            }
            run(source: line)
            /// Reset flag in interactive loop
            hadError = false
        }
    }
    
    /// Core
    private static func run(source: String) {
        let scanner = Scanner(source: source)
        /// To-do: Implement Token class and scanTokens() function.
        let tokens: [Token] = scanner.scanTokens()
        
        for token in tokens {
            print(token)
        }
    }
    
    static func error(line: Int, message: String) {
        report(line: line, where: "", message: message)
    }
    
    static func report(line: Int, where: String, message: String) {
        print("[line \(line)] Error: \(`where`): \(message)")
        hadError = true
    }
}

/// Test function
AstPrinter.testAstPrinter(args: [])

/// Main loop
Lox.main(args: [])
