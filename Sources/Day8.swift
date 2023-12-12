import Foundation
import RegexBuilder

func gcd(_ x: Int, _ y: Int) -> Int {
    var a = 0
    var b = max(x, y)
    var r = min(x, y)
    
    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    return b
}

func lcm(_ x: Int, _ y: Int) -> Int {
    return x / gcd(x, y) * y
}

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
            let ghostLocations: [Substring] = Array(map.filter({$0.0.hasSuffix("A")}).keys)
            var ghostMaps: [(Int, Int, [Int])] = []
            for loc in ghostLocations {
                var currentLoc = loc
                var turnId = 0
                var finalTurns: [Int] = []
                var beenThere: [Substring: [String.Index: Int]] = [:]
                var stringOffset = directions!.startIndex
                while !beenThere.contains(where: {$0.0 == currentLoc && $0.1.contains(where: {$0.0 == stringOffset})}) {
                    if beenThere[currentLoc] == nil {
                        beenThere[currentLoc] = [:]
                    }
                    beenThere[currentLoc]![stringOffset] = turnId
                    if currentLoc.hasSuffix("Z") {
                        finalTurns.append(turnId)
                    }
                    if directions![stringOffset] == "R" {
                        currentLoc = map[currentLoc]!.1
                    }
                    else if directions![stringOffset] == "L" {
                        currentLoc = map[currentLoc]!.0
                    }
                    else {
                        print("HELP! direction is \(directions![stringOffset])!")
                    }
                    stringOffset = directions!.index(after: stringOffset)
                    if stringOffset == directions!.endIndex {
                        stringOffset = directions!.startIndex
                    }
                    turnId += 1
                }
                ghostMaps.append((turnId, beenThere[currentLoc]![stringOffset]!, finalTurns))
                print("Ghost repeated at turn \(turnId) back to \(beenThere[currentLoc]![stringOffset]!) and found endpoints at \(finalTurns)")
                //guard finalTurns.count == 1 && turnId - finalTurns[0] == beenThere[currentLoc]![stringOffset]! else {
                //    print("HELP! \(finalTurns.count) endpoints or complex restart!")
                //    return
                //}
            }
            // Now we have a list of all the ghosts and their turn counts.
            // As it happens, we can just do a least common multiple of all the turn counts.
            answer = ghostMaps[0].2[0]
            for ghost in ghostMaps {
                answer = lcm(answer, ghost.2[0])
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
