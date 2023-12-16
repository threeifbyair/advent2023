func processInnerAshRockMap(_ ashRockMap: [[Bool]], _ ignore: Int) -> Int {
    // Let's look for horizontal reflections first.
    for i in 1..<ashRockMap.count {
        if i == ignore {
            continue
        }
        var distance: Int = 0
        var found: Bool = true
        while i - distance - 1 >= 0 && i + distance < ashRockMap.count {
            if ashRockMap[i-distance-1] == ashRockMap[i+distance] {
                distance += 1
            } else {
                found = false
                break
            }
        }
        if found {
            return i
        }
    }
    return 0
}

func processMediumAshRockMap(_ ashRockMap: inout [[Bool]], _ ignore: (Int, Int)) -> (Int, Int) {
    let horizontal: Int = processInnerAshRockMap(ashRockMap, ignore.1)
    var transposedAshRockMap: [[Bool]] = []
    for i in 0..<ashRockMap[0].count {
        var transposedAshRockLine: [Bool] = []
        for j in 0..<ashRockMap.count {
            transposedAshRockLine.append(ashRockMap[j][i])
        }
        transposedAshRockMap.append(transposedAshRockLine)
    }
    let vertical: Int = processInnerAshRockMap(transposedAshRockMap, ignore.0)
    return (vertical, horizontal)
}

func processAshRockMap(_ ashRockMap: inout [[Bool]], _ partTwo: Bool) -> (Int, Int) {
    if ashRockMap.count == 0 {
        return (0, 0)
    }
    let (vertical, horizontal) = processMediumAshRockMap(&ashRockMap, (0, 0))
    if partTwo {
        // Go through and find the smudge.
        //print("Old reflection was \(vertical), \(horizontal)")
        for i in 0..<ashRockMap.count {
            for j in 0..<ashRockMap[i].count {
                ashRockMap[i][j] = !ashRockMap[i][j]
                let (v1, h1) = processMediumAshRockMap(&ashRockMap, (vertical, horizontal))
                if (v1 != 0 && v1 != vertical) || (h1 != 0 && h1 != horizontal) {
                    //print("Found smudge at \(i), \(j), old reflection was \(vertical), \(horizontal), new reflection is \(v1), \(h1), returning \((v1 == vertical ? 0 : v1, h1 == horizontal ? 0 : h1))")
                    return (v1 == vertical ? 0 : v1, h1 == horizontal ? 0 : h1)
                }
                ashRockMap[i][j] = !ashRockMap[i][j]
            }
        }
    }
    //print("Reflection is unchanged at \(vertical), \(horizontal)")
    return (vertical, horizontal)
}
    
class Day13: AdventDay {

    override func run() {
        var answer: Int = 0
        var vertical: Int = 0
        var horizontal: Int = 0
        var ashRockMap: [[Bool]] = []
        for str in inputStrings {
            if str.length == 0 {
                let (v1, h1) = processAshRockMap(&ashRockMap, partTwo)
                vertical += v1
                horizontal += h1
                ashRockMap = []
                continue
            }
            var ashRockLine: [Bool] = []
            for char in str {
                ashRockLine.append(char == "#")
            }
            ashRockMap.append(ashRockLine)
        }   
        let (v1, h1) = processAshRockMap(&ashRockMap, partTwo)
        vertical += v1
        horizontal += h1
        answer = horizontal * 100 + vertical

        print("Answer is \(answer)")
    }
}
