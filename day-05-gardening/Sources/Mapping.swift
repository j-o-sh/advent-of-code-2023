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

    func source(to: Int) -> Int {
        if let assotiation = map.first(where: { $0.1 == to }) {
            return assotiation.0
        } else if let found = map.first(where: { $0.1 <= to && to <= $0.1+$0.2 }) {
            return found.0 + (to - found.1)
        } else {
            return to
        }
    }

    func valuesSortedByDest() -> MappingSequence {
        return MappingSequence(map: map.sorted(by: { $0.1 < $1.1 }))
    }

    var description: String { return "\(from) -> \(to)" }
}

func findRMappingsFor(to: Int, path: some Collection<Mapping>) -> [(Int, Int)] {
    var mappings: [(Int, Int)?] = Array(repeating: nil, count: path.count)
    mappings[0] = (path.first!.source(to: to), to)
    for (i, node) in path.enumerated().dropFirst() {
        guard let previous = mappings[i-1] else { break }
        mappings[i] = (
            node.source(to: previous.0),
            previous.0
        )
    }
    return mappings.compactMap({$0})
}

func findRValuesFor(_ v: Int, path: some Collection<Mapping>) -> [Int] {
    var values: [Int?] = Array(repeating: nil, count: path.count)
    values[0] = v
    for (i, node) in path.enumerated().dropFirst() {
        guard let previous = values[i-1] else { break }
        values[i] = node.source(to: previous)
        // print("#\(values[i]) -> \(previous)")
    }
    return values.compactMap({$0})
}

struct MappingSequence: Sequence {
    let map: [(Int, Int, Int)]
    
    struct MapIter: IteratorProtocol {
        var i = 0
        var j = -1
        let map: [(Int, Int, Int)]

        mutating func next() -> (from: Int, to: Int)? {
            if i >= map.count { return nil } 
            j += 1
            if map[i].2 < j {
                j = 0
                i += 1
                return next()
            }
            let range = map[i]
            return (from: range.0 + j, to: range.1 + j)
        }
    }

    func makeIterator() -> MapIter {
            let lowest = map.first!.1
            return MapIter(map: [(0, 0, lowest)] + map)
    }
}

