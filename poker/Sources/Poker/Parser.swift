//
//  Parser.swift
//  Poker
//
//  Created by Corey McMahon on 9/1/19.
//

import Foundation

struct Parser<A> {
    let run: (inout Substring) -> A?
    
    func run(_ str: String) -> (match: A?, rest: Substring) {
      var str = str[...]
      let match = self.run(&str)
      return (match, str)
    }
    
    static var never: Parser {
      return Parser { _ in nil }
    }
    
    static func always<B>(_ b: B) -> Parser<B> {
      return Parser<B> { _ in b }
    }
    
    static var empty: Parser<()> {
        return Parser<()> { str in
            return str.isEmpty ? () : nil
        }
    }
    
    func map<B>(_ f: @escaping (A) -> B) -> Parser<B> {
      return Parser<B> { str -> B? in
        self.run(&str).map(f)
      }
    }
    
    func flatMap<B>(_ f: @escaping (A) -> Parser<B>) -> Parser<B> {
        return Parser<B> { str -> B? in
            let original = str
            guard let matchA = self.run(&str) else { return nil }
            let parserB = f(matchA)
            guard let matchB = parserB.run(&str) else {
                str = original
                return nil
            }
            return matchB
        }
    }
    
    static func zip<A, B>(_ a: Parser<A>, _ b: Parser<B>) -> Parser<(A, B)> {
        return Parser<(A, B)> { str -> (A, B)? in
            let original = str
            guard let matchA = a.run(&str) else { return nil }
            guard let matchB = b.run(&str) else {
                str = original
                return nil
            }
            return (matchA, matchB)
        }
    }
    static func zip<A, B, C>(
      _ a: Parser<A>,
      _ b: Parser<B>,
      _ c: Parser<C>
      ) -> Parser<(A, B, C)> {
      return zip(a, zip(b, c))
        .map { a, bc in (a, bc.0, bc.1) }
    }
    static func zip<A, B, C, D>(
      _ a: Parser<A>,
      _ b: Parser<B>,
      _ c: Parser<C>,
      _ d: Parser<D>
      ) -> Parser<(A, B, C, D)> {
      return zip(a, zip(b, c, d))
        .map { a, bcd in (a, bcd.0, bcd.1, bcd.2) }
    }
    static func zip<A, B, C, D, E>(
      _ a: Parser<A>,
      _ b: Parser<B>,
      _ c: Parser<C>,
      _ d: Parser<D>,
      _ e: Parser<E>
      ) -> Parser<(A, B, C, D, E)> {

      return zip(a, zip(b, c, d, e))
        .map { a, bcde in (a, bcde.0, bcde.1, bcde.2, bcde.3) }
    }
    static func zip<A, B, C, D, E, F>(
      _ a: Parser<A>,
      _ b: Parser<B>,
      _ c: Parser<C>,
      _ d: Parser<D>,
      _ e: Parser<E>,
      _ f: Parser<F>
      ) -> Parser<(A, B, C, D, E, F)> {
      return zip(a, zip(b, c, d, e, f))
        .map { a, bcdef in (a, bcdef.0, bcdef.1, bcdef.2, bcdef.3, bcdef.4) }
    }
    static func zip<A, B, C, D, E, F, G>(
      _ a: Parser<A>,
      _ b: Parser<B>,
      _ c: Parser<C>,
      _ d: Parser<D>,
      _ e: Parser<E>,
      _ f: Parser<F>,
      _ g: Parser<G>
      ) -> Parser<(A, B, C, D, E, F, G)> {
      return zip(a, zip(b, c, d, e, f, g))
        .map { a, bcdefg in (a, bcdefg.0, bcdefg.1, bcdefg.2, bcdefg.3, bcdefg.4, bcdefg.5) }
    }
}

func oneOf<A>(_ ps: [Parser<A>]) -> Parser<A> {
  return Parser<A> { str in
    for p in ps {
      if let match = p.run(&str) {
        return match
      }
    }
    return nil
  }
}

let intParser = Parser<Int> { str in
  let prefix = str.prefix(while: { $0.isNumber })
  guard let int = Int(prefix) else { return nil }
  str.removeFirst(prefix.count)
  return int
}

func literalParser(_ literal: String) -> Parser<Void> {
  return Parser<Void> { str in
    guard str.hasPrefix(literal) else { return nil }
    str.removeFirst(literal.count)
    return ()
  }
}

func stringEnumValueParser<E: RawRepresentable>(_ enumVal: E) -> Parser<E> where E.RawValue == String {
    return Parser<E> { str -> E? in
        guard literalParser(enumVal.rawValue).run(&str) != nil else { return nil }
        return enumVal
    }
}

func stringEnumParser<E: RawRepresentable & CaseIterable>(_ enumType: E.Type) -> Parser<E> where E.RawValue == String {
    return Parser<E> { str in
        let resultList = enumType.allCases
            .map(stringEnumValueParser)
            .compactMap { $0.run(&str) }
        guard !resultList.isEmpty else {
            return nil
        }
        return resultList[0]
    }
}

let charParser = Parser<Character> { str in
  guard !str.isEmpty else { return nil }
  return str.removeFirst()
}

func prefixParser(while p: @escaping (Character) -> Bool) -> Parser<Substring> {
  return Parser<Substring> { str in
    let prefix = str.prefix(while: p)
    str.removeFirst(prefix.count)
    return prefix
  }
}

func nOrMoreSpacesParser(n: Int) -> Parser<()> {
    return prefixParser(while: { $0 == " " })
        .flatMap {
            $0.count < n
                ? .never
                : .always(())
    }
}

