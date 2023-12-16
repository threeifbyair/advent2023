enum HotSpring: String, Hashable {
    case operational = "."
    case damaged = "#"
    case unknown = "?"
}

class PartialAnswer: Hashable {
    var springOffset: Int
    var nonogramOffset: Int
    var lastSpring: HotSpring
    var currentCount: Int

    init(_ springOffset: Int, _ nonogramOffset: Int, _ lastSpring: HotSpring, _ currentCount: Int) {
        self.springOffset = springOffset
        self.nonogramOffset = nonogramOffset
        self.lastSpring = lastSpring
        self.currentCount = currentCount
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(springOffset)
        hasher.combine(nonogramOffset)
        hasher.combine(lastSpring)
        hasher.combine(currentCount)
    }

    static func == (lhs: PartialAnswer, rhs: PartialAnswer) -> Bool {
        return lhs.springOffset == rhs.springOffset && lhs.nonogramOffset == rhs.nonogramOffset && lhs.lastSpring == rhs.lastSpring && lhs.currentCount == rhs.currentCount
    }
}

class AdventLine {
    var springLine: [HotSpring]
    var nonogramLine: [Int]
    var partialAnswers: [PartialAnswer: Int] = [:]

    init(springLine: [HotSpring], nonogramLine: [Int]) {
        self.springLine = springLine
        self.nonogramLine = nonogramLine
    }
    
    func matchNonogram(springOffset: Int, nonogramOffset: Int, lastSpring: HotSpring, currentSpring: HotSpring?, currentCount: Int) -> Int {
        if let answer = partialAnswers[PartialAnswer(springOffset, nonogramOffset, lastSpring, currentCount)] {
            return answer
        }
        var answer: Int = 0
        if nonogramOffset == nonogramLine.count && currentCount == 0 && springOffset == springLine.count {
            // We've reached the end so we know this works one way.
            answer = 1
        }
        else if springOffset == springLine.count {
            // We've reached the end of the springs but not the nonogram, so this can't fit.
            answer = 0
        }
        else {
            switch (lastSpring, currentSpring ?? springLine[springOffset]) {
            case (.operational, .operational):
                // OK, keep going.
                answer = matchNonogram(springOffset: springOffset + 1, nonogramOffset: nonogramOffset, lastSpring: .operational, currentSpring: nil, currentCount: 0)
            case (.operational, .damaged):
                // Time to consume a nonogram count.
                if nonogramOffset == nonogramLine.count {
                    // We're out of nonogram counts, so this can't fit.
                    answer = 0
                }
                else {
                    answer = matchNonogram(springOffset: springOffset + 1, nonogramOffset: nonogramOffset + 1, lastSpring: .damaged, currentSpring: nil, currentCount: nonogramLine[nonogramOffset] - 1)
                }
            case (.damaged, .operational):
                // Current count had better be zero so that we close out the last.
                if currentCount != 0 {
                    answer = 0
                }
                else {
                    // OK, keep going.
                    answer = matchNonogram(springOffset: springOffset + 1, nonogramOffset: nonogramOffset, lastSpring: .operational, currentSpring: nil, currentCount: 0)
                }
            case (.damaged, .damaged):
                // Current count had better be non-zero so that we keep going.
                if currentCount == 0 {
                    answer = 0
                }
                else {
                    // OK, keep going.
                    answer = matchNonogram(springOffset: springOffset + 1, nonogramOffset: nonogramOffset, lastSpring: .damaged, currentSpring: nil, currentCount: currentCount - 1)
                }
            case (_, .unknown):
                // We don't know what this is, so we have to try both.
                answer = matchNonogram(springOffset: springOffset, nonogramOffset: nonogramOffset, lastSpring: lastSpring, currentSpring: .operational, currentCount: currentCount) + matchNonogram(springOffset: springOffset, nonogramOffset: nonogramOffset, lastSpring: lastSpring, currentSpring: .damaged, currentCount: currentCount)
            default:
                // This is a bad state.
                answer = 0
            }
        }
        if currentSpring == nil {
            // If we're at an unknown, we can't cache this.
            partialAnswers[PartialAnswer(springOffset, nonogramOffset, lastSpring, currentCount)] = answer
        }
        return answer
    }

    func getAnswer() -> Int {
        return matchNonogram(springOffset: 0, nonogramOffset: 0, lastSpring: .operational, currentSpring: nil, currentCount: 0)
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
            if partTwo {
                // We need to quintuple both lines.
                springLine = springLine + [.unknown] + springLine + [.unknown] + springLine + [.unknown] + springLine + [.unknown] + springLine
                nonogramLine = nonogramLine + nonogramLine + nonogramLine + nonogramLine + nonogramLine
            }
            // OK, now we have a map of the springs and a nonogram.
            // How many ways can the map match the nonogram?
            //print("Matching springs \(springLineStr) to nonogram \(nonogramLine)")
            let thisLine = AdventLine(springLine: springLine, nonogramLine: nonogramLine)
            let thisAnswer = thisLine.getAnswer()
            //print("Result is \(thisAnswer)")
            
            answer += thisAnswer
        }   

        print("Answer is \(answer)")
    }
}
