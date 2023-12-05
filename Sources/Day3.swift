class Day3: AdventDay {
    enum EnginePiece: Equatable {
        case digit(Int)
        case symbol
        case gear
        case whitespace
    }

    func extractDigit(_ piece: EnginePiece) -> Int? {
        switch piece {
        case let .digit(d):
            return d
        default:
            return nil
        }
    }
    
    func findDigit(_ diagram: [[EnginePiece]], _ lineno: Int, _ chrno: Int) -> (Int?, Int) {
        switch diagram[lineno][chrno] {
        case .digit(_):
            // OK. We found a digit. Where does the number start?
            var startChrno = chrno
            while extractDigit(diagram[lineno][startChrno-1]) != nil {
                startChrno -= 1
            }
            var curNumber: Int = 0
            while let e = extractDigit(diagram[lineno][startChrno]) {
                curNumber = curNumber * 10 + e
                startChrno += 1
            }
            return (curNumber, startChrno)
        default:
            return (nil, chrno+1)
        }
    }
    
    
    override func run() {
        var answer: Int = 0
        var diagram: [[EnginePiece]] = []
        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            var piece: [EnginePiece] = [EnginePiece.whitespace]
            var idx = str.startIndex
            while idx != str.endIndex {
                let thisPiece: EnginePiece = if let d = Int(String(str[idx])) { EnginePiece.digit(d) } else if str[idx] == "." { EnginePiece.whitespace } else if str[idx] == "*" { EnginePiece.gear } else { EnginePiece.symbol }
                piece.append(thisPiece)
                idx = str.index(after: idx)
            }
            piece.append(EnginePiece.whitespace)
            diagram.append(piece)
        }

        // We guarantee that there is whitespace all around the array, so we don't need to do any funny business.
        let firstLine = Array(repeating: EnginePiece.whitespace, count: diagram[0].count)

        diagram = [firstLine] + diagram + [firstLine]

        

        
        for (lineno, line) in diagram.enumerated() {
            var curNumber: Int? = nil
            var foundSymbol: Bool = false
            for (chrno, chr) in line.enumerated() {
                if partTwo {
                    switch chr {
                    case .gear:
                        // We've found a gear. Are there numbers around us?
                        var parts: [Int] = []
                        for i in -1...1 {
                            var j = chrno - 1
                            while j <= chrno + 1 {
                                let (n, c) = findDigit(diagram, lineno+i, j)
                                if let n = n {
                                    parts.append(n)
                                }
                                j = c
                            }
                        }
                        if parts.count == 2 {
                            answer += parts[0] * parts[1]
                        }
                    default:
                        break
                    }
                }
                else {
                    switch chr {
                    case let .digit(d):
                        // This one is a digit.
                        if curNumber == nil {
                            // Moving from non-numeric to numeric mode. Look for a symbol.
                            foundSymbol = (diagram[lineno-1][chrno-1] == EnginePiece.symbol || diagram[lineno-1][chrno-1] == EnginePiece.gear ||
                                             diagram[lineno-1][chrno] == EnginePiece.symbol || diagram[lineno-1][chrno] == EnginePiece.gear ||
                                             diagram[lineno][chrno-1] == EnginePiece.symbol || diagram[lineno][chrno-1] == EnginePiece.gear ||
                                             diagram[lineno+1][chrno-1] == EnginePiece.symbol || diagram[lineno+1][chrno-1] == EnginePiece.gear ||
                                             diagram[lineno+1][chrno] == EnginePiece.symbol || diagram[lineno+1][chrno] == EnginePiece.gear)
                            curNumber = 0
                        }
                        if diagram[lineno-1][chrno+1] == EnginePiece.symbol || diagram[lineno-1][chrno+1] == EnginePiece.gear ||
                             diagram[lineno][chrno+1] == EnginePiece.symbol || diagram[lineno][chrno+1] == EnginePiece.gear ||
                             diagram[lineno+1][chrno+1] == EnginePiece.symbol || diagram[lineno+1][chrno+1] == EnginePiece.gear {
                            foundSymbol = true
                        }
                        curNumber = curNumber! * 10 + d
                    default:
                        // It's not a digit. If we had one before, close it out.
                        if let c: Int = curNumber {
                            if foundSymbol {
                                answer += c
                            }
                            curNumber = nil
                        }
                    }
                }
            }
        }        
        print("Answer is \(answer)")
    }
}
