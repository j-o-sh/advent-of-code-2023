typealias GamePlay = (red: Int, green: Int, blue: Int)
typealias Conclusion = (
  possible: [GameRecord], 
  impossible: [(game: GameRecord, cause: String)]
)

func findContradictions(_ game: GameRecord, red: Int, green: Int, blue: Int) -> String? {

  return nil
}

struct GameRecord {
  let label: String
  let plays: [GamePlay] 
}

struct GamesJournal {
  let games: [GameRecord]

  init() {
    self.games = [
      GameRecord(label: "G1", plays: [
        (red: 3, green: 6, blue: 10),
        (red: 13, green: 1, blue: 0)
      ]),
      GameRecord(label: "G2", plays: [(red: 1, green: 3, blue: 2)])
    ]
  }

  func concludeOn(red: Int, green: Int, blue: Int) -> Conclusion {
    return games
      .map { ($0, findContradictions($0, red:red, green:green, blue:blue)) }
      .reduce(into: (possible: [], impossible: [])) {
        result, item in
        if let cause = item.1 {
          result.impossible.append((game:item.0, cause:cause))
        } else {
          result.possible.append(item.0)
        }
      }
  }
}
  
extension GamesJournal: Sequence {
  func makeIterator() -> some IteratorProtocol {
    return games.makeIterator()
  }
}

extension GameRecord: CustomStringConvertible {
  var description: String {
    return label
  }
}
