class Day6: AdventDay {
    override func run() {
        var answer: Int = 0
        var times: [Int] = []
        var distances: [Int] = []
        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            let str = partTwo ? str.replacingOccurrences(of: " ", with: "") : str
            if str.hasPrefix("Time:") {
                // Here are the times.
                let split = str.split(separator: ":")[1].split(separator: " ")
                for value in split {
                    times.append(Int(value)!)
                }
            }
            else if str.hasPrefix("Distance:") {
                // Here are the distances.
                let split = str.split(separator: ":")[1].split(separator: " ")
                for value in split {
                    distances.append(Int(value)!)
                }
            }
        }
        // OK, let's do a calculation.
        let td = zip(times, distances)
        answer = 1
        for (t, d) in td {
            // The optimum time is half the distance. We can calculate the press time required to achieve
            // exactly the run time.
            // Distance = runtime * speed
            //          = (totaltime - presstime) * presstime
            // so d = t * p - p^2
            // so p^2 - tp + d = 0
            // so p = (t +/- sqrt(t^2 - 4d)) / 2


            // Try this again.
            // Distance = runtime * speed
            //          = (totaltime - presstime) * presstime
            // so d = t * p - p^2
            // so p^2 - tp + d = 0
            // so p = (t +/- sqrt(t^2 - 4d)) / 2
            // so p = t/2 +/- sqrt(t^2/4 - d)

            // Give some examples.
            // t = 7, d = 9
            // p = 7/2 +/- sqrt(49/4 - 9)
            // p = 7/2 +/- sqrt(49/4 - 36/4)
            // p = 7/2 +/- sqrt(13/4)
            // p = 7/2 +/- sqrt(13)/2
            // p = 7/2 +/- 3.6/2
            // p = 7/2 +/- 1.8
            // p = 5.4 or 1.6
            // What's wrong with this picture? We know that when p = 2, t = 5, so d = 10.
            // And when p = 5, t = 2, so d = 10.
            // So that means that when p = 2, 3, 4 or 5, d > 9.
            // Oh... because we need to look at adding/subtracting 0.5, 1.5, 2.5, 3.5, etc.
            // Double oh. All we need to do is look at the integers between low p and high p.

            
            let discriminant = Double(t * t - 4 * d).squareRoot() / 2
            let lowp = Double(t) / 2 - discriminant
            let highp = Double(t) / 2 + discriminant
            let thisAnswer = Int(highp) - Int(lowp) - (lowp == Double(Int(lowp)) ? 1 : 0)

            print("t is \(t), d is \(d), discriminant is \(discriminant), lowp is \(lowp), highp is \(highp), thisAnswer is \(thisAnswer)")

            answer *= thisAnswer        
        }
        print("Answer is \(answer)")
    }
}
