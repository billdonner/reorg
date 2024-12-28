import SwiftUI



// MARK: - ReplacementManager Extension on GameState
extension GameState {
    func decrementReplacementCount() -> Bool {
        guard gimmees  > 0 else { return false }
        gimmees -= 1
        return true
    }

    func resetReplacementCount() {
        gimmees = 5
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
let starting_size:Int = 4
let shouldAssert:Bool = true
let isDebugModeEnabled:Bool = true
let cloudKit:Bool = true
let cloudKitBypass = true
let debugBorderColor = Color.red 

let playDataURL  = Bundle.main.url(forResource: "playdata.json", withExtension: nil)

@main
struct QandAApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @AppStorage("OnboardingDone") private var onboardingdone = false
  @State var leaderboardService = LeaderboardService()
  @State var showOnboarding = false

  
  var body: some Scene {
    WindowGroup {
     let _ =  TSLog(">\(AppNameProvider.appName()) \(AppVersionProvider.appVersion()) running; Assertions:\(shouldAssert ? "ON":"OFF") Debug:\(isDebugModeEnabled ? "ON":"OFF") Cloudkit:\(!cloudKitBypass ? "ON":"OFF")")
      if !onboardingdone {
        OuterOnboardingView(isOnboardingComplete: $onboardingdone)
      }
      else {
        ContentView( )
          .debugBorder()
          .onAppear {
            ////conditionalAssert(gs.checkVsChaMan(chmgr: chmgr,message:"MainApp"))
            AppDelegate.lockOrientation(.portrait)// ensure applied
          }
      }
    }
  }
}

struct ContentView: View {
  // @State var chmgr = ChaMan(playData: PlayData.mock )
   @State var gameState = GameState(chmgr: ChaMan(playData: PlayData.mock ), size: starting_size,
                             topics:[:],
                             challenges:Challenge.mockChallenges)
    @State  var showAlert = false

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
                    onBackToGame: { withAnimation { gameState.currentView = .game } }
                )
            case .incorrect(let question):
                IncorrectlyAnsweredView(
                    question: question,
                    onBackToQandA: { withAnimation { gameState.currentView = .game } }
                )
            case .settings:
                SettingsView(
                    gameState: gameState,
                    onNewRound: { resetGame() }
                    //onIncrementReplacementCount: { gameState.replacementCount += 5 }
                )
            case .none:
              let _ = print ("ENDEND");EmptyView()
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



