import Foundation
import RegexBuilder

class LensBox {
    init(_ index: Int) {
        self.index = index
    }
    var index: Int
    var lens: [(Substring, Int)] = []

    func focusingPower() -> Int {
        var power: Int = 0
        for (lensIndex, (_, value)) in lens.enumerated() {
            power += (lensIndex + 1) * value
        }
        return (index + 1) * power
    }
}

func hash(_ hashStr: Substring) -> Int {
    var value: Int = 0
    for char in hashStr {
        value += Int(char.asciiValue!)
        value = (value * 17) % 256
    }
    return value
}

class Day15: AdventDay {
    override func run() {
        var answer: Int = 0
        let str = inputStrings[0]
        let split = str.split(separator: ",")
        if partTwo {
            let lensBoxes: [LensBox] = (0..<256).map { i in LensBox(i) }
            let tag = Reference(Substring.self)
            let op = Reference(Substring.self)
            let value = Reference(Substring.self)
            let ex = Regex {
                Capture(as: tag) {
                    OneOrMore(.word)
                }
                Capture(as: op) {
                    ChoiceOf {
                        "="
                        "-"
                    }
                }
                Capture(as: value) {
                    ZeroOrMore(.digit)
                }
            }
            for cmd in split {
                let match = cmd.firstMatch(of: ex)!
                let tag = match[tag]
                let op = match[op]
                let lensBox = lensBoxes[hash(tag)]
                //print("Before command \(cmd), lensBox \(hash(tag)) is \(lensBox.lens)")
                let tagIndex = lensBox.lens.map { $0.0 }.firstIndex(of: tag)
                if op == "=" {
                    let value = Int(match[value])!
                    //print("Setting \(tag) to \(value)")
                    if tagIndex != nil {
                        lensBox.lens[tagIndex!] = (tag, value)
                    }
                    else {
                        lensBox.lens.append((tag, value))
                    }
                }
                else {
                    //print("Removing \(tag)")
                    if tagIndex != nil {
                        lensBox.lens.remove(at: tagIndex!)
                    }
                    else {
                        //print("Tag \(tag) not found")
                    }
                }
                //print("After command \(cmd), lensBox \(hash(tag)) is \(lensBox.lens)")
            }
            answer = lensBoxes.map { $0.focusingPower() }.reduce(0, +)
        }
        else {
            answer = split.map { hash($0) }.reduce(0, +)
        }
        print("Answer is \(answer)")
    }
}
