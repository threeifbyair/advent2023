class AdventDay {
    let partTwo: Bool
    let inputStrings: [String]
    let argint: Int?
    let verbose: Bool
    
    required init(partTwo: Bool, inputStrings: [String], argint: Int?, verbose: Bool) {
        self.partTwo = partTwo
        self.inputStrings = inputStrings
        self.argint = argint
        self.verbose = verbose
    }
    
    func run() {
        fatalError("run() not implemented")
    }
}
