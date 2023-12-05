class Day2: AdventDay {
    struct Game {
        var numRed: Int
        var numGreen: Int
        var numBlue: Int
    }

    var masterCount: Game = Game(numRed: 12, numGreen: 13, numBlue: 14)
    
    func checkGame(_ game: [Game]) -> Bool {
        for g in game {
            if g.numRed > masterCount.numRed || g.numGreen > masterCount.numGreen || g.numBlue > masterCount.numBlue {
                return false
            }
        }
        return true
    }      

    func powerGame(_ game: [Game]) -> Int {
        var minGame: Game = Game(numRed: 0, numGreen: 0, numBlue: 0)
        for g in game {
            if g.numRed > minGame.numRed {
                minGame.numRed = g.numRed
            }
            if g.numGreen > minGame.numGreen {
                minGame.numGreen = g.numGreen
            }
            if g.numBlue > minGame.numBlue {
                minGame.numBlue = g.numBlue
            }
        }
        return minGame.numRed * minGame.numGreen * minGame.numBlue
    }      
    
    override func run() {
        var answer: Int = 0
        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            var game: [Game] = []
            
            let split = str.split(separator: ": ")
            let gameid = Int(String(split[0][split[0].index(split[0].startIndex, offsetBy: 5) ..< split[0].endIndex]))!
            let gameparts = split[1].split(separator: "; ")
            for gamepart in gameparts {
                let parts = gamepart.split(separator: ", ")
                var thisGame = Game(numRed: 0, numGreen: 0, numBlue: 0)
                for part in parts {
                    let color = part.split(separator: " ")
                    let num = Int(color[0])!
                    switch color[1] {
                    case "red":
                        thisGame.numRed = num
                    case "green":
                        thisGame.numGreen = num
                    case "blue":
                        thisGame.numBlue = num
                    default:
                        fatalError("Unknown color \(color[1])")
                    }
                }
                game.append(thisGame)
            }

            if partTwo {
                answer += powerGame(game)
            }
            else {
                if checkGame(game) {
                    answer += gameid
                }
            }
        }
        print("Answer is \(answer)")
    }
}
