import Foundation
import RegexBuilder

class Trench: Hashable {
    var direction: Direction
    var distance: Int
    var color: Int

    init(direction: Direction, distance: Int, color: Int) {
        self.direction = direction
        self.distance = distance
        self.color = color
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(direction)
        hasher.combine(distance)
        hasher.combine(color)
    }

    static func == (lhs: Trench, rhs: Trench) -> Bool {
        return lhs.direction == rhs.direction && lhs.distance == rhs.distance && lhs.color == rhs.color
    }
}

class LagoonMap {
    static let openSpace: Trench = Trench(direction: .north, distance: 0, color: 0)
    var trenches: [Trench]
    var trenchMap: [Int: [Int: Trench]] = [:]
    var minX: Int = 0
    var maxX: Int = 0
    var minY: Int = 0
    var maxY: Int = 0

    init(trenches: [Trench]) {
        self.trenches = trenches
        var x = 0
        var y = 0
        for trench in trenches {
            var remaining = trench.distance
            while remaining > 0 {
                switch trench.direction {
                case .north:
                    y += 1
                case .south:
                    y -= 1
                case .east:
                    x += 1
                case .west:
                    x -= 1
                }
                remaining -= 1
                if x < minX {
                    minX = x
                }
                if x > maxX {
                    maxX = x
                }
                if y < minY {
                    minY = y
                }
                if y > maxY {
                    maxY = y
                }
                if trenchMap[y] == nil {
                    trenchMap[y] = [:]
                }
                trenchMap[y]![x] = trench
            }
        }
    }

    func fillInterior() {
        var y = minY
        while y <= maxY {
            if let row = trenchMap[y] {
                var x = minX
                var inside = false
                var onEdge = false
                var fromSouth = false
                while x <= maxX {
                    if onEdge {
                        if row[x] != nil {
                            // do nothing, we stay on the edge
                        }
                        else {
                            onEdge = false
                            // Have we gone outside?
                            let wentSouth: Bool = trenchMap[y + 1] != nil && trenchMap[y + 1]![x-1] != nil
                            let stayedSame: Bool = (wentSouth && fromSouth) || (!wentSouth && !fromSouth)
                            //print("x: \(x) y: \(y) wentSouth: \(wentSouth), fromSouth: \(fromSouth), stayedSame: \(stayedSame), inside: \(inside)")

                            if stayedSame {
                                // Yeah, this looks wrong, but we switched earlier, so we're good.
                                inside = !inside
                            }
                            if inside {
                                trenchMap[y]![x] = LagoonMap.openSpace
                            }
                        }
                    } else if inside {
                        if row[x] == nil {
                            trenchMap[y]![x] = LagoonMap.openSpace
                        } else {
                            inside = false
                            if row[x+1] != nil {
                                onEdge = true
                                fromSouth = trenchMap[y + 1] != nil && trenchMap[y + 1]![x] != nil
                                //print("x: \(x) y: \(y) frominside mapsouth \(trenchMap[y+1]![x]) fromSouth: \(fromSouth), inside: \(inside)")
                            }
                        }
                    } else {
                        if row[x] != nil {
                            inside = true
                            if row[x+1] != nil {
                                onEdge = true
                                fromSouth = trenchMap[y + 1] != nil && trenchMap[y + 1]![x] != nil
                                //print("x: \(x) y: \(y) fromoutside mapsouth \(trenchMap[y+1]![x]) fromSouth: \(fromSouth), inside: \(inside)")
                            }
                        }
                    }
                    x += 1
                }
            }
            y += 1
        }
    }

    
    func howFilled() -> Int {
        var filled = 0
        for x in minX...maxX {
            for y in minY...maxY {
                if trenchMap[y] != nil && trenchMap[y]![x] != nil {
                    filled += 1
                }
            }
        }
        return filled
    }

    func printMap() {
        var y = minY
        while y <= maxY {
            var x = minX
            while x <= maxX {
                if trenchMap[y] != nil && trenchMap[y]![x] != nil {
                    print(trenchMap[y]![x]! == LagoonMap.openSpace ? "O" : "#", terminator: "")
                } else {
                    print(".", terminator: "")
                }
                x += 1
            }
            print("")
            y += 1
        }
    }
}


class Day18: AdventDay {

    override func run() {
        var answer: Int = 0
        var trenches: [Trench] = []
        let direction = Reference(Substring.self)
        let distance = Reference(Substring.self)
        let color = Reference(Substring.self)
        let ex = Regex {
            Capture(as: direction) {
                One(.word)
            }
            " "
            Capture(as: distance) {
                OneOrMore(.digit)
            }
            " (#"
            Capture(as: color) {
                OneOrMore(.hexDigit)
            }
            ")"
        }

        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            let match = str.firstMatch(of: ex)!
            let dirchr = match[direction]
            let dist = Int(match[distance])!
            let col = Int(match[color], radix: 16)!
            let direction: Direction = dirchr == "U" ? .north : dirchr == "D" ? .south : dirchr == "L" ? .east : .west
            let trench = Trench(direction: direction, distance: dist, color: col)
            trenches.append(trench)
        }
        // Build the best route from the end to the beginning.
        let thisMap = LagoonMap(trenches: trenches)

        //thisMap.printMap()
        
        thisMap.fillInterior()

        //print("Filled map:")
        //thisMap.printMap()
        
        answer = thisMap.howFilled()
        
        
        print("Answer is \(answer)")
    }
}
