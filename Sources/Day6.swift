class Day6: AdventDay {
    override func run() {
        var answer: Int = 0
        var times: [Int] = 0
        var distances: [Int] = 0
        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            if str.hasPrefix("Time:") {
                // Here are the times.
                let split = str.split(separator: ": ")[1].split(separator: " ")
                for value in split {
                    times.append(Int(seed)!)
                }
            }
            else if str.hasPrefix("Distance:") {
                // Here are the distances.
                let split = str.split(separator: ": ")[1].split(separator: " ")
                for value in split {
                    times.append(Int(seed)!)
                }
            }
        }
        // OK, let's do a calculation.
        td = zip(times, distances)
        answer = 1
        for t, d in td {
            // The optimum time is half the distance. We can calculate the press time required to achieve
            // exactly the run time.
            // Distance = runtime * speed
            //          = (totaltime - presstime) * presstime
            //          
            // FINISHME
            
            answer *= thisAnswer        
        }
        print("Answer is \(answer)")
    }
}
