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
        case "find-back":
            let path = path(from: "seed", to: "location", in: almanac).reversed()
            let seedcode = seedRanges(seeds: seeds) 
            print("\(path.map({"\($0.to)\t<-\t"}).joined())seed")   

            func printValues(_ values: [Int]) {
                print(
                    values.map({"\($0)"}).joined(separator: " | "),
                    terminator: "\r"
                )
                fflush(stdout)
            }

            print("@@\(path.first!.valuesSortedByDest())")
            for (from, to) in path.first!.valuesSortedByDest() {
                let map = findRMappingsFor(to: to, path: path)
                print("\(from) -> \(to) <-- \(map.map({"\($0.0)"}).joined(separator: " <- "))", terminator: "\r")

                if (isKnown(map.last!.0, in: seedcode)) { 
                    print("\nFound location: \(to) for seed: \(map.last)")
                    break 
                }

            }
            // for (from, to) in path.first!.valuesSortedByDest() {
            //     // print("$ \(to)<-\(from)")
            //     let values = findRValuesFor(to, path: path)
            //     let source = values.last!
            //     // printValues(values)
            //     print("\(from) -- \(to) --> \(source): \(values)")
            //     if (isKnown(source, in: seedcode)) { 
            //         print("\nFound location: \(to) for seed: \(source)")
            //         break 
            //     }
            // }
            print("\n")
        case "find": fallthrough
        default:
            let path = path(from: "seed", to: "location", in: almanac)
            print("seed\(path.map({" -> \($0.to)"}).joined())")
            let seedcode = seedRanges(seeds: seeds) 

            print("Ranges: \(seedcode)")

            var found: (Int, Int)? = nil
            var counter = 1
            var percent = -1
            let all = seedcode.reduce(0) { $0 + $1.1 }
            print("Considering \(all) seeds.")
            for (start, length) in seedcode {
                for seed in start..<(start + length) {
                    let nPercent = (counter/all)*1000
                    if (nPercent > percent ) {
                        percent = nPercent
                        print("\(seed) | \((counter/all) * 100)%%\t| \(start)...(\(length)) | Current lowest: \(String(describing: found))", terminator: "\r")
                        fflush(stdout)
                    }
                    counter += 1
                    // found.append((seed, findLocationFor(seed: seed, in: path)))
                    let location = findLocationFor(seed: seed, in: path)
                    if (found == nil || location < found!.1) { found = (seed, location) }
                }
            }
            print("\nFound (seed, location): \(String(describing: found))")
        }
    }
}

func seedRanges(seeds: some StringProtocol) -> [(Int, Int)] {
    let seednrs = seeds
        .split(separator: " ")
        .dropFirst()
        .compactMap { Int($0) }

    return seednrs
        .enumerated()
        .reduce(into: []) { r, v in 
            if (v.0 % 2 == 0) { r.append((v.1, 0)) } 
                else { r[r.count - 1].1 = v.1 }
        }
        .sorted { $0.0 < $1.0 }
}

func isKnown(_ value: Int, in ranges: [(Int, Int)]) -> Bool {
    let range = ranges.first(where: { $0.0 <= value && value <= ($0.0 + $0.1) })
    return range != nil
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

