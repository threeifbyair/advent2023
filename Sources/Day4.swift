class Day4: AdventDay {
    override func run() {
        var answer: Int = 0
        var cardCopies: [Int: Int] = [:]
        for (cardNo, str) in inputStrings.enumerated() {
            if str.length == 0 {
                continue
            }
            cardCopies[cardNo] = cardCopies[cardNo, default: 0] + 1
            let split = str.split(separator: ": ")
            //let cardId = Int(String(split[0][split[0].index(split[0].startIndex, offsetBy: 5) ..< split[0].endIndex]))!
            let gameParts = split[1].split(separator: "| ")
            let winningNumbers = gameParts[0].split(separator: " ").map { Int($0)! }
            let myNumbers = Set(gameParts[1].split(separator: " ").map { Int($0)! })
            var winningCount = 0
            for winningNumber in winningNumbers {
                if myNumbers.contains(winningNumber) {
                    winningCount += 1
                }
            }
            if partTwo {
                let myCopies = cardCopies[cardNo]!
                for nextCard in cardNo + 1 ..< cardNo + winningCount + 1 {
                    cardCopies[nextCard] = cardCopies[nextCard, default: 0] + myCopies
                }
            }
            else {
                if winningCount != 0 {
                    answer += 1 << (winningCount - 1)
                }
            }
        }
        if partTwo {
            answer = cardCopies.compactMap { $0.value }.reduce(0, +)
        }
        print("Answer is \(answer)")
    }
}
