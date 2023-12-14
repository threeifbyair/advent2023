enum MazeValue: String {
    case blank = "."
    case upDown = "|"
    case leftRight = "-"
    case upRight = "L"
    case upLeft = "J"
    case downRight = "F"
    case downLeft = "7"
    case start = "S"
}

enum MazeDirection: String {
    case up = "U"
    case down = "D"
    case left = "L"
    case right = "R"
}

struct MazeEntry {
    var value: MazeValue
    var topLeftInside: Bool?
    var topRightInside: Bool?
    var bottomLeftInside: Bool?
    var bottomRightInside: Bool?
    var partOfLoop: Bool = false

    func hasLeft() -> Bool {
        return value == .leftRight || value == .upLeft || value == .downLeft
    }

    func hasRight() -> Bool {
        return value == .leftRight || value == .upRight || value == .downRight
    }
    
    func hasUp() -> Bool {
        return value == .upDown || value == .upRight || value == .upLeft
    }
    
    func hasDown() -> Bool {
        return value == .upDown || value == .downRight || value == .downLeft
    }
}

class Day10: AdventDay {
    override func run() {
        var answer: Int = 0
        var maze: [[MazeEntry]] = []
        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            var mazeLine: [MazeEntry] = []
            for char in str {
                mazeLine.append(MazeEntry(value: MazeValue(rawValue: String(char))!))
            }
            mazeLine = [MazeEntry(value: .blank)] + mazeLine + [MazeEntry(value: .blank)]
            maze.append(mazeLine)
        }
        let firstLine: [MazeEntry] = Array(repeating: MazeEntry(value: .blank), count: maze[0].count)
        maze = [firstLine] + maze + [firstLine]

        // First, find the start.
        var start: (Int, Int) = (0, 0)
        for (y, line) in maze.enumerated() {
            for (x, entry) in line.enumerated() {
                if entry.value == .start {
                    start = (x, y)
                }
            }
        }
        //print("Start is at \(start)")
        var position: (Int, Int) = start
        var lastDirection: MazeDirection = .down
        maze[start.1][start.0].partOfLoop = true
        // Now, because the start doesn't specify a direction, we need to
        // find something it connects to.
        if maze[start.1][start.0+1].hasLeft() {
            position.0 += 1
            lastDirection = .right
        }
        else if maze[start.1][start.0-1].hasRight() {
            position.0 -= 1
            lastDirection = .left
        }
        else if maze[start.1+1][start.0].hasUp() {
            position.1 += 1
            lastDirection = .down
        }
        else if maze[start.1-1][start.0].hasDown() {
            position.1 -= 1
            lastDirection = .up
        }
        else {
            print("Couldn't find a direction for the start.")
            return
        }
        let firstDirection: MazeDirection = lastDirection
        //print("First move is to \(position), direction is \(lastDirection)")
        maze[position.1][position.0].partOfLoop = true
        var numSteps: Int = 1
        while position != start {
            //print("Now at \(position), entry is \(maze[position.1][position.0]), direction is \(lastDirection)")
            switch maze[position.1][position.0].value {
                case .blank:
                    print("Found a blank at \(position)")
                    return
                case .upDown:
                    if lastDirection == .up {
                        position.1 -= 1
                    }
                    else if lastDirection == .down {
                        position.1 += 1
                    }
                    else {
                        print("Found an upDown at \(position) but last direction was \(lastDirection)")
                        return
                    }
                case .leftRight:
                    if lastDirection == .left {
                        position.0 -= 1
                    }
                    else if lastDirection == .right {
                        position.0 += 1
                    }
                    else {
                        print("Found a leftRight at \(position) but last direction was \(lastDirection)")
                        return
                    }
                case .upRight:
                    if lastDirection == .down {
                        position.0 += 1
                        lastDirection = .right
                    }
                    else if lastDirection == .left {
                        position.1 -= 1
                        lastDirection = .up
                        
                    }
                    else {
                        print("Found an upRight at \(position) but last direction was \(lastDirection)")
                        return
                    }
                case .upLeft:
                    if lastDirection == .down {
                        position.0 -= 1
                        lastDirection = .left
                    }
                    else if lastDirection == .right {
                        position.1 -= 1
                        lastDirection = .up
                    }
                    else {
                        print("Found an upLeft at \(position) but last direction was \(lastDirection)")
                        return
                    }
                case .downRight:
                    if lastDirection == .up {
                        position.0 += 1
                        lastDirection = .right
                    }
                    else if lastDirection == .left {
                        position.1 += 1
                        lastDirection = .down
                    }
                    else {
                        print("Found a downRight at \(position) but last direction was \(lastDirection)")
                        return
                    }
                case .downLeft:
                    if lastDirection == .up {
                        position.0 -= 1
                        lastDirection = .left
                    }
                    else if lastDirection == .right {
                        position.1 += 1
                        lastDirection = .down
                    }
                    else {
                        print("Found a downLeft at \(position) but last direction was \(lastDirection)")
                        return
                    }
                case .start:
                    print("Found a start at \(position)")
                    return
            }
            maze[position.1][position.0].partOfLoop = true
            numSteps += 1
        }
        if partTwo {
            // So we've marked the entire loop. We need to replace the start
            // with what it actually is (we can find that from firstDirection
            // and lastDirection), and then we just go through each line
            // and mark the inside/outside of the loop.
            switch (firstDirection, lastDirection) {
            case (.up, .up), (.down, .down):
                maze[start.1][start.0].value = .upDown
            case (.left, .left), (.right, .right):
                maze[start.1][start.0].value = .leftRight
            case (.up, .left), (.right, .down):
                maze[start.1][start.0].value = .upRight
            case (.up, .right), (.left, .down):
                maze[start.1][start.0].value = .upLeft
            case (.down, .left), (.right, .up):
                maze[start.1][start.0].value = .downRight
            case (.down, .right), (.left, .up):
                maze[start.1][start.0].value = .downLeft
            default:
                print("Couldn't find a direction for the start.")
                return
            }
            for (y, line) in maze.enumerated() {
                for (x, entry) in line.enumerated() {
                    if (x == 0) {
                        // The first entry is a blank so we know it's outside.
                        maze[y][x].topLeftInside = false
                        maze[y][x].topRightInside = false
                        maze[y][x].bottomLeftInside = false
                        maze[y][x].bottomRightInside = false
                        continue
                    }
                    maze[y][x].topLeftInside = maze[y][x-1].topRightInside
                    maze[y][x].bottomLeftInside = maze[y][x-1].bottomRightInside
                    if entry.partOfLoop {
                        // OK, we're part of the loop. Let's see what needs
                        // to change.
                        switch entry.value {
                        case .upDown:
                            maze[y][x].topRightInside = !maze[y][x].topLeftInside!
                            maze[y][x].bottomRightInside = !maze[y][x].bottomLeftInside!
                        case .leftRight:
                            maze[y][x].topRightInside = maze[y][x].topLeftInside!
                            maze[y][x].bottomRightInside = maze[y][x].bottomLeftInside!
                        case .upRight, .upLeft:
                            maze[y][x].topRightInside = !maze[y][x].topLeftInside!
                            maze[y][x].bottomRightInside = maze[y][x].bottomLeftInside!
                        case .downRight, .downLeft:
                            maze[y][x].topRightInside = maze[y][x].topLeftInside!
                            maze[y][x].bottomRightInside = !maze[y][x].bottomLeftInside!
                        default:
                            print("Found a \(entry.value) at \(x),\(y) but it doesn't make sense.")
                                return
                        }
                    }
                    else {
                        // We're not part of the loop, so we just copy the
                        // values from the previous entry.
                        maze[y][x].topRightInside = maze[y][x].topLeftInside
                        maze[y][x].bottomRightInside = maze[y][x].bottomLeftInside
                    }
                }
            }
            // OK, now we've marked everything, we just need to count blanks that are fully inside.
            for line in maze {
                for entry in line {
                    if entry.topLeftInside! && entry.topRightInside! && entry.bottomLeftInside! && entry.bottomRightInside! {
                        answer += 1
                    }
                }
            }
        }
        else {
            answer = Int((numSteps + 1) / 2)
        }
        
        print("Answer is \(answer)")
        }
    }
