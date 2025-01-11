import SwiftUI


let plainTopicIndex = true
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
let isDebugModeEnabled:Bool = false
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
  @State var gs = GameState(chmgr: ChaMan(playData: PlayData.mock ), size: starting_size,
                            topics:[:],
                            challenges:Challenge.mockChallenges)
  @State  var showAlert = false
  @State var qarb:QARBOp? = nil
  @State var gimmeeAlert = false
  @State var current_size: Int = starting_size  //defined in mainapp
  @State var current_topics: [String: FreeportColor] = [:]
  
  fileprivate func loadAndSetupBoard(chmgr:ChaMan ) {
    chmgr.loadAllData(gs: gs)
    chmgr.checkAllTopicConsistency("ContentView onAppear0")
    current_size = gs.boardsize
    if gs.topicsinplay.count == 0 {
      gs.topicsinplay = colorize(
        scheme: gs.currentscheme,
        topics: getRandomTopics(
          GameState.preselectedTopicsForBoardSize(current_size),
          from: chmgr.everyTopicName))
      gs.topicsinorder = gs.topicsinplay.keys.sorted()
    }
  }
  
  var body: some View {
    ZStack {
      switch gs.currentView {
      case .game:
        MainGameView(
          gs: gs, // Pass replacement count,
          chmgr:gs.chmgr!, topics: $current_topics,
          onQandA: { challenge in
            withAnimation {
              gs.currentView = .qanda(challenge)
            }
          },
          onSettings: { showAlert = true }
        )
      case .qanda(let challenge):
        if let chmgr = gs.chmgr {
          QandAScreen(gs:$gs,chmgr: chmgr, ch: challenge, row:0,col:0,
                      qarb:$qarb,
                      onYouWin: { withAnimation { gs.currentView = .youWin } },
                      onYouLose: { withAnimation { gs.currentView = .youLose } },
                      onCorrect: { withAnimation { gs.currentView = .correct(challenge) } },
                      onIncorrect: { withAnimation { gs.currentView = .incorrect(challenge) } },
                      onBack: { withAnimation { gs.currentView = .game } }
          )
        }
      case .youWin:
        YouWinView(
          onNewGame: { resetGame() },
          onSettings: { withAnimation { gs.currentView = .settings } }
        )
      case .youLose:
        YouLoseView(
          onNewGame: { resetGame() },
          onSettings: { withAnimation { gs.currentView = .settings } }
        )
      case .correct(let challenge):
        CorrectlyAnsweredView(
          challenge: challenge,
          onBackToGame: { withAnimation { gs.currentView = .game } }
        )
      case .incorrect(let challenge):
        IncorrectlyAnsweredView(
          challenge: challenge,
          onBackToQandA: { withAnimation { gs.currentView = .game } }
        )
      case .settings:
        if let chmgr = gs.chmgr {
          SettingsView(
            gameState: $gs,chmgr:chmgr,
            onNewRound: { resetGame() }
            //onIncrementReplacementCount: { gameState.replacementCount += 5 }
          )
        }
      case .none:
        let _ = print ("ENDEND");EmptyView()
      }
    }
    .alert("End Current Game?", isPresented: $showAlert) {
      Button("Cancel", role: .cancel) { }
      Button("End Game") { withAnimation { gs.currentView = ViewState.settings } }
    } message: {
      Text("Entering settings will end the current game.")
    }
    .onChange(of:qarb){ old,new  in
      if let qarb = new {
        print("--Qarb is now \(qarb.description())")
      } else {
        print("--Qarb is nil")
      }
    }
    .onAppear {
      if gs.veryfirstgame {
        loadAndSetupBoard(chmgr: gs.chmgr!)
        if gs.gimmees == 0 {gimmeeAlert = true}
        current_topics = gs.topicsinplay
        gs.chmgr?.checkAllTopicConsistency("ContentView onAppear2")
        startTheGame(boardsize: current_size)
        
      }
      
      TSLog(
                """
                //ContentView  size:\(current_size) topics:\(gs.topicsinplay.count)     alloc:\(gs.chmgr!.allocatedChallengesCount()) free:\(gs.chmgr!.freeChallengesCount())
                  gamestate:\(gs.playstate)
       """
      )
      gs.veryfirstgame = false
      gs.saveGameState()
    }
  }
  
  private func resetGame() {
    gs.currentView = ViewState.game
    gs.board = Array(repeating: Array(repeating: 0, count: 5), count: 5) // Reset board
    gs.resetReplacementCount() // Reset replacements
  }
  
  func startTheGame(boardsize: Int) -> Bool {
    print("startTheGame gamestate is \(gs.playstate)")
    if gs.playstate == .playingNow {
      gs.teardownAfterGame(state: .justAbandoned, chmgr: gs.chmgr!)
    }
    //resetAlerts()
    //isTouching = false  // Turn off overlay
    let ok = gs.setupForNewGame(boardsize: boardsize, chmgr: gs.chmgr!)
    if !ok {
      print(
        "Failed to allocate \(boardsize * boardsize) challenges for topics \(gs.topicsinplay.keys.joined(separator: ","))"
      )
      print("Consider changing the topics in settings and trying again ...")
      //activeAlert = .cantStart
    } else {
    // all good, reset movenumber
      gs.movenumber = 0
      TSLog("--->NEW GAME STARTED")
    }
    return ok
  }

  func endGame(status: StateOfPlay) {
   // isTouching = false  // Turn off overlay
    gs.chmgr?.checkAllTopicConsistency("end game")
    gs.teardownAfterGame(state: status, chmgr: gs.chmgr!)
    let _ = gs.saveGameStateToFile()
  }
}



