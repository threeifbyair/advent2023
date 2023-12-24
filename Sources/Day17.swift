import HeapModule

class PartialLossAnswer: Hashable {
    var x: Int
    var y: Int
    var direction: Direction
    var steps: Int

    init(x: Int, y: Int, direction: Direction, steps: Int) {
        self.x = x
        self.y = y
        self.direction = direction
        self.steps = steps
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(direction.rawValue)
        hasher.combine(steps)
    }

    static func == (lhs: PartialLossAnswer, rhs: PartialLossAnswer) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.direction == rhs.direction && lhs.steps == rhs.steps
    }

}

class PartialLossHeapEntry: PartialLossAnswer, Comparable {
    var cost: Int
    var depth: Int
    
    init(x: Int, y: Int, direction: Direction, steps: Int, cost: Int, depth: Int) {
        self.cost = cost
        self.depth = depth
        super.init(x: x, y: y, direction: direction, steps: steps)
    }

    init(key: PartialLossAnswer, cost: Int, depth: Int) {
        self.cost = cost
        self.depth = depth
        super.init(x: key.x, y: key.y, direction: key.direction, steps: key.steps)
    }
    
    static func < (lhs: PartialLossHeapEntry, rhs: PartialLossHeapEntry) -> Bool {
        return lhs.x + lhs.y < rhs.x + rhs.y
    }
}

class LossMap {
    var lossMap: [[Int]]
    var partialAnswers: [PartialLossAnswer: Int] = [:]
    var partialSearches: Heap<PartialLossHeapEntry> = Heap<PartialLossHeapEntry>()

    init(input: [[Int]]) {
        lossMap = input
    }

    func getCachedAnswer(key: PartialLossAnswer) -> Int? {
        /*
        var answer = partialAnswers[key]
        let newKey = PartialLossAnswer(x: key.x, y: key.y, direction: key.direction, steps: key.steps) 
        while newKey.steps < 3 {
            newKey.steps += 1
            if let nextAnswer = partialAnswers[newKey]
            {
                answer = min(answer ?? Int.max, nextAnswer)
            }
        }
        return answer
         */
        return partialAnswers[key]
    }

    func registerPartialAnswer(_ key: PartialLossAnswer, _ cost: Int, _ depth: Int, verbose: Bool = false) {
        if key.y < 0 || key.y >= lossMap.count || key.x < 0 || key.x >= lossMap[key.y].count {
            if verbose {
                print(String(repeating: "*", count: depth),  "Not searching \(key.direction) to \(key.x),\(key.y) with \(key.steps) steps: off the map")
            }
            return
        }
        if key.steps >= 3 {
            if verbose {
                print(String(repeating: "*", count: depth), "Not searching \(key.direction) to \(key.x),\(key.y) with \(key.steps) steps: too many steps")
            }
            return
        }
        if let answer = getCachedAnswer(key: key) {
            if answer <= cost {
                if verbose {
                    print(String(repeating: "*", count: depth), "Not searching \(key.direction) to \(key.x),\(key.y) with \(key.steps) steps: cached cost \(answer) <= \(cost)")
                }
                return
            }
        }
        partialSearches.insert(PartialLossHeapEntry(key: key, cost: cost, depth: depth))
        if verbose {
            print(String(repeating: "*", count: depth), "Searching \(key.direction) to \(key.x),\(key.y) with \(key.steps) steps")
        }
    }
    
    func innerSearchPartialCost(key: PartialLossAnswer, previousCost: Int, depth: Int = 0, verbose: Bool = false) {
        if verbose {
            print(String(repeating: "+", count: depth+1), "\(key.x),\(key.y) \(key.direction) with \(key.steps) steps")
        }
        if key.y < 0 || key.y >= lossMap.count || key.x < 0 || key.x >= lossMap[key.y].count {
            if verbose {
                print(String(repeating: "-", count: depth+1), "\(key.x),\(key.y) \(key.direction) with \(key.steps) steps: off the map")
            }
            return
        }
        if key.steps >= 3 {
            if verbose {
                print(String(repeating: "-", count: depth+1), "\(key.x),\(key.y) \(key.direction) with \(key.steps) steps: too many steps")
            }
            return
        }
        if let answer = getCachedAnswer(key: key) {
            if answer <= previousCost {
                if verbose {
                    print(String(repeating: "-", count: depth+1), "\(key.x),\(key.y) \(key.direction) with \(key.steps) steps: cached cost \(answer) is better than \(previousCost)")
                }
                return
            }
            if verbose {
                print(String(repeating: "*", count: depth+1), "\(key.x),\(key.y) \(key.direction) with \(key.steps) steps: our cost \(previousCost), theirs \(answer)")
            }
        }
        // OK, time to generate the answer for ourselves.
        partialAnswers[key] = previousCost
        if verbose {
            print(String(repeating: "*", count: depth+1), "\(key.x),\(key.y) \(key.direction) with \(key.steps) steps: registering cost \(previousCost)")
        }
        // And move on to the next one.
        let newCost = lossMap[key.y][key.x] + previousCost
        if key.direction != .south {
            if verbose {
                print(String(repeating: "*", count: depth+1), "\(key.x),\(key.y) \(key.direction) with \(key.steps) steps: searching north")
            }
            registerPartialAnswer(PartialLossAnswer(x: key.x, y: key.y-1, direction: .north, steps: (key.direction == .north ? key.steps+1 : 0)), newCost, depth+1, verbose: verbose)
        }
        if key.direction != .north {
            if verbose {
                print(String(repeating: "*", count: depth+1), "\(key.x),\(key.y) \(key.direction) with \(key.steps) steps: searching south")
            }
            registerPartialAnswer(PartialLossAnswer(x: key.x, y: key.y+1, direction: .south, steps: (key.direction == .south ? key.steps+1 : 0)), newCost, depth+1, verbose: verbose)
        }
        if key.direction != .east {
            if verbose {
                print(String(repeating: "*", count: depth+1), "\(key.x),\(key.y) \(key.direction) with \(key.steps) steps: searching west")
            }
            registerPartialAnswer(PartialLossAnswer(x: key.x-1, y: key.y, direction: .west, steps: (key.direction == .west ? key.steps+1 : 0)), newCost, depth+1, verbose: verbose)
        }
        if key.direction != .west {
            if verbose {
                print(String(repeating: "*", count: depth+1), "\(key.x),\(key.y) \(key.direction) with \(key.steps) steps: searching east")
            }
            registerPartialAnswer(PartialLossAnswer(x: key.x+1, y: key.y, direction: .east, steps: (key.direction == .east ? key.steps+1 : 0)), newCost, depth+1, verbose: verbose)
        }
        if verbose {
            print(String(repeating: "-", count: depth+1), "\(key.x),\(key.y) \(key.direction) with \(key.steps) steps: done")
        }
    }

    func searchPartialCost(x: Int, y: Int, direction: Direction, steps: Int, previousCost: Int, verbose: Bool = false) {
        let key = PartialLossAnswer(x: x, y: y, direction: direction, steps: steps)
        if let answer = getCachedAnswer(key: key) {
            if answer <= previousCost {
                return
            }
        }
        registerPartialAnswer(key, previousCost, 0, verbose: verbose)
        while let entry = partialSearches.popMin()
        {
            // Get as far along the search as we can.
            //if verbose {
            //    print("Searching \(thisKey), we have \(partialSearches.map { ($0.0, $0.1.count) }) entries")
            //}
            let previousCost = entry.cost
            let depth = entry.depth
            //print("Searching (\(entry.x),\(entry.y)) \(entry.direction) \(entry.steps) steps at cost \(previousCost), total queue size \(partialSearches.map({ $0.value.count }).reduce(0, +))")
            innerSearchPartialCost(key: entry, previousCost: previousCost, depth: depth, verbose: verbose)
        }
    }

    
    func getBestCost() -> Int? {
        searchPartialCost(x: 0, y: 0, direction: .south, steps: 0, previousCost: -lossMap[0][0], verbose: false)
        searchPartialCost(x: 0, y: 0, direction: .east, steps: 0, previousCost: -lossMap[0][0], verbose: false)
        let try1 = getCachedAnswer(key: PartialLossAnswer(x: lossMap[0].count - 1, y: lossMap.count - 1, direction: .south, steps: 0))
        let try2 = getCachedAnswer(key: PartialLossAnswer(x: lossMap[0].count - 1, y: lossMap.count - 1, direction: .east, steps: 0))
        let adjustment = lossMap[lossMap.count-1][lossMap[0].count-1] /* - lossMap[0][0]*/
        if let try1 = try1, let try2 = try2 {
            return min(try1, try2) + adjustment
        }
        else if let try1 = try1 {
            return try1 + adjustment
        }
        else if let try2 = try2 {
            return try2 + adjustment
        }
        else {
            return nil
        }
    }
       
}


class Day17: AdventDay {

    override func run() {
        var answer: Int = 0
        var lossMap: [[Int]] = []
        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            var lossLine: [Int] = []
            for char in str {
                lossLine.append(Int(String(char))!)
            }
            lossMap.append(lossLine)
        }
        if partTwo {
            // We don't know yet!
        }
        else {
            // Build the best route from the end to the beginning.
            let thisMap = LossMap(input: lossMap)
            let thisAnswer = thisMap.getBestCost()
            //print("Result is \(thisAnswer)")
            
            answer = thisAnswer!
        }   

        print("Answer is \(answer)")
    }
}
