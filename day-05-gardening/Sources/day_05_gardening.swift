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

    @Argument
    var command: String = "find"

    mutating func run() throws {
        let content = try String(contentsOfFile: input)
        let segments = segmentsOf(content)
        let seeds = segments[0]
        let almanac = segments[1..<segments.count]
            .map { Mapping(source: $0) }
        // for s in almanac { print(s); print("----") }

        switch command {
        case "map":
            for entry in almanac {
                print("[\(entry.from)]->[\(entry.to)]")
            }
        case "path":
            print("*** [ seed -> ?? -> location ] ***")
            print("-> location: \(path(from: "seed", to: "location", in: almanac))")
        case "find": fallthrough
        default:
            // print("***\(seeds)***")
            let path = path(from: "seed", to: "location", in: almanac)
            print("seed\(path.map({" -> \($0.to)"}).joined())")
            var found: [(Int, Int)] = []
            let seednrs = seeds
                .split(separator: " ")
                .dropFirst()
                .compactMap { Int($0) }

            let seedcode: [(Int, Int)] = seednrs
                .enumerated()
                .reduce(into: []) { r, v in 
                    if (v.0 % 2 == 0) { r.append((v.1, 0)) } 
                    else { r[r.count - 1].1 = v.1 }
                }

            print("Ranges: \(seedcode)")

            var counter = 1
            let all = seedcode.reduce(0) { $0 + $1.1 }
            print("Considering \(all) seeds.")
            for (start, length) in seedcode {
                for seed in start..<(start + length) {
                    print("\(counter)\t| \((counter/all) * 100)%\t| \(seed)", terminator: "\r")
                    fflush(stdout)
                    counter += 1
                    found.append((seed, findLocationFor(seed: seed, in: path)))
                }
            }
            print("\nFound (seed, location): \(found.sorted(by: { $0.1 < $1.1 }).first!)")
        }
    }
}

func findLocationFor(seed: Int, in path: [Mapping]) -> Int {
    var from = seed
    var values = [from]
    for node in path {
        let to = node.target(from: from)
        // print("* \(node.from):\(from) -> \(node.to):\(to)")
        values.append(to)
        // print("\(from) -> \(to)")
        from = to
    }
    return values.last!
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
    let map: [(Int, Int, Int)]

    init(source: String) {
        let lines = source.split(separator: "\n")

        let fields = lines[0].split(separator: " ")[0].split(separator: "-")
        
        from = "\(fields[0])"
        to = "\(fields[2])"
        map = lines[1..<lines.count]
            .map { $0.split(separator: " ").compactMap({ s in Int(s) }) }
            .filter { $0.count == 3 }
            .map { ($0[1], $0[0], $0[2]) }
            .sorted(by: { $0.0 < $1.0 })
        // map.sort(by: { $0.0 < $1.0 })
            // .flatMap { entry in 
            //     Array(0..<entry[2]).map({ i in ( entry[0] + i, entry[1] + i ) })
            // }
        // print("---[map \(from) -> \(to)]---")
        // map.forEach { print($0) }
        // print("----------------------------")
    }

    func target(from: Int) -> Int {
        if let assotiation = map.first(where: { $0.0 == from }) {
            return assotiation.1
        } else if let found = map.first(where: { $0.0 <= from && from <= $0.0+$0.2 }) {
            return found.1 + (from - found.0)
        } else {
            return from
        }
    }

    var description: String { return "\(from) -> \(to)" }
}
