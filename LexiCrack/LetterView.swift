//
//  LetterView.swift
//  LexiCrack
//
//  Displays a single letter tile. Background color reflects the match state:
//    green  = exact   (right letter, right position)
//    yellow = inexact (right letter, wrong position)
//    gray   = nomatch (letter not in the word)
//    clear  = unfilled guess position (outlined square)
//

import SwiftUI

struct LetterView: View {
    // MARK: Data In
    let peg: Peg              // the letter to display ("" if slot is empty)
    var match: Match? = nil   // nil for guess/master tiles; set for submitted attempts
    var isSelected: Bool = false  // highlights the active input position in the guess
    var isHidden: Bool = false    // true for the master code before the game is won

    private let shape = RoundedRectangle(cornerRadius: 4)

    // MARK: - Body

    var body: some View {
        shape
            .fill(backgroundColor)
            .overlay {
                // Show a border only on unfilled tiles (guess positions have no background color)
                if match == nil && !isHidden {
                    shape.strokeBorder(borderColor, lineWidth: isSelected ? 3 : 2)
                }
            }
            .overlay {
                if !isHidden {
                    Text(peg)
                        .font(.title.bold())
                        .foregroundStyle(textColor)
                }
            }
            .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Appearance

    private var backgroundColor: Color {
        if isHidden { return Color(white: 0.5) }
        switch match {
        case .exact:   return Color.green
        case .inexact: return Color(hue: 0.14, saturation: 0.85, brightness: 0.9) // amber
        case .nomatch: return Color(white: 0.4)
        case nil:      return .clear
        }
    }

    // The border is accent-colored when the slot is selected, light gray otherwise
    private var borderColor: Color {
        isSelected ? .accentColor : Color(white: 0.65)
    }

    // Letters on colored tiles are white; unsubmitted guess letters use the default text color
    private var textColor: Color {
        match != nil ? .white : .primary
    }
}

#Preview {
    HStack {
        LetterView(peg: "C", match: .exact)
        LetterView(peg: "R", match: .inexact)
        LetterView(peg: "A", match: .nomatch)
        LetterView(peg: "N", isSelected: true)
        LetterView(peg: "")
    }
    .padding()
}
