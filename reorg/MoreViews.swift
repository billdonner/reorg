//
//  MoreViews.swift
//  reorg
//
//  Created by bill donner on 12/25/24.
//

import SwiftUI

// MARK: - YouLoseView
struct YouLoseView: View {
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

        LatinGunkView()
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

// MARK: - YouWinView
struct YouWinView: View {
    var onNewGame: () -> Void
    var onSettings: () -> Void

    @State private var titleOffset: CGFloat = UIScreen.main.bounds.height
    @State private var confettiOpacity: Double = 1.0
    @State private var confettiActive: Bool = true

    var body: some View {
        VStack(spacing: 20) {
            // Title Bar Animation
            HStack {
                Spacer()
                Text("🎉 You Win! 🎉")
                    .font(.largeTitle)
                    .bold()
                    .offset(y: titleOffset)
                    .animation(.easeOut(duration: 1.5), value: titleOffset)
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

            Divider()

            Text("Congratulations on completing the challenge!")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button("New Game", action: onNewGame)
                .buttonStyle(.borderedProminent)
                .padding()

            Spacer()

            // Confetti Animation
            ZStack {
                if confettiActive {
                    ForEach(0..<50) { _ in
                        Circle()
                            .fill(randomColor())
                            .frame(width: 20, height: 20)
                            .offset(x: CGFloat.random(in: -150...150), y: CGFloat.random(in: -300...300))
                            .opacity(confettiOpacity)
                    }
                }
            }
        }
        .onAppear {
            titleOffset = 0 // Animate title to rise to the top
            fadeOutConfetti() // Start confetti fade-out
        }
    }

    private func fadeOutConfetti() {
        withAnimation(.easeOut(duration: 20)) {
            confettiOpacity = 0 // Gradually fade out the confetti
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            confettiActive = false // Remove confetti entirely after fade-out
        }
    }

    private func randomColor() -> Color {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]
        return colors.randomElement() ?? .gray
    }
}
// MARK: - ThumbsUpView
struct ThumbsUpView: View {
  var onBackToQandA: () -> Void
  
  var body: some View {
    VStack(spacing: 20) {

      Divider()
      
      Text("You gave this a thumbs up!")
        .padding()
      
      Spacer()
      LatinGunkView()
    }
    .withTitleBar(title: "Thumbs Up", onDismiss: onBackToQandA)
    .background(Color(.systemBackground))
  }
}

// MARK: - ThumbsDownView
struct ThumbsDownView: View {
  var onBackToQandA: () -> Void
  var body: some View {
    VStack(spacing: 20) {
      
      Text("I'm giving this a thumbs down")
        .padding()
      
      Spacer()
      LatinGunkView()
    }
    .withTitleBar(title: "Thubs Down", onDismiss:onBackToQandA)
    .background(Color(.systemBackground))
  }
}

// MARK: - HintView
struct HintView: View {
  var onBackToQandA: () -> Void
  var body: some View {
    VStack(spacing: 20) {
      Text("Here's a helpful hint!")
        .padding()
    }
    .withTitleBar(title: "Hint", onDismiss: onBackToQandA)
  }
}
// MARK: - CorrectlyAnsweredView
struct CorrectlyAnsweredView: View {
    var question: String
    var onBackToQandA: () -> Void
  var body: some View {
        VStack(spacing: 0) {
            // Display the Question
            Text("You answered correctly: \(question)")
                .padding()
                .multilineTextAlignment(.center)

            Spacer()
        }
        .withTitleBar(title: "Answered Correctly", onDismiss: onBackToQandA)
        .background(Color(.systemBackground))
    }
}
#Preview {
  CorrectlyAnsweredView(question: "test question", onBackToQandA: {})
}
// MARK: - IncorrectlyAnsweredView
struct IncorrectlyAnsweredView: View {
    var question: String
    var onBackToQandA: () -> Void
    var body: some View {
        VStack(spacing: 0) {


            // Display the Question
            Text("You answered incorrectly: \(question)")
                .padding()
                .multilineTextAlignment(.center)

            Spacer()
        }
        .withTitleBar(title: "Answered Incorrectly", onDismiss: onBackToQandA)
        .background(Color(.systemBackground))
    
    }
}
#Preview {
  IncorrectlyAnsweredView(question: "test question", onBackToQandA: {})
}
// MARK: - FreePortView
struct FreePortView: View {
  var gameState: GameState
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Add 5 to Replacement Counter Button
            Button(action: {
                gameState.gimmees += 5
            }) {
                Text("Add 5 Replacements")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .withTitleBar(title: "FreePort", onDismiss: onDismiss)
        .background(Color(.systemBackground))
    }
}
// MARK: - ComingFromKwanduhView
struct ComingFromKwanduhView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("It will be the exact same for now.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .withTitleBar(title: "Coming from Kwanduh", onDismiss: onDismiss)
        .background(Color(.systemBackground))
    }
}
#Preview {
  ComingFromKwanduhView(){}
}
// MARK: - AppInfoFooterView

/// A small footer that displays the app’s name, version, and build,
/// using data from Info.plist (CFBundleName, CFBundleShortVersionString, CFBundleVersion).
struct AppInfoFooterView: View {
    // Grab values from Info.plist
    private let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown App"
    private let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0"
    private let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"

    var body: some View {
        Text("\(appName) v\(appVersion) (Build \(appBuild))")
            .font(.footnote)
            .foregroundColor(.primary)
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 1)
            )
            .padding(.bottom, 12)
    }
}
// MARK: - TitleBarModifier
struct TitleBarWithDismiss: ViewModifier {
    var title: String
    var onDismiss: () -> Void

    func body(content: Content) -> some View {
        VStack(spacing: 20) {
            // Top Bar
            HStack {
                Spacer()
                Text(title)
                    .font(.title)
                    .bold()
                Spacer()
              Button(action: onDismiss) {
                  Image(systemName: "xmark")
                      .font(.title)
                      .foregroundColor(.primary)
              }
              .padding(.trailing)
            }
            .padding(.top, 20)
            .padding(.bottom, 10)

            Divider()

            // Main Content
            content
        }
    }
}

extension View {
    func withTitleBar(title: String, onDismiss: @escaping () -> Void) -> some View {
        self.modifier(TitleBarWithDismiss(title: title, onDismiss: onDismiss))
    }
}
