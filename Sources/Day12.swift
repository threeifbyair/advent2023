enum HotSpring: String {
    case operational = "."
    case damaged = "#"
    case unknown = "?"
}

func matchNonogram(springLine: [HotSpring], nonogramLine: [Int], lastSpring: HotSpring, currentSpring: HotSpring?, currentCount: Int) -> Int {
    if nonogramLine.count == 0 && currentCount == 0 {
        // We've reached the end so we know this works one way.
        return 1
    }
    if springLine.count == 0 {
        // We've reached the end of the springs but not the nonogram, so this can't fit.
        return 0
    }
    switch (lastSpring, currentSpring ?? springLine[0]) {
        case (.operational, .operational):
            // OK, keep going.
            return matchNonogram(springLine: Array(springLine[1...]), nonogramLine: nonogramLine, lastSpring: .operational, currentSpring: nil, currentCount: 0)
        case (.operational, .damaged):
            // Time to consume a nonogram count.
            return matchNonogram(springLine: Array(springLine[1...]), nonogramLine: Array(nonogramLine[1...]), lastSpring: .damaged, currentSpring: nil, currentCount: nonogramLine[0] - 1)
        case (.damaged, .operational):
            // Current count had better be zero so that we close out the last.
            if currentCount != 0 {
                return 0
            }
            else {
                // OK, keep going.
                return matchNonogram(springLine: Array(springLine[1...]), nonogramLine: nonogramLine, lastSpring: .operational, currentSpring: nil, currentCount: 0)
            }
        case (.damaged, .damaged):
            // Current count had better be non-zero so that we keep going.
            if currentCount == 0 {
                return 0
            }
            else {
                // OK, keep going.
                return matchNonogram(springLine: Array(springLine[1...]), nonogramLine: nonogramLine, lastSpring: .damaged, currentSpring: nil, currentCount: currentCount - 1)
            }
        case (.operational, .unknown):
            // We don't know what this is, so we have to try both.
            return matchNonogram(springLine: springLine, nonogramLine: nonogramLine, lastSpring: .operational, currentSpring: .operational, currentCount: currentCount) + matchNonogram(springLine: springLine, nonogramLine: nonogramLine, lastSpring: .operational, currentSpring: .damaged, currentCount: currentCount)
        case (.damaged, .unknown):
            // We don't know what this is, so we have to try both.
            return matchNonogram(springLine: springLine, nonogramLine: nonogramLine, lastSpring: .damaged, currentSpring: .operational, currentCount: currentCount) + matchNonogram(springLine: springLine, nonogramLine: nonogramLine, lastSpring: .damaged, currentSpring: .damaged, currentCount: currentCount)
        default:
            // This is a bad state.
            return 0
    }
}

class Day12: AdventDay {
    override func run() {
        var answer: Int = 0
        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            var springLine: [HotSpring] = []
            var nonogramLine: [Int] = []
            let split = str.split(separator: " ")
            let springLineStr = split[0]
            let nonogramLineStr = split[1]
            for char in springLineStr {
                springLine.append(HotSpring(rawValue: String(char))!)
            }
            for part in nonogramLineStr.split(separator: ",") {
                nonogramLine.append(Int(part)!)
            }
            // OK, now we have a map of the springs and a nonogram.
            // How many ways can the map match the nonogram?
            print("Matching springs \(springLineStr) to nonogram \(nonogramLine)")
            let thisAnswer = matchNonogram(springLine: springLine, nonogramLine: nonogramLine, lastSpring: .operational, currentSpring: nil, currentCount: 0)
            print("Result is \(thisAnswer)")
            answer += thisAnswer
        }   

        print("Answer is \(answer)")
    }
}
