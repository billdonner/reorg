import SwiftUI


let plainTopicIndex = true



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
  @State var gimmeeAlert = false
  @State var current_size: Int = starting_size  //defined in mainapp
  @State var current_topics: [String: FreeportColor] = [:]
  
  @State var row = 0
  @State var col = 0
  
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
              gs.currentView = .qanda(row,col )
            }
          },
          onSettings: { showAlert = true }
        )
        
      case .qanda(let row,let col):
        if let chmgr = gs.chmgr {
          QandAScreen(gs:$gs,chmgr: chmgr, row:row,col:col ,
                      onYouWin: { withAnimation { gs.currentView = .youWin(row,col) } },
                      onYouLose: { withAnimation { gs.currentView = .youLose(row,col ) } },
                      onCorrect: { withAnimation { gs.currentView = .correct(row,col) } },
                      onIncorrect: { withAnimation { gs.currentView = .incorrect(row,col) } },
                      onBack: { withAnimation { gs.currentView = .game } }
          )
        }
      case .youWin:
        YouWinView(
          onNewGame: {  gs.woncount+=1 ; endGame(status: .justWon) ; resetGame() },
          onSettings: { withAnimation {  gs.currentView = .settings } }
        )
      case .youLose:
        YouLoseView(
          onNewGame: {  gs.lostcount+=1 ;   endGame(status: .justLost) ; resetGame() },
          onSettings: { withAnimation { gs.currentView = .settings } }
        )
      case .correct(let row,let col):
        CorrectlyAnsweredView(
          gs:gs,row:row,col:col,
          onBackToQandA: { withAnimation { gs.currentView = .game } }
        )
      case .incorrect(let row,let col ):
        IncorrectlyAnsweredView(
          gs:gs,row:row,col:col,
          onBackToQandA: { withAnimation { gs.currentView = .game } }
        )
      case .settings:
        if let chmgr = gs.chmgr {
          SettingsView(
            gameState: $gs,chmgr:chmgr,
            onNewRound: {  resetGame(); }
            //onIncrementReplacementCount: { gameState.replacementCount += 5 }
          )
        }
      case .none:
        let _ = print ("ENDEND");EmptyView()
      }
    }

      .alert("End Current Game?", isPresented: $showAlert) {
        Button("Cancel", role: .cancel) { }
        Button("End Game") { withAnimation {
          endGame(status: .justAbandoned)
          gs.currentView = ViewState.settings  }
        }
      }
      message: {
      Text("Entering settings will end the current game.")
    }
    .onAppear {
      if gs.veryfirstgame {
        loadAndSetupBoard(chmgr: gs.chmgr!)
        if gs.gimmees == 0 {gimmeeAlert = true}
        current_topics = gs.topicsinplay
        gs.chmgr?.checkAllTopicConsistency("ContentView onAppear2")
        let ok = startTheGame(boardsize: current_size)
        if !ok {
          print("Cant start game!!!!")
        }
        
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
    gs.resetReplacementCount() // Reset replacements
    let ok =  startTheGame(boardsize: gs.boardsize)
    if !ok {
      print("Could not start game !!!!!!!!")
    }
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



