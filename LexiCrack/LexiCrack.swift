//
//  LexiCrack.swift
//  LexiCrack
//
//  The game model for LexiCrack — a word-based CodeBreaker.
//  All codes (master and guesses) must be valid English words.
//  The master code word is chosen by the UI (via Words) and passed in here,
//  keeping word-fetching logic out of the model.
//

import Foundation

struct LexiCrack {
    var masterCode: Code          // the secret word the player is trying to crack
    var guess: Code               // the word the player is currently building
    var attempts: [Code] = []    // all submitted guesses with their match results

    // All 26 letters of the English alphabet — the full set of peg choices
    let pegChoices: [Peg] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }

    // The number of letters in the current game's word
    var wordLength: Int { masterCode.pegs.count }

    // MARK: - Initialization

    // Create a new game with the given master word.
    // The word is provided by the UI (from Words.random(length:)) so the model
    // does not need to import SwiftUI or access the Words environment directly.
    init(word: String) {
        masterCode = Code(kind: .master(isHidden: true), length: word.count)
        masterCode.word = word
        guess = Code(kind: .guess, length: word.count)
    }

    // MARK: - Game State

    // The game is over when the player's last attempt matches the master code exactly
    var isOver: Bool {
        attempts.last?.pegs == masterCode.pegs
    }

    // MARK: - Player Actions

    // Submit the current guess as an attempt.
    // Scores the guess against the master code and appends it to the attempt history.
    // Reveals the master code if the player has won.
    mutating func attemptGuess() {
        var attempt = guess
        attempt.kind = .attempt(guess.match(against: masterCode))
        attempts.append(attempt)
        guess.reset()
        if isOver {
            masterCode.kind = .master(isHidden: false)
        }
    }

    // Set a single letter peg in the current guess at the given position
    mutating func setGuessPeg(_ peg: Peg, at index: Int) {
        guard guess.pegs.indices.contains(index) else { return }
        guess.pegs[index] = peg
    }

    // MARK: - Restart

    // Start a fresh game with a new master word (same or different length)
    mutating func restart(word: String) {
        masterCode = Code(kind: .master(isHidden: true), length: word.count)
        masterCode.word = word
        guess = Code(kind: .guess, length: word.count)
        attempts = []
    }
}
