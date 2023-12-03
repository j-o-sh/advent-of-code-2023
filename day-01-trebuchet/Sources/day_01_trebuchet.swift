import ArgumentParser
import Foundation

@main
struct Trebuchet: ParsableCommand {
  @Argument(help: "The cordinate file to clean up")
  var filename: String

  mutating func run() throws {
    let number = try Regex("[0-9]")

    print("Cleaning up \(filename)...")

    let data = try String(contentsOfFile: filename)
    let result = data.components(separatedBy: .newlines)
      .filter { !$0.isEmpty }
      .filter { $0.contains(number) }
      .map { ( $0, $0.ranges(of: number) ) }
      .map { ( text, match ) in Int(text[match.first!] + text[match.last!])! }
      .reduce(0, +)

    print("Done. Result is \(result)")
  }
}
