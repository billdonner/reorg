import SwiftUI

enum ViewState: Codable {
    case game
    case qanda(String)
    case youWin
    case youLose
    case correct(String)
    case incorrect(String)
    case settings

    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    private enum CaseType: String, Codable {
        case game
        case qanda
        case youWin
        case youLose
        case correct
        case incorrect
        case settings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CaseType.self, forKey: .type)

        switch type {
        case .game:
            self = .game
        case .qanda:
            let value = try container.decode(String.self, forKey: .value)
            self = .qanda(value)
        case .youWin:
            self = .youWin
        case .youLose:
            self = .youLose
        case .correct:
            let value = try container.decode(String.self, forKey: .value)
            self = .correct(value)
        case .incorrect:
            let value = try container.decode(String.self, forKey: .value)
            self = .incorrect(value)
        case .settings:
            self = .settings
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .game:
            try container.encode(CaseType.game, forKey: .type)
        case .qanda(let value):
            try container.encode(CaseType.qanda, forKey: .type)
            try container.encode(value, forKey: .value)
        case .youWin:
            try container.encode(CaseType.youWin, forKey: .type)
        case .youLose:
            try container.encode(CaseType.youLose, forKey: .type)
        case .correct(let value):
            try container.encode(CaseType.correct, forKey: .type)
            try container.encode(value, forKey: .value)
        case .incorrect(let value):
            try container.encode(CaseType.incorrect, forKey: .type)
            try container.encode(value, forKey: .value)
        case .settings:
            try container.encode(CaseType.settings, forKey: .type)
        }
    }
}

// MARK: - GameState
@Observable
class GameState: Codable {
    var currentView: ViewState = .game
     var board: [[Int]] = []
    var replacementCount: Int = 5 // Replacement count is now part of GameState

    enum CodingKeys: String, CodingKey {
        case board
        case currentView
        case replacementCount
    }
  // Add this:
  init() {
      // You can customize defaults here
      currentView = .game
      board = []
      replacementCount = 5
  }
    // Codable conformance
  // Codable conformance
  required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.board = try container.decode([[Int]].self, forKey: .board)
      self.currentView = try container.decode(ViewState.self, forKey: .currentView)
      self.replacementCount = try container.decode(Int.self, forKey: .replacementCount)
  }
  
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(board, forKey: .board)
        try container.encode(currentView, forKey: .currentView)
        try container.encode(replacementCount, forKey: .replacementCount)
    }
}

// MARK: - ReplacementManager Extension on GameState
extension GameState {
    func decrementReplacementCount() -> Bool {
        guard replacementCount > 0 else { return false }
        replacementCount -= 1
        return true
    }

    func resetReplacementCount() {
        replacementCount = 5
    }
}
// MARK: - Questions Array
let questions = [
    "What is the largest land animal?",
    "What is the fastest bird?",
    "Which animal is known as the King of the Jungle?",
    "What color are flamingos?",
    "What is a baby kangaroo called?",
    "Which country produces the most wine?",
    "What is the main ingredient of red wine?",
    "What type of wine is Champagne?",
    "Which wine is best served chilled?",
    "What is a wine expert called?",
    "Who was the drummer for The Beatles?",
    "What year did The Beatles release 'Let It Be'?",
    "Which Beatle was known as the quiet one?",
    "What was The Beatles' first hit single?",
    "In what city did The Beatles form?",
    "What is the average lifespan of a tortoise?",
    "What type of whale has a long horn?",
    "What is the collective noun for a group of crows?",
    "What do pandas eat?",
    "What is the fastest aquatic animal?",
    "What type of wine comes from the Bordeaux region?",
    "Which Beatle wrote 'Hey Jude'?",
    "What is the Beatles' best-selling album?",
    "What type of wine is made from Sauvignon Blanc grapes?",
    "Which bird cannot fly but is the largest in the world?"
]
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


// MARK: - Main App
@main
struct QandAApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
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
struct ContentView: View {
    @State private var gameState = GameState()
    @State private var showAlert = false

    var body: some View {
        ZStack {
            switch gameState.currentView {
            case .game:
                MainGameView(
                  gameState: gameState, // Pass replacement count
                    onQandA: { question in
                        withAnimation {
                            gameState.currentView = .qanda(question)
                        }
                    },
                    onSettings: { showAlert = true }
                )
            case .qanda(let question):
                QandAView(
                    question: question,
                    gameState: gameState, // Use GameState for replacement count
                    onYouWin: { withAnimation { gameState.currentView = .youWin } },
                    onYouLose: { withAnimation { gameState.currentView = .youLose } },
                    onCorrect: { withAnimation { gameState.currentView = .correct(question) } },
                    onIncorrect: { withAnimation { gameState.currentView = .incorrect(question) } },
                    onBack: { withAnimation { gameState.currentView = .game } }
                )
            case .youWin:
                YouWinView(
                    onNewGame: { resetGame() },
                    onSettings: { withAnimation { gameState.currentView = .settings } }
                )
            case .youLose:
                YouLoseView(
                    onNewGame: { resetGame() },
                    onSettings: { withAnimation { gameState.currentView = .settings } }
                )
            case .correct(let question):
                CorrectlyAnsweredView(
                    question: question,
                    onBackToQandA: { withAnimation { gameState.currentView = .qanda(question) } }
                )
            case .incorrect(let question):
                IncorrectlyAnsweredView(
                    question: question,
                    onBackToQandA: { withAnimation { gameState.currentView = .qanda(question) } }
                )
            case .settings:
                SettingsView(
                    gameState: gameState,
                    onNewRound: { resetGame() }
                    //onIncrementReplacementCount: { gameState.replacementCount += 5 }
                )
            }
        }
        .alert("End Current Game?", isPresented: $showAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Game") { withAnimation { gameState.currentView = ViewState.settings } }
        } message: {
            Text("Entering settings will end the current game.")
        }
    }

    private func resetGame() {
        gameState.currentView = ViewState.game
        gameState.board = Array(repeating: Array(repeating: 0, count: 5), count: 5) // Reset board
        gameState.resetReplacementCount() // Reset replacements
    }
}
// MARK: - MainGameView
struct MainGameView: View {
    var gameState: GameState
    var onQandA: (String) -> Void // Pass the selected question
    var onSettings: () -> Void

    private let gridColors: [Color] = [.red, .yellow, .blue] // Define the three colors

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

          Text("Replacements Left: \(gameState.replacementCount)")
                .font(.subheadline)
                .padding(.bottom)

            // Grid of Touchpoints with Three Colors
            VStack(spacing: 10) {
                ForEach(0..<5, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(0..<5, id: \.self) { col in
                            let questionIndex = row * 5 + col
                            Button(action: {
                                onQandA(questions[questionIndex])
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
// MARK: - QandAView
struct QandAView: View {
    @State private var showAlert = false
    @State private var currentQuestion: String
    @State private var questionTimestamp: String
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

    init(question: String, gameState: GameState, onYouWin: @escaping () -> Void, onYouLose: @escaping () -> Void, onCorrect: @escaping () -> Void, onIncorrect: @escaping () -> Void, onBack: @escaping () -> Void) {
        self._currentQuestion = State(initialValue: question)
        self._questionTimestamp = State(initialValue: Date().formatted(date: .omitted, time: .standard))
        self.gameState = gameState
        self.onYouWin = onYouWin
        self.onYouLose = onYouLose
        self.onCorrect = onCorrect
        self.onIncorrect = onIncorrect
        self.onBack = onBack
    }

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
            Text("Replacements Left: \(gameState.replacementCount)")
                .font(.subheadline)

            // Current Question
            Text("\(currentQuestion) (\(questionTimestamp))")
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
                        questionTimestamp = Date().formatted(date: .omitted, time: .standard)
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
        .padding()
    }
}
// MARK: - SettingsView
struct SettingsView: View {
  var gameState: GameState
  var onNewRound: () -> Void
  @State var showComingFromKwanduh = false
  var body: some View {
    VStack(spacing: 20) {
      Text("Settings")
        .font(.largeTitle)
        .bold()
        .padding(.top)
      
      Text("Replacements Left: \(gameState.replacementCount)")
        .font(.subheadline)
      
      Button("Size") {showComingFromKwanduh = true}
        .buttonStyle(.borderedProminent)
      
      Button("Topics") { showComingFromKwanduh = true}
        .buttonStyle(.borderedProminent)
      
      Button("Colors") { showComingFromKwanduh = true}
        .buttonStyle(.borderedProminent)
      
      Button("Freeport") { gameState.replacementCount += 5}
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
      
      
      // ---- Here’s your new footer at the bottom ----
      AppInfoFooterView()
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
                gameState.replacementCount += 5
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
