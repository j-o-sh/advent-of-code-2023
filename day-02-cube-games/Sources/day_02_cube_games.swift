// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser

@main
struct Cubegames: ParsableCommand {
  @Option(name: [.long, .customShort("f")])
  var gamesFile: String
  
  @Argument
  var reds: Int
  @Argument
  var greens: Int
  @Argument
  var blues: Int

  mutating func run() throws {
    print("Hello, world!")
  }
}
