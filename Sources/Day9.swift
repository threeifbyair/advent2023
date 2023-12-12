
func findNext(sequence: [Int], partTwo: Bool) -> Int {
    if sequence.filter({ $0 != 0 }).count > 0 {
        // It's not all zeros. Recurse.
        var diffs: [Int] = []
        for i in 0..<sequence.count {
            if i == 0 {
                continue
            }
            else {
                diffs.append(sequence[i] - sequence[i-1])
            }
        }
        if partTwo {
            return sequence[0] - findNext(sequence: diffs, partTwo: partTwo)
        }
        else {
            return sequence[sequence.count-1] + findNext(sequence: diffs, partTwo: partTwo)
        }
    }
    else {
        // It's all zeros. Return a zero.
        return 0
    }
}

class Day9: AdventDay {
    override func run() {
        var answer: Int = 0
        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            let split = str.split(separator: " ")
            var sequence: [Int] = []
            for s in split {
                sequence.append(Int(s)!)
            }
            answer += findNext(sequence: sequence, partTwo: partTwo)
        }
        print("Answer is \(answer)")
    }
}
