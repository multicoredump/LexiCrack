//
//  WordView.swift
//  LexiCrack
//
//  Displays a row of LetterViews for a given Code.
//  - Guess code:    shows current letters with a selection highlight; tappable to move selection.
//  - Attempt code:  shows each letter colored by its match result (exact/inexact/nomatch).
//  - Master code:   shows hidden tiles until the game is won, then reveals the word.
//

import SwiftUI

struct WordView: View {
    // MARK: Data In
    let code: Code

    // MARK: Data Shared With Me
    // Pass .constant(-1) for non-guess codes so no tile appears selected.
    @Binding var selection: Int

    // MARK: - Body

    var body: some View {
        HStack(spacing: 6) {
            ForEach(code.pegs.indices, id: \.self) { index in
                LetterView(
                    peg: code.pegs[index],
                    match: code.matches?[index],
                    isSelected: code.kind == .guess && selection == index,
                    isHidden: code.isHidden
                )
                .onTapGesture {
                    // Only the active guess lets the player move the selection by tapping
                    if code.kind == .guess {
                        selection = index
                    }
                }
            }
        }
    }
}
