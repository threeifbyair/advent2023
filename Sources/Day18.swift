import Foundation
import RegexBuilder
import HeapModule

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
            if trenchMap[y] == nil {
                trenchMap[y] = [:]
            }
            trenchMap[y]![x] = trench
            //print("Trench at \(x), \(y): \(trench.direction) \(trench.distance)")
            switch trench.direction {
            case .north:
                y -= trench.distance
            case .south:
                y += trench.distance
            case .east:
                x += trench.distance
            case .west:
                x -= trench.distance
            }
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
        }
    }
    
    func howFilled() -> Int {
        var filled = 0
        var trenchStatus: Heap<Int> = Heap<Int>()
        var lastY: Int? = nil
        for y in trenchMap.keys.sorted() {
            var ourTrenches: [Int] = []
            while !trenchStatus.isEmpty {
                let trench = trenchStatus.popMin()!
                ourTrenches.append(trench)
            }
            trenchStatus = Heap<Int>()
            if lastY != nil && y - lastY! > 0 {
                let diff = y - lastY!
                var lineFilled = 0
                var offset = 0
                while offset < ourTrenches.count  {
                    let start = ourTrenches[offset]
                    let end = ourTrenches[offset + 1]
                    offset += 2
                    lineFilled += end - start + 1
                }
                //print("\nIntermediate \(lastY!) - \(y), status \(ourTrenches), filling \(lineFilled), \(diff) times")
                filled += lineFilled * diff
            }
            var inside: Bool = false
            var offset = 0
            var prevEnd: Int? = nil
            let keys = trenchMap[y]!.keys.sorted()
            var lineFilled = 0
            //print("\nEdge line \(y), status \(ourTrenches), keys \(keys)")
            while offset <= trenchMap[y]!.count {
                let edgeStart = (offset == trenchMap[y]!.count ? Int.max :keys[offset])
                // We may have a trench just coming past.
                while !ourTrenches.isEmpty && ourTrenches[0] < edgeStart {
                    let passed = ourTrenches.removeFirst()
                    if inside {
                        //print("In passing code, filling \(passed - prevEnd! - 1) for \(prevEnd!) - \(passed)")
                        lineFilled += passed - prevEnd! - 1
                    }
                    //print("In passing code, filling 1 for \(passed)")
                    lineFilled += 1 // for the trench
                    inside = !inside
                    trenchStatus.insert(passed)
                    //print("Status: in passing, inserting \(passed)")
                    prevEnd = passed
                }
                if offset == trenchMap[y]!.count {
                    break
                }
                let edgeEnd = keys[offset + 1]
                offset += 2
                if inside && prevEnd != nil && edgeStart - prevEnd! > 1 {
                    // Fill this part.
                    //print("Inside part: Filling \(edgeStart - prevEnd! - 1) for \(prevEnd!) - \(edgeStart)")
                    lineFilled += edgeStart - prevEnd! - 1
                }
                //print("Edge: Filling \(edgeEnd - edgeStart + 1) for \(edgeStart) - \(edgeEnd)")
                lineFilled += edgeEnd - edgeStart + 1
                let fromNorth = (!ourTrenches.isEmpty && ourTrenches[0] == edgeStart)
                if fromNorth  {
                    // So this is a trench coming from the north.
                    ourTrenches.removeFirst()
                    let wentNorth = (!ourTrenches.isEmpty && ourTrenches[0] == edgeEnd)
                    if wentNorth {
                        // And it's going north, so no change to the inside status.
                        // And we lose both ends of the trench.
                        ourTrenches.removeFirst()
                        //print("Status: north to north, inserting nothing")
                    }
                    else {
                        // And it's going south.
                        inside = !inside
                        trenchStatus.insert(edgeEnd)
                        //print("Status: north to south, inserting \(edgeEnd)")
                    }
                }
                else {
                    // This is a trench coming from the south.
                    let wentNorth = (!ourTrenches.isEmpty && ourTrenches[0] == edgeEnd)
                    if wentNorth {
                        // And it's going north.
                        ourTrenches.removeFirst()
                        inside = !inside
                        trenchStatus.insert(edgeStart)
                        //print("Status: south to north, inserting \(edgeStart)")
                    }
                    else {
                        // And it's going south, so no change to the inside status.
                        // But we gain both ends of the trench.
                        trenchStatus.insert(edgeStart)
                        trenchStatus.insert(edgeEnd)
                        //print("Status: south to south, inserting \(edgeStart) and \(edgeEnd)")
                    }
                }
                prevEnd = edgeEnd
            }
            //print("Edge line \(y), new status \(Array(trenchStatus.unordered)), filling \(lineFilled)")
            filled += lineFilled
            lastY = y + 1
        }
        return filled
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
            if partTwo {
                let dist = Int(col / 16)
                let col = col % 16
                let direction: Direction = col == 3 ? .north : col == 1 ? .south : col == 0 ? .east : .west
                let trench = Trench(direction: direction, distance: dist, color: col)
                trenches.append(trench)
            }
            else {
                let direction: Direction = dirchr == "U" ? .north : dirchr == "D" ? .south : dirchr == "L" ? .west : .east
                let trench = Trench(direction: direction, distance: dist, color: col)
                trenches.append(trench)
            }
        }
        // Build the best route from the end to the beginning.
        let thisMap = LagoonMap(trenches: trenches)

        answer = thisMap.howFilled()
        
        
        print("Answer is \(answer)")
    }
}
