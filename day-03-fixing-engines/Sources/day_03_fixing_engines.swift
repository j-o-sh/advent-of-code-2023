// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

struct BoundRange: CustomStringConvertible {
    let src: String
    var ranges: [Range<String.Index>] = []

    init(src: String, ranges: [Range<String.Index>]) {
        self.src = src
        self.ranges = ranges
    }

    var description: String {
        return ranges.map({ src[$0] }).joined(separator: "\n")
    }

    func clampV() -> BoundRange {
        guard let firstRange = ranges.first else { return self }

        if (ranges.count > 2) {
            return BoundRange(src: src, ranges: Array(ranges[1..<ranges.count - 1]))
        } else if (src.lineRange(for: firstRange).lowerBound > src.startIndex) {
            return BoundRange(src: src, ranges: Array(ranges[1..<ranges.count]))
        } else {
            return BoundRange(src: src, ranges: Array(ranges[0..<ranges.count - 1]))
        }
    }

    func clampH() -> BoundRange {
        return BoundRange(
            src: src,
            ranges: ranges
                .map { src.index(after: $0.lowerBound)..<src.index(before: $0.upperBound) }
        )
    }

    var innerNumbers: String {
        return self.description.filter { $0.isNumber }
    }

    func contains(_ re: any RegexComponent) -> Bool {
        return ranges.contains(where: {src[$0].contains(re)})
    }

    mutating func expandH() {
        for (i, range) in ranges.enumerated() {
          let line = src.lineRange(for: range)
          let l = src.index(
              range.lowerBound,
              offsetBy: -1,
              limitedBy: line.lowerBound
          ) ?? line.lowerBound
          let r = src.index(
              range.upperBound,
              offsetBy: 1,
              limitedBy: line.upperBound
          ) ?? line.upperBound
          self.ranges[i] = l..<r
        }
    }

    mutating func expandV() {
        guard let firstRange = ranges.first else { return }
        guard let lastRange = ranges.last else { return }

        let leftBound = ranges
            .map { src.distance(from: src.lineRange(for: $0).lowerBound, to: $0.lowerBound) }
            .reduce(Int.max, min)
        let rightBound = ranges
            .map { src.distance(from: src.lineRange(for: $0).lowerBound, to: $0.upperBound) }
            .reduce(0, max)

        let firstLine = src.lineRange(for: firstRange)
        if (firstLine.lowerBound > src.startIndex) {
            let up = src.index(before: firstLine.lowerBound)
            let lineUpStart = src.lineRange(for: up...up).lowerBound
            let start = src.index(lineUpStart, offsetBy: leftBound)
            let end = src.index(lineUpStart, offsetBy: rightBound)
            self.ranges = [start..<end] + self.ranges
        }
        let lastLine = src.lineRange(for: lastRange)
        if (lastLine.upperBound < src.endIndex) {
            let down = src.index(after: lastLine.upperBound)
            let lineDownStart = src.lineRange(for: down...down).lowerBound
            let start = src.index(lineDownStart, offsetBy: leftBound)
            let end = src.index(lineDownStart, offsetBy: rightBound)
            self.ranges.append(start..<end)
        }
    }
}

@main
struct day_03_fixing_engines: ParsableCommand {
    @Argument
    var inputFile: String

    mutating func run() throws {
        let numbers = try Regex("[0-9]+")
        let partsSymbol = try Regex("[^[0-9]\\.\\s]")

        let contents = try String(contentsOfFile: inputFile)
        let parts = contents.ranges(of: numbers)
            .map({ (range: Range<String.Index>) -> BoundRange in 
                var r = BoundRange(src: contents, ranges: [range])
                r.expandV()
                r.expandH()
                return r
            })
            .filter { $0.contains(partsSymbol) }
            .map { $0.clampV() }
            .map { $0.innerNumbers }

        for part in parts { print("\(part)\n--") }

        let total = parts
            .map { Int($0.description) ?? 0 }
            .reduce(0, +)

        print("Total: \(total)")
    }
}
