import XCTest
@testable import Poker

class CustomTests: XCTestCase {
    func testSuitParser() {
        assert(suitParser.run("♢").match! == Suit.diamonds)
        assert(suitParser.run("♡").match! == Suit.hearts)
        assert(suitParser.run("♤").match! == Suit.spades)
        assert(suitParser.run("♧").match! == Suit.clubs)
    }
    
    func testRankParser() {
        assert(rankParser.run("2").match! == Rank.two)
        assert(rankParser.run("3").match! == Rank.three)
        assert(rankParser.run("4").match! == Rank.four)
        assert(rankParser.run("5").match! == Rank.five)
        assert(rankParser.run("6").match! == Rank.six)
        assert(rankParser.run("7").match! == Rank.seven)
        assert(rankParser.run("8").match! == Rank.eight)
        assert(rankParser.run("9").match! == Rank.nine)
        assert(rankParser.run("10").match! == Rank.ten)
        assert(rankParser.run("J").match! == Rank.jack)
        assert(rankParser.run("Q").match! == Rank.queen)
        assert(rankParser.run("K").match! == Rank.king)
        assert(rankParser.run("A").match! == Rank.ace)
    }
    
    func testCardParser() {
        XCTAssertEqual(cardParser.run("10♤").match?.rank, .ten)
        XCTAssertEqual(cardParser.run("10♤").match?.suit, .spades)
        
        XCTAssertEqual(cardParser.run("J♡").match?.rank, .jack)
        XCTAssertEqual(cardParser.run("J♡").match?.suit, .hearts)
        
        XCTAssertEqual(cardParser.run("A♢").match?.rank, .ace)
        XCTAssertEqual(cardParser.run("A♢").match?.suit, .diamonds)
        
        XCTAssertEqual(cardParser.run("3♧").match?.rank, .three)
        XCTAssertEqual(cardParser.run("3♧").match?.suit, .clubs)
    }
    
    func testCardAndSpaceParser() {
        XCTAssertEqual(cardAndSpaceParser.run("10♤ ").match?.rank, .ten)
        XCTAssertEqual(cardAndSpaceParser.run("10♤ ").match?.suit, .spades)
        
        XCTAssertEqual(cardAndSpaceParser.run("J♡ ").match?.rank, .jack)
        XCTAssertEqual(cardAndSpaceParser.run("J♡ ").match?.suit, .hearts)
        
        XCTAssertEqual(cardAndSpaceParser.run("A♢ ").match?.rank, .ace)
        XCTAssertEqual(cardAndSpaceParser.run("A♢ ").match?.suit, .diamonds)
        
        XCTAssertEqual(cardAndSpaceParser.run("3♧ ").match?.rank, .three)
        XCTAssertEqual(cardAndSpaceParser.run("3♧ ").match?.suit, .clubs)
        
        XCTAssertEqual(cardAndSpaceParser.run("3♧").match, nil)
    }
    
    func testHandParser() {
        XCTAssertEqual(
            handParser.run("10♤ 3♧ A♢ 7♢ J♡").match,
            [
                Card(rank: .ten, suit: .spades),
                Card(rank: .three, suit: .clubs),
                Card(rank: .ace, suit: .diamonds),
                Card(rank: .seven, suit: .diamonds),
                Card(rank: .jack, suit: .hearts),
            ]
        )
    }
    
    func testRankArrayHasHighCard() {
        XCTAssertTrue(Array<Rank>([.three, .two, .five, .six, .ten]).hasHighCard(over: [.three, .two, .five, .six, .nine] ))
        XCTAssertTrue(Array<Rank>([.ten, .five, .three]).hasHighCard(over: [.ten, .five, .two] ))
        XCTAssertTrue(Array<Rank>([.three, .five, .ten]).hasHighCard(over: [.five, .ten, .two] ))
        
        XCTAssertTrue(Array<Rank>([.ace, .king]).hasHighCard(over: [.three, .two]))
        XCTAssertTrue(Array<Rank>([.ace, .king]).hasHighCard(over: [.king, .queen]))
        XCTAssertTrue(Array<Rank>([.ace, .two]).hasHighCard(over: [.king, .queen]))
        
        XCTAssertFalse(Array<Rank>([.king, .queen]).hasHighCard(over: [.ace, .king]))
        XCTAssertFalse(Array<Rank>([.king, .queen]).hasHighCard(over: [.ace, .two]))
        XCTAssertFalse(Array<Rank>([.king, .queen]).hasHighCard(over: [.king, .queen]))
    }
    
    func testRankArrayHighToLow() {
        XCTAssertEqual(Array<Rank>([.two, .three, .four]).highToLow, [.four, .three, .two])
        XCTAssertEqual(Array<Rank>([.two, .four, .three]).highToLow, [.four, .three, .two])
        XCTAssertEqual(Array<Rank>([.four, .three, .two]).highToLow, [.four, .three, .two])
        
        XCTAssertEqual(Array<Rank>([.ten, .two, .ace]).highToLow, [.ace, .ten, .two])
    }
    
    func testHandResultsResultMethod() {
        XCTAssertEqual(PokerHand.init("4♢ 3♤ 4♤ J♤ K♤")?.result().handRank, .pair)
        XCTAssertEqual(PokerHand.init("Q♡ K♡ J♢ 10♧ 9♡")?.result().handRank, .straight)
        XCTAssertEqual(PokerHand.init("A♢ K♧ 10♢ J♢ Q♢")?.result().handRank, .straight)
        XCTAssertEqual(PokerHand.init("2♢ 8♡ 5♢ 2♡ 8♧")?.result().handRank, .twoPair)
        
        XCTAssertEqual(PokerHand.init("2♤ 3♡ A♤ 5♤ 4♤")?.result().handRank, .straight)
        XCTAssertEqual(PokerHand.init("4♢ 3♤ 4♤ J♤ K♤")?.result().handRank, .pair)
        XCTAssertEqual(PokerHand.init("3♢ 8♡ 3♡ 3♧ 9♧")?.result().handRank, .threeOfAKind)
        XCTAssertEqual(PokerHand.init("2♢ 8♡ 5♢ 2♡ 8♧")?.result().handRank, .twoPair)
    }
    
    func testRankArrayIsConsecutiveMethod() {
        XCTAssertTrue(Array<Rank>([.queen, .king, .jack, .ten, .nine]).isConsecutive())
        XCTAssertTrue(Array<Rank>([.queen, .eight, .jack, .ten, .nine]).isConsecutive())
        XCTAssertTrue(Array<Rank>([.seven, .eight, .jack, .ten, .nine]).isConsecutive())
        XCTAssertTrue(Array<Rank>([.ace, .two, .three, .four, .five]).isConsecutive())
        
        XCTAssertFalse(Array<Rank>([.two, .eight, .jack, .ten, .nine]).isConsecutive())
    }

    
    func testHandResultsComparisonIntegration() {
        XCTAssertGreaterThan(PokerHand.init("A♢ K♧ 10♢ J♢ Q♢")!.result(), PokerHand.init("Q♡ K♡ J♢ 10♧ 9♡")!.result())
        
        XCTAssertGreaterThan(PokerHand.init("2♤ 3♡ A♤ 5♤ 4♤")!.result(), PokerHand.init("3♢ 8♡ 3♡ 3♧ 9♧")!.result())
        
        XCTAssertGreaterThan(PokerHand.init("3♡ 2♡ 5♧ 6♢ 10♡")!.result(), PokerHand.init("3♢ 2♢ 5♤ 6♤ 9♡")!.result())
        
        XCTAssertGreaterThan(PokerHand.init("4♤ 4♧ 5♡ 10♢ 3♡")!.result(), PokerHand.init("4♡ 2♡ 5♧ 4♢ 10♡")!.result())
        
        XCTAssertGreaterThan(PokerHand.init("2♢ 8♡ 8♢ 2♡ 8♧")!.result(), PokerHand.init("3♡ A♡ 3♢ 3♧ A♧")!.result())
    }
}
