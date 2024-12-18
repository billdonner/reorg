import SwiftUI
import Observation
 

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
    @State private var gameID = UUID() // Resets the game grid
    var replacementManager = ReplacementManager()

    enum ViewState {
        case game, qanda, youWin, youLose, settings
    }

    var body: some View {
        ZStack {
            switch currentView {
            case .game:
                MainGameView(
                    onQandA: { withAnimation { currentView = .qanda } },
                    onSettings: { showAlert = true }
                )
                .environment(replacementManager)

            case .qanda:
                QandAView(
                    onYouWin: { withAnimation { currentView = .youWin } },
                    onYouLose: { withAnimation { currentView = .youLose } },
                    onBack: { withAnimation { currentView = .game } }
                )
                .environment(replacementManager)

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

            case .settings:
                SettingsView(
                    onNewRound: { resetGame() }
                )
                .environment(replacementManager)
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
      replacementManager.reset()
  }
}
// MARK: - MainGameView
struct MainGameView: View {
    @Environment(ReplacementManager.self) private var replacementManager
    var onQandA: () -> Void
    var onSettings: () -> Void

    @State private var gridColors: [[Color]] = []

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Text("Game Board")
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
    @Environment(ReplacementManager.self) private var replacementManager
    @State private var showAlert = false
    @State private var question = "Here is the question to answer. (\(Date().formatted(date: .omitted, time: .standard)))"
    @State private var showThumbsUp = false
    @State private var showThumbsDown = false
    @State private var showHint = false

    var onYouWin: () -> Void
    var onYouLose: () -> Void
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

            // Replace Button
            Button("Replace") {
                if !replacementManager.decrementReplacementCount() {
                    showAlert = true
                } else {
                    question = "Here is a new question. (\(Date().formatted(date: .omitted, time: .standard)))"
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

            // Answer Buttons
            VStack(spacing: 10) {
                ForEach(1...4, id: \.self) { index in
                    Button("Answer \(index)") {
                        handleAnswerTap()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
    }

    private func handleAnswerTap() {
        let outcome = Double.random(in: 0...1)
        if outcome <= 0.3 {
            onYouWin()
        } else if outcome <= 0.6 {
            onYouLose()
        } else {
            // Future explain logic can go here
        }
    }
}

// MARK: - SettingsView
struct SettingsView: View {
    @Environment(ReplacementManager.self) private var replacementManager
    var onNewRound: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            Text("Replacements Left: \(replacementManager.replacementCount)")
                .font(.subheadline)

            Button("Size") { /* Add navigation logic */ }
                .buttonStyle(.borderedProminent)

            Button("Topics") { /* Add navigation logic */ }
                .buttonStyle(.borderedProminent)

            Button("Colors") { /* Add navigation logic */ }
                .buttonStyle(.borderedProminent)

            Button("Freeport") { /* Add navigation logic */ }
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
        }
    }
}
// MARK: - YouWinView
struct YouWinView: View {
    var onNewGame: () -> Void
    var onSettings: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Top Bar with Gear Button
            HStack {
                Spacer()
                
                Text("🎉 You Win! 🎉")
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
          LatinGunkView()
        }
    }
}
// MARK: - YouLoseView
struct YouLoseView: View {
    var onNewGame: () -> Void
    var onSettings: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Top Bar with Gear Button
            HStack {
                Spacer()
                
                Text("😢 You Lose 😢")
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
            .padding(.top, 20)
            .padding(.bottom, 10)
            
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
}
// MARK: - ExplainView
struct ExplainView: View {
    var text: String
    var onBackToQandA: () -> Void // Explicit function to ensure clean transition

  var body: some View {
        VStack(spacing: 0) {
            // Top Bar with Back Button
            HStack {
                Button(action: onBackToQandA) { // Directly transitions back to Q&A
                    Image(systemName: "arrow.left")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                .padding(.leading)
                
                Spacer()
                
                Text("Explain")
                    .font(.title)
                    .bold()
                
                Spacer()
            }
            .padding(.top, 20) // Spacing at the top
            .padding(.bottom, 10) // Spacing under the header
            
            Divider()
          LatinGunkView()
        }
        .background(Color(.systemBackground))
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
