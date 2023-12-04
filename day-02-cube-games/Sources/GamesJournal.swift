import Foundation

typealias GamePlay = (red: Int, green: Int, blue: Int)
typealias Conclusion = (
  possible: [GameRecord], 
  impossible: [(game: GameRecord, cause: String)]
)

func asGamePlay(input: String) -> GamePlay {
  var red = 0, green = 0, blue = 0
  for x in input.components(separatedBy: ",") {
    let parts = x.components(separatedBy: .whitespaces)
    switch parts[1] {
    case "red": red = Int(parts[0]) ?? 0
    case "green": green = Int(parts[0]) ?? 0
    case "blue": blue = Int(parts[0]) ?? 0
    default: break
    }
  }
  return (red, green, blue)
}

func findContradictions(_ game: GameRecord, red: Int, green: Int, blue: Int) -> String? {
  let condradicting = game.plays
    .filter { $0.red > red || $0.green > green || $0.blue > blue }

  return condradicting.isEmpty ? nil : condradicting
    .map { "red \($0.red) (\(red)) green \($0.green) (\(green)) blue \($0.blue) (\(blue))" }
    .joined(separator: " ; ")
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

  init(fromFile: String) throws {
    let content = try String(contentsOfFile: fromFile)
    games = content.components(separatedBy: .newlines)
      .map { $0.components(separatedBy: ":") }
      .map { ($0[0], $0[1].components(separatedBy: ";")) }
      .map { ($0.0, $0.1.map(asGamePlay) ) }
      .map { GameRecord(label: $0.0, plays: $0.1) }
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
