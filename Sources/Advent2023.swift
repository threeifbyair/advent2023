import ArgumentParser
import Foundation

@main
struct Advent2023: ParsableCommand {
    @Flag(name: [.long, .customShort("p")], help: "Perform part two of the challenge")
    var partTwo = false

    @Flag(name: [.long, .customShort("v")], help: "Give verbose results")
    var verbose = false

    @Option(name: [.long, .customShort("i")], help: "The file to read input from")
    var inputFile: String? = nil

    @Option(name: [.long, .customShort("a")], help: "The command-line argument, if any")
    var argint: Int? = nil
    
    @Argument(help: "The day to run")
    var day: Int

    mutating func run() throws {
        let unwrappedInputFile = self.inputFile ?? "-"
        var inputArray: [String] = []
        if unwrappedInputFile == "-" {
            while let line = readLine() {
                inputArray.append(line)
            }
        }
        else {
            let inputStrings = try? String(contentsOfFile: unwrappedInputFile)
            guard let inputStrings2 = inputStrings else {
                print("Could not read input file \(unwrappedInputFile)")
                return
            }
            inputArray = inputStrings2.components(separatedBy: "\n")
        }

        let dayClass = "Advent2023.Day\(day)"
        guard let dayClassType = NSClassFromString(dayClass) as? AdventDay.Type else {
            print("No such day \(dayClass)")
            return
        }
        let dayInstance = dayClassType.init(partTwo: partTwo, inputStrings: inputArray, argint: argint, verbose: verbose)
        dayInstance.run()
    }
}
