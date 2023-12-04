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
    // let games = GamesJournal(fromFile: gamesFile)
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

    // let re = try Regex("[0-9]+")
    // let possibleSum = possible
    //   .map { 
    //     let strNum: String = $0.label.firstRange(of: re).
    //     return Int("") || 0
    //   }
    //   .reduce(0, +)
    // print("Possible sum is: \(possibleSum)")
  }
}
