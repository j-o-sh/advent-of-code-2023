import ArgumentParser

@main
struct Cubegames: ParsableCommand {
  @Option(name: [.long, .customShort("f")])
  var gamesFile: String
  
  @Argument
  var reds: Int
  @Argument
  var greens: Int
  @Argument
  var blues: Int

  mutating func run() throws {
    let games = try GamesJournal(fromFile: gamesFile)

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
