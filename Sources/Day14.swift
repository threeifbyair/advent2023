enum ParabolaEntry: String, Hashable {
    case empty = "."
    case cube = "#"
    case round = "O"
}

func tiltToNorth(_ parabolaMap: [[ParabolaEntry]]) -> [[ParabolaEntry]] {
    var parabolaNorth: [[ParabolaEntry]] = parabolaMap
    for i in 0..<parabolaNorth.count-1 {
        for j in 0..<parabolaNorth[i].count {
            if parabolaNorth[i][j] == .empty && parabolaNorth[i+1][j] == .round {
                parabolaNorth[i][j] = .round
                parabolaNorth[i+1][j] = .empty
                if i > 0 {
                    var newI = i - 1
                    while newI >= 0 && parabolaNorth[newI][j] == .empty {
                        parabolaNorth[newI][j] = .round
                        parabolaNorth[newI+1][j] = .empty
                        newI -= 1
                    }
                }
            }
        }
    }
    return parabolaNorth
}

func tiltToEast(_ parabolaMap: [[ParabolaEntry]]) -> [[ParabolaEntry]] {
    var parabolaEast: [[ParabolaEntry]] = parabolaMap
    for i in 0..<parabolaEast.count {
        for j in 0..<parabolaEast[i].count-1 {
            if parabolaEast[i][j] == .empty && parabolaEast[i][j+1] == .round {
                parabolaEast[i][j] = .round
                parabolaEast[i][j+1] = .empty
                if j > 0 {
                    var newJ = j - 1
                    while newJ >= 0 && parabolaEast[i][newJ] == .empty {
                        parabolaEast[i][newJ] = .round
                        parabolaEast[i][newJ+1] = .empty
                        newJ -= 1
                    }
                }
            }
        }
    }
    return parabolaEast
}

func tiltToWest(_ parabolaMap: [[ParabolaEntry]]) -> [[ParabolaEntry]] {
    var parabolaWest: [[ParabolaEntry]] = parabolaMap
    for i in 0..<parabolaWest.count {
        for j in (1..<parabolaWest[i].count).reversed() {
            if parabolaWest[i][j] == .empty && parabolaWest[i][j-1] == .round {
                parabolaWest[i][j] = .round
                parabolaWest[i][j-1] = .empty
                if j < parabolaWest[i].count - 1 {
                    var newJ = j + 1
                    while newJ < parabolaWest[i].count && parabolaWest[i][newJ] == .empty {
                        parabolaWest[i][newJ] = .round
                        parabolaWest[i][newJ-1] = .empty
                        newJ += 1
                    }
                }
            }
        }
    }
    return parabolaWest
}

func tiltToSouth(_ parabolaMap: [[ParabolaEntry]]) -> [[ParabolaEntry]] {
    var parabolaSouth: [[ParabolaEntry]] = parabolaMap
    for i in (1..<parabolaSouth.count).reversed() {
        for j in 0..<parabolaSouth[i].count {
            if parabolaSouth[i][j] == .empty && parabolaSouth[i-1][j] == .round {
                parabolaSouth[i][j] = .round
                parabolaSouth[i-1][j] = .empty
                if i < parabolaSouth.count - 1 {
                    var newI = i + 1
                    while newI < parabolaSouth.count && parabolaSouth[newI][j] == .empty {
                        parabolaSouth[newI][j] = .round
                        parabolaSouth[newI-1][j] = .empty
                        newI += 1
                    }
                }
            }
        }
    }
    return parabolaSouth
}

func spinCycle(_ parabolaMap: [[ParabolaEntry]]) -> [[ParabolaEntry]] {
    return tiltToWest(tiltToSouth(tiltToEast(tiltToNorth(parabolaMap))))
}

func mapWeight(_ parabolaMap: [[ParabolaEntry]]) -> Int {
    var weight: Int = 0
    for i in 0..<parabolaMap.count {
        for j in 0..<parabolaMap[i].count {
            if parabolaMap[i][j] == .round {
                //print("Found round at \(i), \(j), adding by \(parabolaMap.count - i)")
                weight += parabolaMap.count - i
            }
        }
    }
    return weight
}

class Day14: AdventDay {

    override func run() {
        var answer: Int = 0
        var parabolaMap: [[ParabolaEntry]] = []
        let targetSpin: Int = 1000000000
        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            var parabolaLine: [ParabolaEntry] = []
            for char in str {
                parabolaLine.append(ParabolaEntry(rawValue: String(char))!)
            }
            parabolaMap.append(parabolaLine)
        }
        if partTwo {
            var spinMap: [[[ParabolaEntry]]: Int] = [:]
            var spinList: [[[ParabolaEntry]]] = []
            var turnCount: Int = 0
            while !spinMap.keys.contains(parabolaMap) {
                spinList.append(parabolaMap)
                spinMap[parabolaMap] = turnCount
                parabolaMap = spinCycle(parabolaMap)
                turnCount += 1
            }
            print(" At turn \(turnCount), found duplicate at turn \(spinMap[parabolaMap]!)")
            let firstOffset: Int = spinMap[parabolaMap]!
            let cycleLength: Int = turnCount - firstOffset
            print("Cycle length is \(cycleLength)")
            let targetTurn: Int = (targetSpin - firstOffset) % cycleLength + firstOffset
            print("Target turn is \(targetTurn)")
            answer = mapWeight(spinList[targetTurn])
        }
        else {
            let parabolaNorth = tiltToNorth(parabolaMap)
            answer = mapWeight(parabolaNorth)
        }
        print("Answer is \(answer)")
    }
}
