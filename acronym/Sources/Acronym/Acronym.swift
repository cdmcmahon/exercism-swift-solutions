//Solution goes in Sources

extension String {
    func replaceAll(char: Character, with replacement: Character) -> String {
        return self
            .map({ return $0 == char ? replacement : $0 })
            .map(String.init)
            .joined()
    }
}

struct Acronym {
    static func abbreviate(_ input: String) -> String {
        return input
            .replaceAll(char: "-", with: " ")
            .split(separator: " ")
            .compactMap({ word in
                let upperCaseLetters = word.dropFirst().filter({ $0.isUppercase }).map(String.init).joined()
                
            
                return String(word.first ?? Character("")) + upperCaseLetters
            })
            .joined()
    }
}
