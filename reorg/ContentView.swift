import SwiftUI


// MARK: - LatinGunkView
struct LatinGunkView: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 10) {
        Text("""
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras gravida tincidunt mi, nec scelerisque elit malesuada sit amet. Fusce et consectetur dolor. Etiam nec fermentum magna, nec accumsan mauris.
                    """)
        Text("""
                    Integer gravida felis id velit efficitur volutpat. Mauris sagittis, urna ut consectetur gravida, eros justo luctus eros, quis dapibus lectus risus quis urna. Proin non quam facilisis, mollis eros non, blandit quam.
                    """)
        Text("""
                    Nullam nec venenatis libero. Phasellus vel elit at magna cursus porttitor. Ut faucibus magna vel justo mollis volutpat. Vivamus fermentum eu urna sed vehicula. Curabitur consequat vestibulum nulla nec tempus.
                    """)
      }
      .padding()
    }
  }
}

// MARK: - ReplacementManager
@Observable
class ReplacementManager {
  var replacementCount: Int = 5
  
  func decrementReplacementCount() -> Bool {
    guard replacementCount > 0 else { return false }
    replacementCount -= 1
    return true
  }
  
  func reset() {
    replacementCount = 5
  }
}

// MARK: - Main App
@main
struct QandAApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
// MARK: - ContentView
struct ContentView: View {
    @State private var currentView: ViewState = .game
    @State private var showAlert = false
    @State private var gameID = UUID()
    private var replacementManager = ReplacementManager() // Replacement count initialized once

    enum ViewState {
        case game, qanda, youWin, youLose, correct, incorrect, settings
    }

    var body: some View {
        ZStack {
            switch currentView {
            case .game:
                MainGameView(
                    replacementManager: replacementManager, // Pass manager explicitly
                    onQandA: { withAnimation { currentView = .qanda } },
                    onSettings: { showAlert = true }
                )

            case .qanda:
                QandAView(
                    replacementManager: replacementManager, // Pass manager explicitly
                    onYouWin: { withAnimation { currentView = .youWin } },
                    onYouLose: { withAnimation { currentView = .youLose } },
                    onCorrect: { withAnimation { currentView = .correct } },
                    onIncorrect: { withAnimation { currentView = .incorrect } },
                    onBack: { withAnimation { currentView = .game } }
                )

            case .youWin:
                YouWinView(
                    onNewGame: { resetGame() },
                    onSettings: { withAnimation { currentView = .settings } }
                )

            case .youLose:
                YouLoseView(
                    onNewGame: { resetGame() },
                    onSettings: { withAnimation { currentView = .settings } }
                )

            case .correct:
                CorrectlyAnsweredView(
                    text: "You answered this question correctly!",
                    onBackToQandA: { withAnimation { currentView = .qanda } }
                )

            case .incorrect:
                IncorrectlyAnsweredView(
                    text: "You answered this question incorrectly!",
                    onBackToQandA: { withAnimation { currentView = .qanda } }
                )

            case .settings:
                SettingsView(
                    replacementManager: replacementManager, // Pass manager explicitly
                    onNewRound: { resetGame() }
                )
            }
        }
        .alert("End Current Game?", isPresented: $showAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Game") {
                withAnimation { currentView = .settings }
            }
        } message: {
            Text("Entering settings will end the current game.")
        }
    }

    private func resetGame() {
        gameID = UUID()
        withAnimation { currentView = .game }
        // Note: Replacement count is not reset here
    }
}
// MARK: - MainGameView
struct MainGameView: View {
    var replacementManager: ReplacementManager
    var onQandA: () -> Void
    var onSettings: () -> Void

    @State private var gridColors: [[Color]] = []

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
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

            Text("Replacements Left: \(replacementManager.replacementCount)")
                .font(.subheadline)
                .padding(.bottom)

            Button(action: onQandA) {
                VStack {
                    if gridColors.count == 4 && gridColors.allSatisfy({ $0.count == 4 }) {
                        ForEach(0..<4, id: \.self) { row in
                            HStack {
                                ForEach(0..<4, id: \.self) { col in
                                    Circle()
                                        .fill(gridColors[row][col])
                                        .frame(width: 40, height: 40)
                                }
                            }
                        }
                    } else {
                        Text("Loading Grid...")
                            .font(.headline)
                    }
                }
            }
            .buttonStyle(.plain)
            .padding()

            Spacer()
        }
        .onAppear {
            resetGridColors()
        }
    }

    private func resetGridColors() {
        gridColors = (0..<4).map { _ in
            (0..<4).map { _ in randomColor() }
        }
    }

    private func randomColor() -> Color {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]
        return colors.randomElement() ?? .gray
    }
}
// MARK: - QandAView
struct QandAView: View {
    @State private var showAlert = false
    @State private var question = "Here is the question to answer. (\(Date().formatted(date: .omitted, time: .standard)))"
    @State private var showThumbsUp = false
    @State private var showThumbsDown = false
    @State private var showHint = false
    @State private var isAnimatingReplacement = false
    @State private var answerCounter = 1 // Tracks the current label number for answers

    var replacementManager: ReplacementManager
    var onYouWin: () -> Void
    var onYouLose: () -> Void
    var onCorrect: () -> Void
    var onIncorrect: () -> Void
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Top Bar
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                .padding(.leading)

                Spacer()

                Text("Q&A Session")
                    .font(.title)
                    .bold()

                Spacer()
            }
            .padding(.top)

            // Replacement Count
            Text("Replacements Left: \(replacementManager.replacementCount)")
                .font(.subheadline)

            // Question
            Text(question)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .scaleEffect(isAnimatingReplacement ? 1.1 : 1.0) // Slight zoom-in effect
                .opacity(isAnimatingReplacement ? 0.5 : 1.0) // Fade-out during animation
                .animation(.easeInOut(duration: 0.5), value: isAnimatingReplacement)

            // Replace Button
            Button("Replace") {
                if !replacementManager.decrementReplacementCount() {
                    showAlert = true
                } else {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isAnimatingReplacement = true // Start the animation
                        question = "Here is a new question. (\(Date().formatted(date: .omitted, time: .standard)))"
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
                    ThumbsUpView(onBackToQandA: { showThumbsUp = false })
                }

                Button("👎 Thumbs Down") {
                    showThumbsDown = true
                }
                .buttonStyle(.bordered)
                .fullScreenCover(isPresented: $showThumbsDown) {
                    ThumbsDownView(onBackToQandA: { showThumbsDown = false })
                }
            }

            // Hint Button
            Button("Hint") {
                showHint = true
            }
            .buttonStyle(.borderedProminent)
            .fullScreenCover(isPresented: $showHint) {
                HintView(onBackToQandA: { showHint = false })
            }

            Spacer()
          // Answer Buttons with Monotonically Increasing Labels and New Prefixes
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
        .padding()
    }
}

// MARK: - SettingsView
struct SettingsView: View {
  var replacementManager: ReplacementManager
  var onNewRound: () -> Void
  @State var showComingFromKwanduh = false
  var body: some View {
    VStack(spacing: 20) {
      Text("Settings")
        .font(.largeTitle)
        .bold()
        .padding(.top)
      
      Text("Replacements Left: \(replacementManager.replacementCount)")
        .font(.subheadline)
      
      Button("Size") {showComingFromKwanduh = true}
        .buttonStyle(.borderedProminent)
      
      Button("Topics") { showComingFromKwanduh = true}
        .buttonStyle(.borderedProminent)
      
      Button("Colors") { showComingFromKwanduh = true}
        .buttonStyle(.borderedProminent)
      
      Button("Freeport") { replacementManager.replacementCount += 5}
        .buttonStyle(.borderedProminent)
      
      Button(action: onNewRound) {
        Text("Start New Round")
          .font(.title2)
          .bold()
          .frame(maxWidth: .infinity, minHeight: 60)
          .foregroundColor(.white)
          .background(Color.blue)
          .cornerRadius(10)
          .padding()
      }
    } .sheet(isPresented: $showComingFromKwanduh){
      ComingFromKwanduhView() {
        showComingFromKwanduh = false
      }
    }
  }
}
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
      HStack {
        Button(action: onBackToQandA) {
          Image(systemName: "arrow.left")
            .font(.title)
            .foregroundColor(.primary)
        }
        .padding(.leading)
        
        Spacer()
        
        Text("Thumbs Up")
          .font(.title)
          .bold()
        
        Spacer()
      }
      .padding(.top, 20)
      .padding(.bottom, 10)
      
      Divider()
      
      Text("You gave this a thumbs up!")
        .padding()
      
      Spacer()
      LatinGunkView()
    }
  }
}

// MARK: - ThumbsDownView
struct ThumbsDownView: View {
  var onBackToQandA: () -> Void
  
  var body: some View {
    VStack(spacing: 20) {
      HStack {
        Button(action: onBackToQandA) {
          Image(systemName: "arrow.left")
            .font(.title)
            .foregroundColor(.primary)
        }
        .padding(.leading)
        
        Spacer()
        
        Text("Thumbs Down")
          .font(.title)
          .bold()
        
        Spacer()
      }
      .padding(.top, 20)
      .padding(.bottom, 10)
      
      Divider()
      
      Text("You gave this a thumbs down!")
        .padding()
      
      Spacer()
      LatinGunkView()
    }
  }
}

// MARK: - HintView
struct HintView: View {
  var onBackToQandA: () -> Void
  
  var body: some View {
    VStack(spacing: 20) {
      HStack {
        Button(action: onBackToQandA) {
          Image(systemName: "arrow.left")
            .font(.title)
            .foregroundColor(.primary)
        }
        .padding(.leading)
        
        Spacer()
        
        Text("Hint")
          .font(.title)
          .bold()
        
        Spacer()
      }
      .padding(.top, 20)
      .padding(.bottom, 10)
      
      Divider()
      
      Text("Here's a helpful hint!")
        .padding()
      
      Spacer()
    }
  }
}
// MARK: - CorrectlyAnsweredView
struct CorrectlyAnsweredView: View {
  var text: String
  var onBackToQandA: () -> Void
  
  var body: some View {
    VStack(spacing: 0) {
      // Top Bar with Back Button
      HStack {
        Button(action: onBackToQandA) {
          Image(systemName: "arrow.left")
            .font(.title)
            .foregroundColor(.primary)
        }
        .padding(.leading)
        
        Spacer()
        
        Text("Correct Answer")
          .font(.title)
          .bold()
        
        Spacer()
      }
      .padding(.top, 20)
      .padding(.bottom, 10)
      
      Divider()
      
      // Scrollable Text
      ScrollView {
        Text(text)
          .padding()
      }
    }
    .background(Color(.systemBackground))
  }
}
// MARK: - IncorrectlyAnsweredView
struct IncorrectlyAnsweredView: View {
  var text: String
  var onBackToQandA: () -> Void
  
  var body: some View {
    VStack(spacing: 0) {
      // Top Bar with Back Button
      HStack {
        Button(action: onBackToQandA) {
          Image(systemName: "arrow.left")
            .font(.title)
            .foregroundColor(.primary)
        }
        .padding(.leading)
        
        Spacer()
        
        Text("Incorrect Answer")
          .font(.title)
          .bold()
        
        Spacer()
      }
      .padding(.top, 20)
      .padding(.bottom, 10)
      
      Divider()
      
      // Scrollable Text
      ScrollView {
        Text(text)
          .padding()
      }
    }
    .background(Color(.systemBackground))
  }
}

// MARK: - FreePortView
struct FreePortView: View {
  @Environment(ReplacementManager.self) private var replacementManager
  var onDismiss: () -> Void
  
  var body: some View {
    VStack(spacing: 20) {
      // Top Bar with Dismiss Button
      HStack {
        Button(action: onDismiss) {
          Image(systemName: "xmark")
            .font(.title)
            .foregroundColor(.primary)
        }
        .padding(.leading)
        
        Spacer()
        
        Text("FreePort")
          .font(.title)
          .bold()
        
        Spacer()
      }
      .padding(.top, 20)
      .padding(.bottom, 10)
      
      Divider()
      
      Spacer()
      
      // Add 5 to Replacement Counter Button
      Button(action: {
        replacementManager.replacementCount += 5
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
    .padding()
    .background(Color(.systemBackground))
  }
}
// MARK: - ComingFromKwanduhView
struct ComingFromKwanduhView: View {
  var onDismiss: () -> Void
  
  var body: some View {
    VStack(spacing: 20) {
      // Top Bar with Dismiss Button
      HStack {
        Button(action: onDismiss) {
          Image(systemName: "xmark")
            .font(.title)
            .foregroundColor(.primary)
        }
        .padding(.leading)
        
        Spacer()
        
        Text("Coming from Kwanduh")
          .font(.title)
          .bold()
        
        Spacer()
      }
      .padding(.top, 20)
      .padding(.bottom, 10)
      
      Divider()
      
      Spacer()
      
      Text("It will be the exact same for now.")
        .font(.body)
        .multilineTextAlignment(.center)
        .padding()
      
      Spacer()
    }
    .padding()
    .background(Color(.systemBackground))
  }
}
