// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

@main
struct day_06_boatrace: ParsableCommand {
    mutating func run() throws {
        print("Hello, world!")
        print(limitButtonPress(distance: 9, time: 7))
    }
}


func limitButtonPress(distance: Int, time: Int) -> (Double, Double)? {
    let discriminant = t * t - 4 * d
    
    guard discriminant >= 0 else {
        return nil // No real solutions
    }
    
    let sqrtDiscriminant = sqrt(discriminant)
    
    let b1 = (t + sqrtDiscriminant) / 2
    let b2 = (t - sqrtDiscriminant) / 2
    
    return (b1, b2)
}
