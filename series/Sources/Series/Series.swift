//Solution goes in Sources
struct Series {
    let input: String
    
    init(_ input: String) {
        self.input = input
    }
    
    func slices(_ sliceSize: Int) -> [[Int]] {
        let digitList = input.map(String.init).compactMap(Int.init)
        return digitList.enumerated().compactMap { (offset, element) in
            guard digitList.count >= offset + sliceSize else { return nil }
            return Array(digitList[offset..<offset+sliceSize])
        }
    }
}
