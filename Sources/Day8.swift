import Foundation
import RegexBuilder

class Day8: AdventDay {
    override func run() {
        var answer: Int = 0
        var directions: String? = nil
        var map: [Substring: (Substring, Substring)] = [:]
        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            if directions == nil {
                // This better be the first line with directions.
                directions = str
                continue
            }
            let origin = Reference(Substring.self)
            let left = Reference(Substring.self)
            let right = Reference(Substring.self)
            let ex = Regex {
                Capture(as: origin) {
                    OneOrMore(.word)
                }
                " = ("
                Capture(as: left) {
                    OneOrMore(.word)
                }
                ", "
                Capture(as: right) {
                    OneOrMore(.word)
                }
                ")"
            }
            if let match = str.firstMatch(of: ex) {
                map[match[origin]] = (match[left], match[right])
            }
        }
        if partTwo {
            var ghostLocations: [Substring] = Array(map.filter({$0.0.hasSuffix("A")}).keys)
            var stringOffset = directions!.startIndex
            while ghostLocations.filter({$0.hasSuffix("Z")}).count != ghostLocations.count {
                var newGhostLocations: [Substring] = []
                let thisDirection = directions![stringOffset]
                for loc in ghostLocations {
                    if thisDirection == "R" {
                        newGhostLocations.append(map[loc]!.1)
                    }
                    else if thisDirection == "L" {
                        newGhostLocations.append(map[loc]!.0)
                    }
                    else {
                        print("HELP! direction is \(thisDirection)!")
                    }
                }
                ghostLocations = newGhostLocations
                stringOffset = directions!.index(after: stringOffset)
                if stringOffset == directions!.endIndex {
                    stringOffset = directions!.startIndex
                }
                answer += 1
            }
        }
        else {
            var location = Substring("AAA")
            var stringOffset = directions!.startIndex
            while location != Substring("ZZZ") {
                if directions![stringOffset] == "R" {
                    location = map[location]!.1
                }
                else if directions![stringOffset] == "L" {
                    location = map[location]!.0
                }
                else {
                    print("HELP! direction is \(directions![stringOffset])!")
                }
                stringOffset = directions!.index(after: stringOffset)
                if stringOffset == directions!.endIndex {
                    stringOffset = directions!.startIndex
                }
                answer += 1
            }
        }
        print("Answer is \(answer)")
    }
}
