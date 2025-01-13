//
//  YouLoseView.swift
//  reorg
//
//  Created by bill donner on 1/13/25.
//
import SwiftUI

// MARK: - YouLoseView
struct YouLoseView: View {
  let ch:Challenge
var onNewGame: () -> Void
var onSettings: () -> Void

@State private var titleOffset: CGFloat = -UIScreen.main.bounds.height
@State private var animationCompleted = false

var body: some View {
    VStack(spacing: 20) {
        // Title Bar Animation
        HStack {
            Spacer()
            Text("😢 You Lose 😢")
                .font(.largeTitle)
                .bold()
                .offset(y: titleOffset)
                .opacity(animationCompleted ? 1 : 0) // Ensure title fades in
            Spacer()
            Button(action: onSettings) {
                Image(systemName: "gear")
                    .font(.title)
                    .foregroundColor(.primary)
            }
            .padding(.trailing)
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
        .onAppear {
            startBounceAnimation()
        }

        Divider()

        Text("Don't worry, try again and you'll do better!")
            .multilineTextAlignment(.center)
            .padding(.horizontal)

        Spacer()

        Button("New Game", action: onNewGame)
            .buttonStyle(.borderedProminent)
            .padding()

        Spacer()

      VStack(spacing: 0) {
          // Display the Question
        Text("You answered incorrectly:").font(.subheadline)
        Spacer()
             Text( "\(ch.question)")
              .padding()
              .multilineTextAlignment(.center)
        Spacer()
        Text("The correct answer was:")
             Text( "\(ch.correct )")
              .padding()
              .multilineTextAlignment(.center)
          Spacer()
      }
    }
}

private func startBounceAnimation() {
    withAnimation(.easeInOut(duration: 0.8)) {
        titleOffset = UIScreen.main.bounds.height * 0.3 // Bounce to the bottom
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0)) {
            titleOffset = 0 // Return to the top
            animationCompleted = true // Ensure the title is fully visible
        }
    }
}
}
#Preview {
  YouLoseView(ch: Challenge.amock, onNewGame: {}, onSettings: {})
}
