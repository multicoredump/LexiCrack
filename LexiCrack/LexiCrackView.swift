//
//  LexiCrackView.swift
//  LexiCrack
//
//  The main game view. Owns the game model and drives all player interactions.
//  Layout (top to bottom):
//    - Header: title + New Game button
//    - Master code (hidden until the game is won)
//    - Scrollable attempt history (newest at top) + current guess row
//    - QWERTY keyboard
//

import SwiftUI

struct LexiCrackView: View {
    // MARK: Data From Environment
    @Environment(\.words) var words

    // MARK: Data Owned by Me
    @State private var game = LexiCrack(word: "AWAIT")  // replaced once Words loads
    @State private var selection: Int = 0
    @State private var wordLength: Int = 5
    @State private var checker = UITextChecker()

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            header
            WordView(code: game.masterCode, selection: .constant(-1))
                .padding(.horizontal)
            attemptScroll
            QwertyKeyboard(
                onChoose: chooseLetter,
                onEnter: submitGuess,
                onDelete: deleteLetter
            )
            .padding(.horizontal)
        }
        .padding(.vertical)
        // Set initial master word when the view appears, and again when Words finishes loading.
        // If words haven't loaded yet, the placeholder "AWAIT" is used.
        .onChange(of: words.count, initial: true) {
            if game.attempts.isEmpty {
                game = LexiCrack(word: newMasterWord())
                selection = 0
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            Text("LexiCrack")
                .font(.largeTitle.bold())
            Spacer()
            Button("New Game") {
                game = LexiCrack(word: newMasterWord())
                selection = 0
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
    }

    private var attemptScroll: some View {
        ScrollView {
            VStack(spacing: 6) {
                // Show the active guess row while the game is still in progress
                if !game.isOver {
                    WordView(code: game.guess, selection: $selection)
                        .padding(.horizontal)
                }
                // Previous attempts shown newest-first
                ForEach(game.attempts.indices.reversed(), id: \.self) { index in
                    WordView(code: game.attempts[index], selection: .constant(-1))
                        .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Player Actions

    // Called when the player taps a letter key
    private func chooseLetter(_ peg: Peg) {
        game.setGuessPeg(peg, at: selection)
        // Advance selection, wrapping back to the start after the last position
        selection = (selection + 1) % game.wordLength
    }

    // Called when the player taps Enter — validates and submits the current guess
    private func submitGuess() {
        let word = game.guess.word.lowercased()
        guard word.count == game.wordLength,
              !game.guess.pegs.contains(Code.missingPeg),
              checker.isAWord(word) else { return }
        game.attemptGuess()
        selection = 0
    }

    // Called when the player taps Delete — moves selection back and clears that letter
    private func deleteLetter() {
        selection = max(selection - 1, 0)
        game.setGuessPeg(Code.missingPeg, at: selection)
    }

    // MARK: - Word Selection

    // Returns a random word of the current length from the loaded dictionary,
    // falling back to a placeholder if words haven't loaded yet.
    private func newMasterWord() -> String {
        words.count == 0
            ? "AWAIT"
            : (words.random(length: wordLength) ?? "ERROR")
    }
}

#Preview {
    LexiCrackView()
}
