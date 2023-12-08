// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

@main
struct day_05_gardening: ParsableCommand {
    @Option
    var input: String

    mutating func run() throws {
        let content = try String(contentsOfFile: input)
        let segments = segmentsOf(content)
        let seeds = segments[0]
        let almanac = segments[1..<segments.count]
            .map { Mapping(source: $0) }
        for s in almanac { print(s); print("----") }

        print("*** [ seed -> ?? -> location ] ***")
        print("-> location: \(path(from: "seed", to: "location", in: almanac))")
    }
}

func segmentsOf(_ content: String) -> [String] {
    return content.split(separator: "\n").reduce(into: [String]()) { r, l in
        if r.isEmpty || l.trimmingCharacters(in: .whitespaces).last == ":" {
            r.append("\(l)")
        } else {
            r[r.count - 1] = "\(r.last ?? "")\n\(l)"
        }
    }
}
func path(from: String, to: String, in graph: [Mapping]) -> [Mapping] {
    // let end = graph.filter { $0.to }
    return shortestPath(to: to, from: from, in: graph) ?? []
}



struct Mapping: CustomStringConvertible, Traversable {
    let from: String
    let to: String
    let _map: ArraySlice<Substring>

    init(source: String) {
        let lines = source.split(separator: "\n")

        let fields = lines[0].split(separator: " ")[0].split(separator: "-")
        
        from = "\(fields[0])"
        to = "\(fields[2])"
        _map = lines[1..<lines.count]
    }

    var description: String { return "\(from) -> \(to)" }
}
