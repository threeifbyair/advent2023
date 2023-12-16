enum HotSpring: String {
    case operational = "."
    case damaged = "#"
    case unknown = "?"
}

func matchNonogram(springLine: [HotSpring], nonogramLine: [Int], lastSpring: HotSpring, currentSpring: HotSpring?, currentCount: Int) -> [[HotSpring]]? {
    if nonogramLine.count == 0 && currentCount == 0 && springLine.count == 0 {
        // We've reached the end so we know this works one way.
        return [[]]
    }
    if springLine.count == 0 {
        // We've reached the end of the springs but not the nonogram, so this can't fit.
        return nil
    }
    switch (lastSpring, currentSpring ?? springLine[0]) {
        case (.operational, .operational):
            // OK, keep going.
            let innerMatch = matchNonogram(springLine: Array(springLine[1...]), nonogramLine: nonogramLine, lastSpring: .operational, currentSpring: nil, currentCount: 0)
            if innerMatch != nil {
                return innerMatch!.map { [.operational] + $0 }
            }
            else {
                return nil
            }
        case (.operational, .damaged):
            // Time to consume a nonogram count.
            if nonogramLine.count == 0 {
                // We're out of nonogram counts, so this can't fit.
                return nil
            }
            let innerMatch =  matchNonogram(springLine: Array(springLine[1...]), nonogramLine: Array(nonogramLine[1...]), lastSpring: .damaged, currentSpring: nil, currentCount: nonogramLine[0] - 1)
            if innerMatch != nil {
                return innerMatch!.map { [.damaged] + $0 }
            }
            else {
                return nil
            }
        case (.damaged, .operational):
            // Current count had better be zero so that we close out the last.
            if currentCount != 0 {
                return nil
            }
            else {
                // OK, keep going.
                let innerMatch = matchNonogram(springLine: Array(springLine[1...]), nonogramLine: nonogramLine, lastSpring: .operational, currentSpring: nil, currentCount: 0)
                if innerMatch != nil {
                    return innerMatch!.map { [.operational] + $0 }
                }
                else {
                    return nil
                }
            }
        case (.damaged, .damaged):
            // Current count had better be non-zero so that we keep going.
            if currentCount == 0 {
                return nil
            }
            else {
                // OK, keep going.
                let innerMatch = matchNonogram(springLine: Array(springLine[1...]), nonogramLine: nonogramLine, lastSpring: .damaged, currentSpring: nil, currentCount: currentCount - 1)
                if innerMatch != nil {
                    return innerMatch!.map { [.damaged] + $0 }
                }
                else {
                    return nil
                }
            }
        case (_, .unknown):
            // We don't know what this is, so we have to try both.
            let innerMatchOperational =  matchNonogram(springLine: springLine, nonogramLine: nonogramLine, lastSpring: lastSpring, currentSpring: .operational, currentCount: currentCount)
            let innerMatchDamaged = matchNonogram(springLine: springLine, nonogramLine: nonogramLine, lastSpring: lastSpring, currentSpring: .damaged, currentCount: currentCount)
            if innerMatchOperational != nil && innerMatchDamaged != nil {
                return innerMatchOperational! + innerMatchDamaged!
            }
            else if innerMatchOperational != nil {
                return innerMatchOperational!
            }
            else if innerMatchDamaged != nil {
                return innerMatchDamaged!
            }
            else {
                return nil
            }
        default:
            // This is a bad state.
            return nil
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
            //print("Matching springs \(springLineStr) to nonogram \(nonogramLine)")
            let thisAnswer = matchNonogram(springLine: springLine, nonogramLine: nonogramLine, lastSpring: .operational, currentSpring: nil, currentCount: 0)
            //for answer in thisAnswer ?? [] {
            //    print("                ", answer.map { $0.rawValue }.joined())
            //}

            //print("Result is \(thisAnswer?.count ?? 0)")
            
            answer += thisAnswer?.count ?? 0
        }   

        print("Answer is \(answer)")
    }
}
