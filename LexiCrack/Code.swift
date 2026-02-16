//
//  Code.swift
//  LexiCrack
//
//  Adapted from CS193p Lecture 6 CodeBreaker.
//  In LexiCrack, a Peg is a single letter (String) instead of a Color.
//

import Foundation

// A single letter in the game (one of the 26 letters of the English alphabet)
typealias Peg = String

// The match result for a single letter peg in a completed attempt
enum Match: Equatable {
    case exact    // right letter, right position (shown in green)
    case inexact  // right letter, wrong position (shown in yellow)
    case nomatch  // letter not in the word at all (shown in gray)
}

struct Code {
    var kind: Kind
    var pegs: [Peg]

    // An empty string represents a letter slot that has not been filled yet
    static let missingPeg: Peg = ""

    enum Kind: Equatable {
        case master(isHidden: Bool)  // the secret word the player is trying to guess
        case guess                   // the word the player is currently building
        case attempt([Match])        // a submitted guess with its per-letter match results
        case unknown
    }

    // Initialize a Code with a given kind and word length (defaults to 5)
    init(kind: Kind, length: Int = 5) {
        self.kind = kind
        self.pegs = Array(repeating: Code.missingPeg, count: length)
    }

    // MARK: - Word Convenience

    // Read/write the pegs as a plain String (e.g. "CRANE" → ["C","R","A","N","E"])
    var word: String {
        get { pegs.joined() }
        set { pegs = newValue.map { String($0) } }
    }

    // MARK: - State Helpers

    var isHidden: Bool {
        switch kind {
        case .master(let isHidden): return isHidden
        default: return false
        }
    }

    // The match array for this code, if it is a completed attempt
    var matches: [Match]? {
        switch kind {
        case .attempt(let matches): return matches
        default: return nil
        }
    }

    // Reset all pegs to missing while keeping the same word length
    mutating func reset() {
        pegs = Array(repeating: Code.missingPeg, count: pegs.count)
    }

    // MARK: - Matching Algorithm

    // Compare this code's pegs against another code using the standard two-pass approach:
    //   Pass 1 (backwards): identify all exact matches (same letter, same position)
    //   Pass 2: identify inexact matches (letter exists elsewhere in the remaining pool)
    // The backwards pass for exact matches correctly handles duplicate letters.
    func match(against otherCode: Code) -> [Match] {
        var pegsToMatch = otherCode.pegs

        // Pass 1 — exact matches (iterate backwards to allow safe in-place removal)
        let backwardsExactMatches = pegs.indices.reversed().map { index in
            if pegsToMatch.count > index, pegsToMatch[index] == pegs[index] {
                pegsToMatch.remove(at: index)
                return Match.exact
            } else {
                return Match.nomatch
            }
        }
        let exactMatches = Array(backwardsExactMatches.reversed())

        // Pass 2 — inexact matches for positions that were not exact
        return pegs.indices.map { index in
            if exactMatches[index] != .exact,
               let matchIndex = pegsToMatch.firstIndex(of: pegs[index]) {
                pegsToMatch.remove(at: matchIndex)
                return .inexact
            } else {
                return exactMatches[index]
            }
        }
    }
}
