//
//  QwertyKeyboard.swift
//  LexiCrack
//
//  A standard QWERTY keyboard for entering letter guesses.
//  Row 3 includes Enter (submit guess) and Delete (backspace) action keys.
//  The keyboard's overall aspect ratio is fixed at 10:3 (width of top row : number of rows)
//  so SwiftUI can size it consistently regardless of the screen width.
//

import SwiftUI

struct QwertyKeyboard: View {
    // MARK: Data Out Functions
    var onChoose: ((Peg) -> Void)?   // called when a letter key is tapped
    var onEnter:  (() -> Void)?      // called when the Enter key is tapped
    var onDelete: (() -> Void)?      // called when the Delete key is tapped

    private let topRow:    [Peg] = ["Q","W","E","R","T","Y","U","I","O","P"]
    private let middleRow: [Peg] = ["A","S","D","F","G","H","J","K","L"]
    private let bottomRow: [Peg] = ["Z","X","C","V","B","N","M"]

    // MARK: - Body

    var body: some View {
        VStack(spacing: 4) {
            letterRow(topRow)
            letterRow(middleRow)
            // Bottom row: Enter | letters | Delete
            HStack(spacing: 4) {
                actionKey("Enter") { onEnter?() }
                letterRow(bottomRow)
                actionKey("Del") { onDelete?() }
            }
        }
        // Lock the keyboard to a 10:3 aspect ratio (10 keys wide, 3 rows tall)
        .aspectRatio(CGFloat(topRow.count) / 3, contentMode: .fit)
    }

    // MARK: - Key Builders

    // A row of equally-sized letter keys
    @ViewBuilder
    private func letterRow(_ letters: [Peg]) -> some View {
        HStack(spacing: 4) {
            ForEach(letters, id: \.self) { letter in
                letterKey(letter)
            }
        }
    }

    // A single letter key
    private func letterKey(_ letter: Peg) -> some View {
        Button {
            onChoose?(letter)
        } label: {
            Text(letter)
                .font(.headline.bold())
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(Color.secondary.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .foregroundStyle(.primary)
    }

    // An action key (Enter / Delete) — slightly wider than a letter key
    private func actionKey(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption.bold())
                .frame(maxWidth: .infinity)
                .aspectRatio(1.5, contentMode: .fit)
                .background(Color.secondary.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    QwertyKeyboard(
        onChoose: { print("Letter: \($0)") },
        onEnter:  { print("Enter") },
        onDelete: { print("Delete") }
    )
    .padding()
}
