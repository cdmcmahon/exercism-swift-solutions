// MARK: - Enums
enum Suit: String, CaseIterable {
    case diamonds = "♢"
    case hearts = "♡"
    case spades = "♤"
    case clubs = "♧"
}

enum Rank: String, CaseIterable, Comparable, RawRepresentable {
    init?(_ value: Int) {
        switch(value) {
        case 11:
            self = .jack
        case 12:
            self = .queen
        case 13:
            self = .king
        case 14:
            self = .ace
        case 1:
            self = .ace
        default:
            guard let rank = Rank(rawValue: String(value)) else { return nil }
            self = rank
        }
    }

    case ace = "A"
    case king = "K"
    case queen = "Q"
    case jack = "J"
    case ten = "10"
    case nine = "9"
    case eight = "8"
    case seven = "7"
    case six = "6"
    case five = "5"
    case four = "4"
    case three = "3"
    case two = "2"
    
    var intValue: Int {
        switch(self) {
        case .jack:
            return 11
        case .queen:
            return 12
        case .king:
            return 13
        case .ace:
            return 14
        default:
            return Int(self.rawValue)!
        }
    }
    
    var aceLowIntValue: Int {
        return self == .ace ? 1 : intValue
    }
    
    static func <(lhs: Rank, rhs: Rank) -> Bool {
        return lhs.intValue < rhs.intValue
    }

    static func ==(lhs: Rank, rhs: Rank) -> Bool {
        return lhs.intValue == rhs.intValue
    }
}

extension Array where Element == Rank {
    static func ==(lhs: [Rank], rhs: [Rank]) -> Bool {
        return lhs.allSatisfy({ rhs.contains($0) })
            && rhs.allSatisfy({ lhs.contains($0) })
            && lhs.count == rhs.count
    }
    
    func isConsecutive() -> Bool {
        guard let lowestValue = self.map({ $0.intValue }).min(),
         let aceLowLowestValue = self.map({ $0.aceLowIntValue }).min() else { return false }
        let expectedRange = lowestValue...lowestValue+self.count-1
        let aceLowExpectedRange = aceLowLowestValue...aceLowLowestValue+self.count-1
        return self == expectedRange.compactMap(Rank.init)
            || self == aceLowExpectedRange.compactMap(Rank.init)
    }
    
    var highToLow: Array<Rank> {
        return self.sorted(by: { $0 > $1 })
    }
    
    func hasHighCard(over otherRankArray: [Rank]) -> Bool {
        guard !self.isEmpty else { return false }
        guard !otherRankArray.isEmpty else { return true }
        guard self.max() != otherRankArray.max() else {
            return Array(self.highToLow.dropFirst()).hasHighCard(over: Array(otherRankArray.highToLow.dropFirst()))
        }
        return self.highToLow.contains { rank in
            return rank > otherRankArray.max()!
        }
    }
    
    func isEqualInRank(to otherRankArray: [Rank]) -> Bool {
        return !self.hasHighCard(over: otherRankArray) && !otherRankArray.hasHighCard(over: self)
    }
}

struct Card: Equatable, Hashable {
    let rank: Rank
    let suit: Suit
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }
}

enum HandResultRank: Int, RawRepresentable, Comparable {
    static func < (lhs: HandResultRank, rhs: HandResultRank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case highCard = 0
    case pair = 1
    case twoPair = 2
    case threeOfAKind = 3
    case straight = 4
    case flush = 5
    case fullHouse = 6
    case fourOfAKind = 7
    case straightFlush = 8
    case royalFlush = 9
}

enum HandResult: Comparable {
    case royalFlush
    case straightFlush(highRank: Rank)
    case fourOfAKind(rank: Rank, highRank: Rank)
    case fullHouse(threeRank: Rank, twoRank: Rank)
    case flush(highRanks: [Rank])
    case straight(highRank: Rank)
    case threeOfAKind(rank: Rank, highRanks: [Rank])
    case twoPair(pairOneRank: Rank, pairTwoRank: Rank, highRank: Rank)
    case pair(pairRank: Rank, highRanks: [Rank])
    case highCard(highRanks: [Rank])
    
    var handRank: HandResultRank {
        switch self {
        case .highCard:
            return HandResultRank.highCard
        case .pair:
            return HandResultRank.pair
        case .twoPair:
            return HandResultRank.twoPair
        case .threeOfAKind:
            return HandResultRank.threeOfAKind
        case .straight:
            return HandResultRank.straight
        case .flush:
            return HandResultRank.flush
        case .fullHouse:
            return HandResultRank.fullHouse
        case .fourOfAKind:
            return HandResultRank.fourOfAKind
        case .straightFlush:
            return HandResultRank.straightFlush
        case .royalFlush:
            return HandResultRank.royalFlush
        }
    }

    static func ==(lhs: HandResult, rhs: HandResult) -> Bool {
        guard lhs.handRank == rhs.handRank else { return false }
        switch (lhs, rhs) {
        case let (.highCard(lhsHighRanks), .highCard(rhsHighRanks)):
            return lhsHighRanks.highToLow.isEqualInRank(to: rhsHighRanks.highToLow)
        case let (.pair(lhsPairRank, lhsHighRanks), .pair(rhsPairRank, rhsHighRanks)):
            guard lhsPairRank == rhsPairRank else { return false }
            return lhsHighRanks.highToLow.isEqualInRank(to: rhsHighRanks.highToLow)
        case let (.twoPair(lhsPairOneRank, lhsPairTwoRank, lhsHighRank), .twoPair(rhsPairOneRank, rhsPairTwoRank, rhsHighRank)):
            guard [lhsPairOneRank, lhsPairTwoRank].isEqualInRank(to: [rhsPairOneRank, rhsPairTwoRank]) else { return false }
            return lhsHighRank == rhsHighRank
        case let (.threeOfAKind(lhsThreeOfAKindRank, lhsHighRanks), .threeOfAKind(rhsThreeOfAKindRank, rhsHighRanks)):
            guard lhsThreeOfAKindRank == rhsThreeOfAKindRank else { return false }
            return lhsHighRanks.highToLow.isEqualInRank(to: rhsHighRanks.highToLow)
        case let (.straight(lhsHighRank), .straight(rhsHighRank)):
            return lhsHighRank == rhsHighRank
        case let (.flush(lhsHighRanks), .flush(rhsHighRanks)):
            return lhsHighRanks.highToLow.isEqualInRank(to: rhsHighRanks.highToLow)
        case let (.fullHouse(lhsThreeKind, lhsTwoKind), .fullHouse(rhsThreeKind, rhsTwoKind)):
            return [lhsThreeKind, lhsTwoKind].isEqualInRank(to: [rhsThreeKind, rhsTwoKind])
        case let (.fourOfAKind(lhsFourOfAKindRank, lhsHighRank), .fourOfAKind(rhsFourOfAKindRank, rhsHighRank)):
            guard lhsFourOfAKindRank == rhsFourOfAKindRank else { return false }
            return lhsHighRank == rhsHighRank
        case let (.straightFlush(lhsHighRank), .straightFlush(rhsHighRank)):
            return lhsHighRank == rhsHighRank
        case (.royalFlush, .royalFlush):
            return true
        default:
            fatalError()
        }
    }
    
    static func <(lhs: HandResult, rhs: HandResult) -> Bool {
        return rhs > lhs
    }
    
    static func >(lhs: HandResult, rhs: HandResult) -> Bool {
        guard lhs.handRank == rhs.handRank else { return lhs.handRank > rhs.handRank }
        switch (lhs, rhs) {
        case let (.highCard(lhsHighRanks), .highCard(rhsHighRanks)):
            return lhsHighRanks.highToLow.hasHighCard(over: rhsHighRanks.highToLow)
        case let (.pair(lhsPairRank, lhsHighRanks), .pair(rhsPairRank, rhsHighRanks)):
            guard lhsPairRank == rhsPairRank else { return lhsPairRank > rhsPairRank }
            return lhsHighRanks.highToLow.hasHighCard(over: rhsHighRanks.highToLow)
        case let (.twoPair(lhsPairOneRank, lhsPairTwoRank, lhsHighRank), .twoPair(rhsPairOneRank, rhsPairTwoRank, rhsHighRank)):
            guard [lhsPairOneRank, lhsPairTwoRank].isEqualInRank(to: [rhsPairOneRank, rhsPairTwoRank]) else {
                return [lhsPairOneRank, lhsPairTwoRank].hasHighCard(over: [rhsPairOneRank, rhsPairTwoRank])
            }
            return lhsHighRank > rhsHighRank
        case let (.threeOfAKind(lhsThreeOfAKindRank, lhsHighRanks), .threeOfAKind(rhsThreeOfAKindRank, rhsHighRanks)):
            guard lhsThreeOfAKindRank == rhsThreeOfAKindRank else { return lhsThreeOfAKindRank > rhsThreeOfAKindRank }
            return lhsHighRanks.highToLow.hasHighCard(over: rhsHighRanks.highToLow)
        case let (.straight(lhsHighRank), .straight(rhsHighRank)):
            return lhsHighRank > rhsHighRank
        case let (.flush(lhsHighRanks), .flush(rhsHighRanks)):
            return lhsHighRanks.highToLow.hasHighCard(over: rhsHighRanks.highToLow)
        case let (.fullHouse(lhsThreeKind, lhsTwoKind), .fullHouse(rhsThreeKind, rhsTwoKind)):
            guard lhsThreeKind != rhsThreeKind else { return lhsTwoKind > rhsTwoKind }
            return lhsThreeKind > rhsThreeKind
        case let (.fourOfAKind(lhsFourOfAKindRank, lhsHighRank), .fourOfAKind(rhsFourOfAKindRank, rhsHighRank)):
            guard lhsFourOfAKindRank == rhsFourOfAKindRank else { return lhsFourOfAKindRank > rhsFourOfAKindRank }
            return lhsHighRank > rhsHighRank
        case let (.straightFlush(lhsHighRank), .straightFlush(rhsHighRank)):
            return lhsHighRank > rhsHighRank
        case (.royalFlush, .royalFlush):
            return false
        default:
            fatalError()
        }
    }
}

// Mark: Models
struct Poker {
    static func bestHand(_ handStrings: [String]) -> String? {
        return handStrings
            .compactMap(PokerHand.init)
            .sorted(by: {(card1, card2) in card1.result() > card2.result() })
            .first?
            .toString()
    }
}

typealias PokerHand = Array<Card>
extension PokerHand {
    init?(_ handInput: String) {
        guard let hand = handParser.run(handInput).match else { return nil }
        self = hand
    }

    init?(cards: [Card]) {
        guard cards.count == 5 else { return nil }
        self.init()
        self.append(cards[0])
        self.append(cards[1])
        self.append(cards[2])
        self.append(cards[3])
        self.append(cards[4])
    }
    
    func toString() -> String {
        return self.map({ card in
            "\(card.rank.rawValue)\(card.suit.rawValue)"
        }).joined(separator: " ")
    }
    
    func result() -> HandResult {
        return [
            royalFlush(),
            straightFlush(),
            fourOfAKind(),
            fullHouse(),
            flush(),
            straight(),
            threeOfAKind(),
            twoPair(),
            pair(),
            highCard()
        ].compactMap({ $0 })[0]
    }
    
    private func ranks() -> [Rank] {
        return self.map({ $0.rank })
    }
    
    private func suits() -> [Suit] {
        return self.map({ $0.suit })
    }
    
    private func rankFrequencies() -> Dictionary<Rank, Int> {
        return self.reduce(into: Dictionary<Rank, Int>()) { map, card in
            map[card.rank] = (map[card.rank] ?? 0) + 1
        }
    }
    
    private func getRanks(withFrequency n: Int) -> [Rank] {
        return rankFrequencies().filter({ (key: Rank, value: Int) -> Bool in
            value == n
        }).keys.map { $0 }
    }
    
    private func royalFlush() -> HandResult? {
        guard self.flush() != nil
            && ranks() == [.ace, .king, .queen, .jack, .ten] else {
            return nil
        }
        return .royalFlush
        
    }
    private func straightFlush() -> HandResult? {
        guard Set<Suit>(suits()).count == 1
            && self.straight() != nil else {
            return nil
        }
        return .straightFlush(highRank: Rank.jack)
    }
    private func fourOfAKind() -> HandResult? {
        guard let fourOfAKindRank = getRanks(withFrequency: 4).first,
            let highCardRank = getRanks(withFrequency: 1).first else { return nil }
        return .fourOfAKind(
            rank: fourOfAKindRank,
            highRank: highCardRank
        )
    }
    private func fullHouse() -> HandResult? {
        guard let threeOfAKindRank = getRanks(withFrequency: 3).first,
            let pairRank = getRanks(withFrequency: 2).first else { return nil }
        return .fullHouse(threeRank: threeOfAKindRank, twoRank: pairRank)
    }
    private func flush() -> HandResult? {
        guard Set<Suit>(self.map({ $0.suit })).count == 1 else { return nil }
        return .flush(highRanks: self.map({ $0.rank }))
    }
    private func straight() -> HandResult? {
        guard ranks().isConsecutive() else { return nil }
        return .straight(highRank: ranks().max()!)
    }
    private func threeOfAKind() -> HandResult? {
        let singleCardRanks = getRanks(withFrequency: 1)
        guard let threeOfAKindRank = getRanks(withFrequency: 3).first,
            singleCardRanks.count == 2 else { return nil }
        return .threeOfAKind(rank: threeOfAKindRank, highRanks: singleCardRanks)
    }
    private func twoPair() -> HandResult? {
        let pairRanks = getRanks(withFrequency: 2)
        guard let highCardRank = getRanks(withFrequency: 1).first,
            pairRanks.count == 2 else { return nil }
        return .twoPair(pairOneRank: pairRanks[0], pairTwoRank:pairRanks[1], highRank: highCardRank)
    }
    private func pair() -> HandResult? {
        let pairRank = getRanks(withFrequency: 2)
        let highCardRanks = getRanks(withFrequency: 1)
        guard pairRank.count == 1, highCardRanks.count == 3 else { return nil }
        return .pair(pairRank: pairRank[0], highRanks: highCardRanks)
    }
    private func highCard() -> HandResult {
        return .highCard(highRanks: self.map { $0.rank })
    }
}

// Mark: Domain specific Parsers
let suitParser: Parser<Suit> = stringEnumParser(Suit.self)
let rankParser: Parser<Rank> = stringEnumParser(Rank.self)
let cardParser: Parser<Card> = Parser<()>.zip(rankParser, suitParser).map {
    Card(rank: $0, suit: $1)
}
let cardAndSpaceParser: Parser<Card> = Parser<()>.zip(
    cardParser,
    nOrMoreSpacesParser(n: 1)
    ).map { card, _ in card }

let handParser: Parser<PokerHand> = Parser<()>.zip(
    nOrMoreSpacesParser(n: 0),
    cardAndSpaceParser,
    cardAndSpaceParser,
    cardAndSpaceParser,
    cardAndSpaceParser,
    cardParser,
    Parser<()>.empty
    ).map { _, card1, card2, card3, card4, card5, _ in
        PokerHand(cards: [card1, card2, card3, card4, card5])!
}
