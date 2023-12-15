
class Day11: AdventDay {
    override func run() {
        var answer: Int = 0
        var starMap: [[Bool]] = []
        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            var starLine: [Bool] = []
            for char in str {
                starLine.append(char == "#")
            }
            starMap.append(starLine)
            // Expand the universe here
            if starLine.filter({ $0 }).count == 0 {
                starMap.append(starLine)
            }
        }
        // Now transpose the star map.
        var transposedStarMap: [[Bool]] = []
        for y in 0..<starMap[0].count {
            var mapLine: [Bool] = []
            for x in 0..<starMap.count {
                mapLine.append(starMap[x][y])
            }
            transposedStarMap.append(mapLine)
            if mapLine.filter({ $0 }).count == 0 {
                transposedStarMap.append(mapLine)
            }
        }
        // OK, now we have a star map that's been expanded in all directions.
        // Let's find the star coordinates.
        var starCoordinates: [(Int, Int)] = []
        for y in 0..<transposedStarMap.count {
            for x in 0..<transposedStarMap[y].count {
                if transposedStarMap[y][x] {
                    starCoordinates.append((x, y))
                }
            }
        }
        // Now, for each star, we need to find the Manhattan distance to
        // every other star.
        for (starId, star) in starCoordinates.enumerated() {
            for otherStar in starCoordinates[starId+1..<starCoordinates.count] {
                answer += abs(star.0 - otherStar.0) + abs(star.1 - otherStar.1)
            }
        }        
        
        print("Answer is \(answer)")
    }
}
