//
//  MainGameView.swift
//  reorg
//
//  Created by bill donner on 12/25/24.
//

import SwiftUI
// MARK: - MainGameView
struct MainGameView: View {
    var gameState: GameState
    var onQandA: (Challenge) -> Void // Pass the selected question
    var onSettings: () -> Void

    private let gridColors: [Color] = [.red, .yellow, .blue] // Define the three colors

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Live Game Running")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button(action: onSettings) {
                    Image(systemName: "gear")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                .padding(.trailing)
            }
            .padding(.top)

          Text("Replacements Left: \(gameState.gimmees)")
                .font(.subheadline)
                .padding(.bottom)

            // Grid of Touchpoints with Three Colors
            VStack(spacing: 10) {
                ForEach(0..<5, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(0..<5, id: \.self) { col in
                            //let questionIndex = row * 5 + col
                            Button(action: {
                              onQandA(Challenge.amock )
                            }) {
                                Circle()
                                    .fill(randomGridColor())
                                    .frame(width: 50, height: 50)
                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
    }

    private func randomGridColor() -> Color {
        gridColors.randomElement() ?? .gray // Randomly pick one of the defined colors
    }
}
