import Foundation

typealias GamePlay = (red: Int, green: Int, blue: Int)
typealias Conclusion = (
  possible: [GameRecord], 
  impossible: [(game: GameRecord, cause: String)]
)

func asGamePlay(input: String) -> GamePlay {
  var red = 0, green = 0, blue = 0
  for x in input.trimmingCharacters(in: .whitespaces).components(separatedBy: ",") {
    let parts = x.trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces)
    switch parts[1] {
    case "red": red = Int(parts[0]) ?? 0
    case "green": green = Int(parts[0]) ?? 0
    case "blue": blue = Int(parts[0]) ?? 0
    default: break
    }
  }
  return (red, green, blue)
}

func gamePower(play: GamePlay) -> Int {
  return play.red * play.green * play.blue
}

struct GameRecord {
  let label: String
  let plays: [GamePlay] 
}

func checkDice(_ name: String, played: Int, secret: Int) -> (Bool, String) {
  if (played > secret) { return (true, "**\(played) \(name)**") }
  else { return (false, "\(played) \(name)") }
}

func findContradictions(_ game: GameRecord, red: Int, green: Int, blue: Int) -> String? {
  let found = game.plays
    .map {[
      checkDice("red", played: $0.red, secret: red),
      checkDice("green", played: $0.green, secret: green),
      checkDice("blue", played: $0.blue, secret: blue)
    ]}
    .map {(
      $0.reduce(false) { $0 || $1.0 },
      $0.reduce("") { "\($0) \($1.1)" }
    )}
    .filter { $0.0 }
    .map { $0.1 }

  return found.isEmpty ? nil : "\n\t - " + found.joined(separator: "\n\t - ")
}

func findMinimalSet(_ plays: [GamePlay]) -> GamePlay {
  return (
    red:   plays.map({ $0.red   }).reduce(0, max),
    green: plays.map({ $0.green }).reduce(0, max), 
    blue:  plays.map({ $0.blue  }).reduce(0, max) 
  )
}

// func powerOfPlay()

func splitStr(_ str: String, by: String) -> [String] {
  return str.components(separatedBy: by).map { $0.trimmingCharacters(in: .whitespaces) }
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
    self.games = content.components(separatedBy: .newlines)
      .filter { !$0.isEmpty }
      .map { splitStr($0, by: ":") }
      .map { GameRecord( 
        label: $0[0], 
        plays: splitStr($0[1], by: ";").map {asGamePlay(input: $0)}
      ) }
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

  func findMinimalPlays() -> [(label: String, minimal: GamePlay, power: Int)] {
    return games
      .map {(
        label: $0.label,
        minimal: findMinimalSet($0.plays)
      )}
      .map {(
        label: $0.label,
        minimal: $0.minimal,
        power: gamePower(play: $0.minimal)
      )}
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
