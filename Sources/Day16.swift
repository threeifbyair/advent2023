enum MirrorEntry: String, Hashable {
    case empty = "."
    case mirrorSlash = "/"
    case mirrorBackslash = "\\"
    case vertSplit = "|"
    case horizSplit = "-"
}

enum Direction: Int, Hashable {
    case north = 0
    case south = 1
    case east = 2
    case west = 3
}

class Mirror {
    var entry: MirrorEntry
    var illuminated: [Direction] = []
    
    init(entry: MirrorEntry) {
        self.entry = entry
    }
}

class MirrorFarm {
    var mirrors: [[Mirror]]
    var numIlluminated: Int = 0

    init(input: [[MirrorEntry]]) {
        mirrors = []
        for line in input {
            var mirrorLine: [Mirror] = []
            for entry in line {
                mirrorLine.append(Mirror(entry: entry))
            }
            mirrors.append(mirrorLine)
        }
    }

    func illuminate(x: Int, y: Int, direction: Direction) {
        //print("Illuminating \(x),\(y) from \(direction)")
        if y < 0 || y >= mirrors.count || x < 0 || x >= mirrors[y].count {
            return
        }
        let mirror = mirrors[y][x]
        if mirror.illuminated.contains(direction) {
            return
        }
        if mirror.illuminated.count == 0 {
            numIlluminated += 1
        }
        mirror.illuminated.append(direction)
        switch mirror.entry {
        case .empty:
            switch direction {
            case .north:
                illuminate(x: x, y: y+1, direction: .north)
            case .south:
                illuminate(x: x, y: y-1, direction: .south)
            case .east:
                illuminate(x: x-1, y: y, direction: .east)
            case .west:
                illuminate(x: x+1, y: y, direction: .west)
            }
        case .mirrorSlash:
            switch direction {
            case .north:
                illuminate(x: x-1, y: y, direction: .east)
            case .south:
                illuminate(x: x+1, y: y, direction: .west)
            case .east:
                illuminate(x: x, y: y+1, direction: .north)
            case .west:
                illuminate(x: x, y: y-1, direction: .south)
            }
        case .mirrorBackslash:
            switch direction {
            case .north:
                illuminate(x: x+1, y: y, direction: .west)
            case .south:
                illuminate(x: x-1, y: y, direction: .east)
            case .east:
                illuminate(x: x, y: y-1, direction: .south)
            case .west:
                illuminate(x: x, y: y+1, direction: .north)
            }
        case .vertSplit:
            switch direction {
            case .north:
                illuminate(x: x, y: y+1, direction: .north)
            case .south:
                illuminate(x: x, y: y-1, direction: .south)
            case .east, .west:
                illuminate(x: x, y: y+1, direction: .north)
                illuminate(x: x, y: y-1, direction: .south)
            }
        case .horizSplit:
            switch direction {
            case .north, .south:
                illuminate(x: x-1, y: y, direction: .east)
                illuminate(x: x+1, y: y, direction: .west)
            case .east:
                illuminate(x: x-1, y: y, direction: .east)
            case .west:
                illuminate(x: x+1, y: y, direction: .west)
            }
        }
    }
}

class Day16: AdventDay {

    override func run() {
        var answer: Int = 0
        var mirrorMap: [[MirrorEntry]] = []
        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            var mirrorLine: [MirrorEntry] = []
            for char in str {
                mirrorLine.append(MirrorEntry(rawValue: String(char))!)
            }
            mirrorMap.append(mirrorLine)
        }
        if partTwo {
            var maxIlluminated = 0
            for y in 0..<mirrorMap.count {
                let farm = MirrorFarm(input: mirrorMap)
                farm.illuminate(x: 0, y: y, direction: .west)
                if farm.numIlluminated > maxIlluminated {
                    maxIlluminated = farm.numIlluminated
                }
            }
            for y in 0..<mirrorMap.count {
                let farm = MirrorFarm(input: mirrorMap)
                farm.illuminate(x: mirrorMap[0].count-1, y: y, direction: .east)
                if farm.numIlluminated > maxIlluminated {
                    maxIlluminated = farm.numIlluminated
                }
            }
            for x in 0..<mirrorMap[0].count {
                let farm = MirrorFarm(input: mirrorMap)
                farm.illuminate(x: x, y: 0, direction: .north)
                if farm.numIlluminated > maxIlluminated {
                    maxIlluminated = farm.numIlluminated
                }
            }
            for x in 0..<mirrorMap.count {
                let farm = MirrorFarm(input: mirrorMap)
                farm.illuminate(x: x, y: mirrorMap.count-1, direction: .south)
                if farm.numIlluminated > maxIlluminated {
                    maxIlluminated = farm.numIlluminated
                }
            }
            answer = maxIlluminated
        } else {
            let farm = MirrorFarm(input: mirrorMap)
            farm.illuminate(x: 0, y: 0, direction: .west)
            answer = farm.numIlluminated
        }
        print("Answer is \(answer)")
    }
}
