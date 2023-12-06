import ArgumentParser

@main
struct Cubegames: ParsableCommand {
  @Option(name: [.long, .customShort("f")])
  var gamesFile: String

  @Flag
  var findMinimum = false
  
  @Argument
  var reds = 0
  @Argument
  var greens = 0
  @Argument
  var blues = 0

  mutating func run() throws {
    let games = try GamesJournal(fromFile: gamesFile)

    if (findMinimum) {
      let min = games.findMinimalPlays()
      for (label, minimum, power) in min {
        print("  - \(label): \(minimum) -> \(power)")
      }
      print("----")
      print("Combined Power: \(min.map({$0.power}).reduce(0, +))")
    } else {
      try possibleGames(games)
    }
  }

  func possibleGames(_ games: GamesJournal) throws {
    let (possible, impossible) = games.concludeOn(red: reds, green: greens, blue: blues)

    for (label) in possible {
      print("\(label) is possible.")
    }

    print("\n----\n")

    for (game, cause) in impossible {
      print("\(game.label) is impossible because \(cause)")
    }

    print("\n----\n")

    let result = possible
      .map { $0.label.filter { $0.isNumber } }
      .map { Int($0) ?? 0 }
      .reduce(0, +)
    
    print(result)
  }
}
