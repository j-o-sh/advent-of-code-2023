// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

func splitIntoChunks(_ separators: String...) -> (Substring) -> [String?] {
    return { src in 
        var tail: String? = String(src)
        var chunks: [String?] = []
        for separator in separators { if let ttail = tail {
            let split = ttail.split(separator: separator, maxSplits: 1)
            chunks.append(split.first.map(String.init))
            tail = split.last.map(String.init)
        }}
        chunks.append(tail)
        return chunks
    }
}

func asNumbers(_ str: String?) -> [Int] {
    guard let str = str else { return [] }
    return str.split(separator: " ").compactMap { Int($0) }
}

@main
struct day_04_scratchcards: ParsableCommand {
    @Argument
    var filename: String

    mutating func run() throws {
        let content = try String(contentsOfFile: filename)
        let result = content.split(separator: "\n")
            .map(splitIntoChunks(":", "|"))
            .map { ($0[0], $0[1], $0[2]) }
            .map { (label, winning, mine) in (
                label ?? "",
                asNumbers(winning),
                asNumbers(mine)
            )}
            .map { (lbl, win, mine) in mine.filter(win.contains) }
            .map { mine in mine.isEmpty ? 0 : pow(2, mine.count - 1) }
            .reduce(0, +)
        print("Winning Total: \(result)")
    }
}
