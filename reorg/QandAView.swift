//
//  QandAView.swift
//  reorg
//
//  Created by bill donner on 12/25/24.
//

import SwiftUI
// MARK: - QandAView
struct QandAView: View {
    @State private var showAlert = false
    @State private var currentChallenge: Challenge
    @State private var showThumbsUp = false
    @State private var showThumbsDown = false
    @State private var showHint = false
    @State private var isAnimatingReplacement = false
    @State private var answerCounter = 1 // Tracks the current label number for answers

    var gameState: GameState
    var onYouWin: () -> Void
    var onYouLose: () -> Void
    var onCorrect: () -> Void
    var onIncorrect: () -> Void
    var onBack: () -> Void

    init(challenge: Challenge, gameState: GameState, onYouWin: @escaping () -> Void, onYouLose: @escaping () -> Void, onCorrect: @escaping () -> Void, onIncorrect: @escaping () -> Void, onBack: @escaping () -> Void) {
        self._currentChallenge = State(initialValue: challenge)
        self.gameState = gameState
        self.onYouWin = onYouWin
        self.onYouLose = onYouLose
        self.onCorrect = onCorrect
        self.onIncorrect = onIncorrect
        self.onBack = onBack
    }

    var body: some View {
        VStack(spacing: 20) {

            // Replacement Count
          Text("Replacements Left: \(gameState.gimmees)")
                .font(.subheadline)

            // Current Question
          Text("\(currentChallenge.question) (\(currentChallenge.date))")
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .scaleEffect(isAnimatingReplacement ? 1.1 : 1.0) // Slight zoom-in effect
                .opacity(isAnimatingReplacement ? 0.5 : 1.0) // Fade-out during animation
                .animation(.easeInOut(duration: 0.5), value: isAnimatingReplacement)

            // Replace Button
            Button("Replace") {
                if !gameState.decrementReplacementCount() {
                    showAlert = true
                } else {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isAnimatingReplacement = true // Start the animation
                     
                        answerCounter += 1 // Increment the counter for new labels
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isAnimatingReplacement = false // End the animation after a short delay
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .alert("No Replacements Left", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }

            // Thumbs Up and Thumbs Down Buttons
            HStack(spacing: 20) {
                Button("👍 Thumbs Up") {
                    showThumbsUp = true
                }
                .buttonStyle(.bordered)
                .fullScreenCover(isPresented: $showThumbsUp) {
                  ThumbsUpView (ch:currentChallenge, onBackToQandA: { showThumbsUp = false })
                }

                Button("👎 Thumbs Down") {
                    showThumbsDown = true
                }
                .buttonStyle(.bordered)
                .fullScreenCover(isPresented: $showThumbsDown) {
                  ThumbsDownView(ch:currentChallenge, onBackToQandA: { showThumbsDown = false })
                }
            }

            // Hint Button
            Button("Hint") {
                showHint = true
            }
            .buttonStyle(.borderedProminent)
            .fullScreenCover(isPresented: $showHint) {
              HintView(ch:currentChallenge,onBackToQandA: { showHint = false })
            }

            Spacer()

            // Answer Buttons
            VStack(spacing: 10) {
                Button("Correct \(answerCounter)-1") {
                    onCorrect()
                }
                .buttonStyle(.borderedProminent)

                Button("Wrong \(answerCounter)-2") {
                    onIncorrect()
                }
                .buttonStyle(.borderedProminent)

                Button("YouWin \(answerCounter)-3") {
                    onYouWin()
                }
                .buttonStyle(.borderedProminent)

                Button("YouLose \(answerCounter)-4") {
                    onYouLose()
                }
                .buttonStyle(.borderedProminent)
            }
        }
       
           .padding(.top)
           .withTitleBar(title: "Q&A Session", onDismiss: onBack)
           .background(Color(.systemBackground))

        .padding()
    }
}
