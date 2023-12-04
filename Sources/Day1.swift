class Day1: AdventDay {
    override func run() {
        var answer: Int = 0
        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            var firstNum: Int? = nil
            var secondNum: Int? = nil
            var index: String.Index = str.startIndex
            while index != str.endIndex {
                if let num = recognizeDigit(str, index, partTwo)  {
                    if firstNum == nil {
                        firstNum = num
                    }
                    secondNum = num
                }
                index = str.index(after: index)
            }
            guard let firstNum2 = firstNum, let secondNum2 = secondNum
            else {
                fatalError("Could not parse \(str)")
            }
            answer += firstNum2 * 10 + secondNum2
        }
        print("Answer is \(answer)")
    }

    func recognizeDigit(_ str: String, _ i: String.Index, _ partTwo: Bool) -> Int? {
        let c = str[i]
        switch c {
        case "0": return 0
        case "1": return 1
        case "2": return 2
        case "3": return 3
        case "4": return 4
        case "5": return 5
        case "6": return 6
        case "7": return 7
        case "8": return 8
        case "9": return 9
        default:
            if partTwo {
                if str[i ..< str.endIndex].hasPrefix("one") {
                    return 1
                }
                else if str[i ..< str.endIndex].hasPrefix("two") {
                    return 2
                }
                else if str[i ..< str.endIndex].hasPrefix("three") {
                    return 3
                }
                else if str[i ..< str.endIndex].hasPrefix("four") {
                    return 4
                }
                else if str[i ..< str.endIndex].hasPrefix("five") {
                    return 5
                }
                else if str[i ..< str.endIndex].hasPrefix("six") {
                    return 6
                }
                else if str[i ..< str.endIndex].hasPrefix("seven") {
                    return 7
                }
                else if str[i ..< str.endIndex].hasPrefix("eight") {
                    return 8
                }
                else if str[i ..< str.endIndex].hasPrefix("nine") {
                    return 9
                }
                else {
                    return nil
                }
            }
            else {
                return nil
            }
        }
    }
}
