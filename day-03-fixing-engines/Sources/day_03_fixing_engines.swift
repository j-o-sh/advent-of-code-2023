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

    init(src: String, range: Range<String.Index>) {
        self.src = src
        self.ranges = [range]
    }

    var description: String {
        return ranges.map({ src[$0] }).joined(separator: "\n")
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

        let schematic = try String(contentsOfFile: inputFile)

        for r in schematic.ranges(of: numbers) {
            var partno = BoundRange(src: schematic, range: r)
            partno.expandH()
            partno.expandV()
            print(partno)
            print("   ")
        }

        // let partnrs = schematic.ranges(of: numbers)
        //     .map { BoundRange(src: schematic, range: $0) }
        //     .map { $0.expand(left: 1, right: 1) }
        //
        // print(partnrs)
    }
}
