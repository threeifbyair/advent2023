enum CamelCard: String {
    case ace = "A"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "T"
    case jack = "J"
    case queen = "Q"
    case king = "K"
}

extension CamelCard: Comparable {
    static let values: [String: Int] = ["A": 14, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "T": 10, "J": 11, "Q": 12, "K": 13]
    static let values2: [String: Int] = ["A": 14, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "T": 10, "J": 1, "Q": 12, "K": 13]

    static var partTwo: Bool = false
    
    static func ==(lhs: CamelCard, rhs: CamelCard) -> Bool {
        return cardValue(lhs) == cardValue(rhs)
    }

    static func <(lhs: CamelCard, rhs: CamelCard) -> Bool {
        return cardValue(lhs) < cardValue(rhs)
    }

    static func cardValue(_ card: CamelCard) -> Int {
        return (partTwo ? values2[card.rawValue]! : values[card.rawValue]!)
    }

}

enum HandStrength: Int {
    case highCard = 0
    case pair = 1
    case twoPair = 2
    case threeOfAKind = 3
    case fullHouse = 4
    case fourOfAKind = 5
    case fiveOfAKind = 6
}

struct CamelHand: Comparable {
    var cards: [CamelCard] = []
    var strength: HandStrength = .highCard

    init(_ cards: [CamelCard]) {
        self.cards = cards
        self.strength = self.calculateStrength()
    }

    func calculateStrength() -> HandStrength {
        //print("Calculating strength for \(self.cards)")
        var strength: HandStrength = .highCard
        var counts: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        for card in cards {
            //print("Card is \(card), value is \(CamelCard.cardValue(card))")
            counts[CamelCard.cardValue(card)] += 1
            //print("Counts are \(counts)")
        }
        var numDifferent = 0
        for count in counts {
            if count > 0 {
                numDifferent += 1
            }
        }
        for (index, _) in counts.enumerated() {
            if index < 2 {
                continue
            }
            if counts[index] != 0 {
                counts[index] += counts[1]
            }
        }
        //print("Counts are \(counts)")
        var pairs: Int = 0
        var threes: Int = 0
        var fours: Int = 0
        var fives: Int = 0
        for count in counts {
            if count == 2 {
                pairs += 1
            }
            else if count == 3 {
                threes += 1
            }
            else if count == 4 {
                fours += 1
            }
            else if count == 5 {
                fives += 1
            }
        }
        //print("Pairs: \(pairs), threes: \(threes), fours: \(fours), fives: \(fives)")
        if fives >= 1 {
            strength = .fiveOfAKind
        }
        else if fours >= 1 {
            strength = .fourOfAKind
        }
        else if (threes >= 2 && counts[1] < 2) || (threes >= 1 && pairs >= 1 && numDifferent < 4) {
            strength = .fullHouse
        }
        else if threes >= 1 {
            strength = .threeOfAKind
        }
        else if pairs >= 2 && numDifferent < 5 {
            strength = .twoPair
        }
        else if pairs >= 1 {
            strength = .pair
        }
        //print("Strength is \(strength)")
        return strength
    }

    func string() -> String {
        var str: String = ""
        for card in cards {
            str += card.rawValue
        }
        return str
    }

    static func <(lhs: CamelHand, rhs: CamelHand) -> Bool {
        if lhs.strength.rawValue < rhs.strength.rawValue {
            return true
        }
        else if lhs.strength.rawValue > rhs.strength.rawValue {
            return false
        }
        else {
            // Same strength. Compare the cards.
            for cardpair in zip(lhs.cards, rhs.cards) {
                if CamelCard.cardValue(cardpair.0) < CamelCard.cardValue(cardpair.1) {
                    return true
                }
                else if CamelCard.cardValue(cardpair.0) > CamelCard.cardValue(cardpair.1) {
                    return false
                }
            }
            return false
        }
    }
}

class Day7: AdventDay {
    override func run() {
        var answer: Int = 0
        var hands: [(CamelHand, Int)] = []
        CamelCard.partTwo = partTwo
        for str in inputStrings {
            if str.length == 0 {
                continue
            }
            let split = str.split(separator: " ")
            var cards: [CamelCard] = []
            //print(split)
            for card in split[0] {
                cards.append(CamelCard(rawValue: String(card))!)
            }
            //print(cards)
            hands.append((CamelHand(cards), Int(split[1])!))
            //print(hands.last!)
        }
        hands.sort(by: { $0.0 < $1.0 })
        for (mult, hand) in hands.enumerated() {
            //if hand.0.cards.contains(.jack) { 
            //    print("\(mult): Cards: \(hand.0.string()) Strength: \(hand.0.strength) Bid: \(hand.1)")
            //}
            answer += (mult+1) * hand.1
        }

        
        print("Answer is \(answer)")
    }
}
