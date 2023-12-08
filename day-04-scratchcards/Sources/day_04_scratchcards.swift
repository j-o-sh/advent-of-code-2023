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

struct Card {
    let label: String
    let winning: [Int]
    let scratched: [Int]
    
    var matching: Int { return scratched.filter(winning.contains).count }
    var total: Decimal { return matching == 0 ? 0 : pow(2, matching - 1) }
}

extension Card {
    init(label: String?, winning: String?, mine: String?) {
        self.label = label ?? ""
        self.winning = asNumbers(winning)
        self.scratched = asNumbers(mine)
    }
}

@main
struct day_04_scratchcards: ParsableCommand {
    @Argument
    var filename: String

    @Flag
    var copyRules: Bool = false

    mutating func run() throws {
        let content = try String(contentsOfFile: filename)
        let cards = content.split(separator: "\n")
            .map(splitIntoChunks(":", "|"))
            .map { Card(label: $0[0] ?? "", winning: $0[1], mine: $0[2]) }


        if (copyRules) {
            var stack = cards.map { ( card: $0, copies: 1 ) }
            for i in 0..<stack.count - 1 {
                let (card, copies) = stack[i]
                let reach = (i + 1)..<min(card.matching + i + 1, stack.count)
                for j in reach { stack[j].copies += copies }
            }
            for (card, copies) in stack {
                print("\(copies) * \(card.label) - \(card.matching) matching")
            }
            print("----")
            print("Total: \(stack.reduce(0, { $0 + $1.copies }))")
        } else {
            print("Winning Total: \(doublingPoints(cards))")
        }
    }

    func doublingPoints(_ cards: [Card]) -> Decimal {
        return cards
            .map { $0.total }
            .reduce(0, +)
    }
}
