import SwiftUI

typealias ColorSchemeName = Int

/// High-level states of the game lifecycle
enum StateOfPlay: Int, Codable {
    case initializingApp, playingNow, justLost, justWon, justAbandoned
}
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


/// Represents the state of a game cell
/// - playedCorrectly: The cell was played successfully.
/// - playedIncorrectly: The cell was played but incorrectly.
/// - unplayed: The cell has not yet been interacted with.
/// - blocked: The cell is unavailable for interaction.
enum GameCellState: Codable {
    case playedCorrectly, playedIncorrectly, unplayed, blocked
    var borderColor: Color {
        switch self {
        case .playedCorrectly: return .green
        case .playedIncorrectly: return .red
        case .unplayed: return .gray
        case .blocked: return Color.gray.opacity(0.5)
        }
    }
}
/// Represents a position in the matrix and a move number
struct GameMove: Codable, Hashable {
  let row: Int
  let col: Int
  let movenumber: Int
}

/// Represents a position in the matrix
struct Coordinate: Hashable {
    let row: Int
    let col: Int
}

enum CornerPosition: CaseIterable {
    case topLeft, topRight, bottomLeft, bottomRight
}


/// Represents a point in the matrix with additional status information
struct IdentifiablePoint: Identifiable {
    let id = UUID()
    let row: Int
    let col: Int
    let status: ChallengeStatus?
}

// MARK: - Colors

/// RGB representation for custom colors
/// Used exclusively for theming within the app.
struct RGB: Codable {
    let red: Double
    let green: Double
    let blue: Double
}

// MARK: - Data Models

/// Represents basic information about a topic
struct BasicTopic: Codable {
    public var name: String
    public var subject: String
    public var pic: String
    public var notes: String
    public var subtopics: [String]
    public init(name: String, subject: String = "", pic: String = "", notes: String = "", subtopics: [String] = []) {
        self.name = name
        self.subject = subject
        self.pic = pic
        self.notes = notes
        self.subtopics = subtopics
    }
}

/// Contains detailed statistics and indices for a topic
struct TopicInfo: Codable {
    let name: String
    var alloccount: Int
    var freecount: Int
    var replacedcount: Int
    var rightcount: Int
    var wrongcount: Int
    var challengeIndices: [Int] // Indexes into associated challenge data
}

/// Represents a collection of topics and metadata
struct TopicGroup: Codable {
    public var description: String
    public var version: String
    public var author: String
    public var date: String
    public var topics: [BasicTopic]
    public init(description: String, version: String, author: String, date: String, topics: [BasicTopic]) {
        self.description = description
        self.version = version
        self.author = author
        self.date = date
        self.topics = topics
    }
}

/// Represents a single game configuration
struct GameData: Codable, Hashable, Identifiable, Equatable {
    public let id: String
    public let topic: String
    public let challenges: [Challenge]
    public let generated: Date
    public let pic: String?
    public let commentary: String?
    public init(topic: String, challenges: [Challenge], pic: String? = "leaf", shuffle: Bool = false, commentary: String? = nil) {
        self.topic = topic
        self.challenges = shuffle ? challenges.shuffled() : challenges
        self.id = UUID().uuidString
        self.generated = Date()
        self.pic = pic
        self.commentary = commentary
    }
}

/// Represents aggregated game data across multiple topics
struct PlayData: Codable {
    public let topicData: TopicGroup
    public let gameDatum: [GameData]
    public let playDataId: String
    public let blendDate: Date
    public let pic: String?
    /// Returns all topic names in this play session
    /// Assumes upstream processes ensure uniqueness.
    var allTopics: [String] {
        self.topicData.topics.map { $0.name }
    }
}

// MARK: - Challenges and Results

/// Represents a game challenge or question
struct Challenge: Codable, Equatable, Hashable, Identifiable {
    public let question: String
    public let topic: String
    public let hint: String
    public let answers: [String]
    public let correct: String
    public let explanation: String?
    public let id: String
    public let date: Date
    public let aisource: String // Set by the agent generating the challenge (e.g., ChatGPT 4.0)
    public let notes: String?
    public init(question: String, topic: String, hint: String, answers: [String], correct: String, explanation: String? = nil, id: String, date: Date, aisource: String, notes: String? = nil) {
        self.question = question
        self.topic = topic
        self.hint = hint
        self.answers = answers
        self.correct = correct
        self.explanation = explanation
        self.id = id
        self.date = date
        self.aisource = aisource
        self.notes = notes
    }
}

/// Errors that can occur while allocating resources for challenges
enum ChallengeError: Error {
    case notfound
}

/// Result of requesting challenges across topics
/// - success: Contains indices to challenges.
/// - error: Contains details about the failure.
enum AllocationResult: Equatable {
    case success([Int])
    case error(AllocationError)
    enum AllocationError: Equatable, Error {
        case emptyTopics
        case invalidTopics([String])
        case invalidDeallocIndices([Int])
        case insufficientChallenges(Int)
        static func == (lhs: AllocationError, rhs: AllocationError) -> Bool {
            switch (lhs, rhs) {
            case (.insufficientChallenges(let l), .insufficientChallenges(let r)): return l == r
            case (.invalidDeallocIndices(let l), .invalidDeallocIndices(let r)): return l == r
            default: return false
            }
        }
    }
}

// MARK: - Freeport Colors

/// Represents theming colors grouped at a higher level
enum FreeportColor:  CaseIterable, Comparable, Codable {
    case myLightYellow, myDeepPink, myLightBlue, myRoyalBlue, myPeach, myOrange, myLavender, myMint, myLightCoral, myAqua, myLemon, mySkyBlue, mySunshineYellow, myOceanBlue, mySeafoam, myPalmGreen, myCoral, myLagoon, myShell, mySienna, myCoconut, myPineapple, myBurntOrange, myGoldenYellow, myCrimsonRed, myPumpkin, myChestnut, myHarvestGold, myAmber, myMaroon, myRusset, myMossGreen, myIceBlue, myMidnightBlue, myFrost, mySlate, mySilver, myPine, myBerry, myEvergreen, myStorm, myHolly, myOffWhite, myOffBlack, myGold, myHotPink, myDarkOrange, myDarkViolet, myDarkGreen, myCrimson, myTeal, myNavy, myGoldenrod, myForestGreen, myDeepTeal, myChocolate, myBrown, myDarkGoldenrod, myDarkRed, myOrangeRed, mySaddleBrown, myDarkOliveGreen, myPrussianBlue, myAliceBlue, mySteelBlue, myDarkSlateGray, myDarkGray, myWhite
}


enum ChallengeStatus : Int, Codable  {
  case inReserve         // 0
  case allocated         // 1
  case playedCorrectly   // 2
  case playedIncorrectly // 3
  case abandoned         // 4
}

// The manager class to handle Challenge-related operations and state
@Observable
class ChaMan {
  internal init(playData: PlayData) {
    self.playData = playData
    self.stati = []
    self.tinfo = [:]
    self.ansinfo = [:]
  }
  
  // TopicInfo is built from PlayData and is used to improve performance by simplifying searching and
  // eliminating lots of scanning to get counts
  
  
  
  // tinfo and stati must be maintained in sync
  // tinfo["topicname"].ch[123] and stati[123] are in sync with everychallenge[123]
  
  var tinfo: [String: TopicInfo]  // Dictionary indexed by topic
  var stati: [ChallengeStatus]  // Using array instead of dictionary
  var ansinfo: [String:AnsweredInfo] // Dictionary indexed by challenge UUID
  
  var playData: PlayData {
    didSet {
      // Invalidate the cache when playData changes
      invalidateAllTopicsCache()
      invalidateAllChallengesCache()
    }
  }
  
  // Cache for allChallenges
  private var _allChallenges: [Challenge]?
  var everyChallenge: [Challenge] {
    get {
      // If _allChallenges is nil, compute the value and cache it
      if _allChallenges == nil {
        _allChallenges = playData.gameDatum.flatMap { $0.challenges }
      }
      // Return the cached value
      return _allChallenges!
    }
    set {
      // Update the cache with the new value
      _allChallenges = newValue
    }
  }
  
  // Cache for allTopics
  private var _allTopics: [String]?
  var everyTopicName: [String] {
    // If _allTopics is nil, compute the value and cache it
    if _allTopics == nil {
      _allTopics = playData.topicData.topics.map { $0.name }
    }
    // Return the cached value
    return _allTopics!
  }
  // Method to invalidate the allChallenges cache
  func invalidateAllChallengesCache() {
    _allChallenges = nil
  }
  
  // Method to invalidate the cache
  func invalidateAllTopicsCache() {
    _allTopics = nil
  }
}

@Observable
class GameState: Codable {
  var board: [[Int]]  // Array of arrays to represent the game board with challenges
  var cellstate: [[GameCellState]]  // Array of arrays to represent the state of each cell
  var moveindex: [[Int]]  // -1 is unplayed
  var savedGamePaths: [String]
  var replaced: [[[Int]]]  // list of replacements in this cell
  var boardsize: Int  // Size of the game board
  var playstate: StateOfPlay
  var totaltime: TimeInterval  // aka Double
  var veryfirstgame: Bool
  var currentscheme: ColorSchemeName
  var topicsinplay: [String: FreeportColor]  // a subset of allTopics (which is constant and maintained in ChaMan)
  var topicsinorder: [String]
  var onwinpath: [[Bool]]  // only set after win detected
  var gimmees: Int  // Number of "gimmee" actions available
  var doublediag: Bool
  @ObservationIgnored
  var chmgr: ChaMan? = nil
 // @ObservationIgnored
  var currentView: ViewState? = nil
  var difficultylevel: Int
  var lastmove: GameMove?
  var gamestart: Date  // when game started
  var swversion: String  // if this changes we must delete all state
  var woncount: Int
  var lostcount: Int
  var rightcount: Int
  var wrongcount: Int
  var replacedcount: Int
  var gamenumber: Int
  var movenumber: Int
  
  // in chaman we can fetch counts to make % from Tinfo
  //chmgr.tinfo[topic]
  // var tinfo: [String: TopicInfo]  // Dictionary indexed by topic
  //all topics is in chmgr.everyTopicName

  //
  enum CodingKeys: String, CodingKey {
    case board
    case cellstate
    case moveindex
    case savedgamepaths
    case onwinpath
    case replaced
    case boardsize
    case topicsinplay
    case topicsinorder
    case gamestate
    case totaltime
    case veryfirstgame
    case gimmees
    case currentscheme
    case doublediag
    case difficultylevel
    case lastmove
    case gamestart
    case swversion
    case woncount
    case lostcount
    case rightcount
    case wrongcount
    case replacedcount
    case gamenumber
    case movenumber
  }

  // Codable conformance: decode the properties
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.topicsinplay = try container.decode(
      [String: FreeportColor].self, forKey: .topicsinplay)
    self.topicsinorder = try container.decode(
      [String].self, forKey: .topicsinorder)
    self.boardsize = try container.decode(Int.self, forKey: .boardsize)
    self.board = try container.decode([[Int]].self, forKey: .board)
    self.cellstate = try container.decode(
      [[GameCellState]].self, forKey: .cellstate)
    self.moveindex = try container.decode([[Int]].self, forKey: .moveindex)
    self.savedGamePaths = try container.decode([String].self, forKey: .savedgamepaths)
    self.onwinpath = try container.decode([[Bool]].self, forKey: .onwinpath)
    self.replaced = try container.decode([[[Int]]].self, forKey: .replaced)
    self.gimmees = try container.decode(Int.self, forKey: .gimmees)
    self.gamenumber = try container.decode(Int.self, forKey: .gamenumber)
    self.movenumber = try container.decode(Int.self, forKey: .movenumber)
    self.woncount = try container.decode(Int.self, forKey: .woncount)
    self.lostcount = try container.decode(Int.self, forKey: .lostcount)
    self.rightcount = try container.decode(Int.self, forKey: .rightcount)
    self.wrongcount = try container.decode(Int.self, forKey: .wrongcount)
    self.replacedcount = try container.decode(Int.self, forKey: .replacedcount)
    self.totaltime = try container.decode(TimeInterval.self, forKey: .totaltime)
    self.currentscheme = try container.decode(
      ColorSchemeName.self, forKey: .currentscheme)
    self.veryfirstgame = try container.decode(Bool.self, forKey: .veryfirstgame)
    self.doublediag = try container.decode(Bool.self, forKey: .doublediag)
    self.difficultylevel = try container.decode(
      Int.self, forKey: .difficultylevel)  //0//.easy
    self.gamestart = try container.decode(Date.self, forKey: .gamestart)
    self.swversion = try container.decode(String.self, forKey: .swversion)
    self.playstate = try container.decode(StateOfPlay.self, forKey: .gamestate)

  }

  init(chmgr:ChaMan, size: Int, topics: [String: FreeportColor], challenges: [Challenge]) {
    self.topicsinplay = topics  //*****4
    self.topicsinorder = topics.keys.sorted()
    self.boardsize = size
    self.chmgr = chmgr
    self.currentView = .game
    self.board = Array(
      repeating: Array(repeating: -1, count: size), count: size)
    self.cellstate = Array(
      repeating: Array(repeating: .unplayed, count: size), count: size)
    self.moveindex = Array(
      repeating: Array(repeating: -1, count: size), count: size)
    self.savedGamePaths = []
    self.onwinpath = Array(
      repeating: Array(repeating: false, count: size), count: size)
    self.replaced = Array(
      repeating: Array(repeating: [], count: size), count: size)
    self.gimmees = 0
    self.gamenumber = 0
    self.movenumber = 0
    self.woncount = 0
    self.lostcount = 0
    self.rightcount = 0
    self.wrongcount = 0
    self.replacedcount = 0
    self.totaltime = 0.0
    // self.facedown = true
    self.currentscheme = 2  //.summer
    self.veryfirstgame = true
    self.doublediag = false
    self.difficultylevel = 0  //.easy
    //  self.startincorners = true
    self.gamestart = Date()
    self.swversion = AppVersionProvider.appVersion()
    self.playstate = .initializingApp
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(board, forKey: .board)
    try container.encode(cellstate, forKey: .cellstate)
    try container.encode(moveindex, forKey: .moveindex)
    try container.encode(savedGamePaths, forKey: .savedgamepaths)
    try container.encode(onwinpath, forKey: .onwinpath)
    try container.encode(replaced, forKey: .replaced)
    try container.encode(boardsize, forKey: .boardsize)
    try container.encode(topicsinplay, forKey: .topicsinplay)
    try container.encode(topicsinorder, forKey: .topicsinorder)
    try container.encode(playstate, forKey: .gamestate)
    try container.encode(totaltime, forKey: .totaltime)
    try container.encode(veryfirstgame, forKey: .veryfirstgame)
    // `nonObservedProperties`
    try container.encode(gimmees, forKey: .gimmees)
    try container.encode(currentscheme, forKey: .currentscheme)
    try container.encode(doublediag, forKey: .doublediag)
    try container.encode(difficultylevel, forKey: .difficultylevel)
    try container.encode(lastmove, forKey: .lastmove)
    try container.encode(gamestart, forKey: .gamestart)
    try container.encode(swversion, forKey: .swversion)
    try container.encode(woncount, forKey: .woncount)
    try container.encode(lostcount, forKey: .lostcount)
    try container.encode(rightcount, forKey: .rightcount)
    try container.encode(wrongcount, forKey: .wrongcount)
    try container.encode(replacedcount, forKey: .replacedcount)
    try container.encode(gamenumber, forKey: .gamenumber)
    try container.encode(movenumber, forKey: .movenumber)

  }

}

struct AnsweredInfo: Codable {
  internal init(id: String, answer: String, outcome: ChallengeStatus, timestamp: Date, timetoanswer: TimeInterval, gamenumber: Int, movenumber: Int, row: Int, col: Int) {
    self.id = id
    self.answer = answer
    self.outcome = outcome
    self.timestamp = timestamp
    self.timetoanswer = timetoanswer
    self.gamenumber = gamenumber
    self.movenumber = movenumber
    self.row = row
    self.col = col
  }
  
  let id:String //id of the challenge
  let answer:String //answer given
  let outcome:ChallengeStatus
  let timestamp: Date
  let timetoanswer: TimeInterval
  let gamenumber: Int
  let movenumber: Int
  let row: Int
  let col: Int


  
  private enum CodingKeys: CodingKey {
    case id
    case answer
    case outcome
    case timestamp
    case timetoanswer
    case gamenumber
    case movenumber
    case row
    case col
  }
  
  init(from decoder: any Decoder) throws {
    let container: KeyedDecodingContainer<AnsweredInfo.CodingKeys> = try decoder.container(keyedBy: AnsweredInfo.CodingKeys.self)
    
    self.id = try container.decode(String.self, forKey: AnsweredInfo.CodingKeys.id)
    self.answer = try container.decode(String.self, forKey: AnsweredInfo.CodingKeys.answer)
    self.outcome = try container.decode(ChallengeStatus.self, forKey: AnsweredInfo.CodingKeys.outcome)
    self.timestamp = try container.decode(Date.self, forKey: AnsweredInfo.CodingKeys.timestamp)
    self.timetoanswer = try container.decode(TimeInterval.self, forKey: AnsweredInfo.CodingKeys.timetoanswer)
    self.gamenumber = try container.decode(Int.self, forKey: AnsweredInfo.CodingKeys.gamenumber)
    self.movenumber = try container.decode(Int.self, forKey: AnsweredInfo.CodingKeys.movenumber)
    self.row = try container.decode(Int.self, forKey: AnsweredInfo.CodingKeys.row)
    self.col = try container.decode(Int.self, forKey: AnsweredInfo.CodingKeys.col)
    
  }
  
  func encode(to encoder: any Encoder) throws {
    var container: KeyedEncodingContainer<AnsweredInfo.CodingKeys> = encoder.container(keyedBy: AnsweredInfo.CodingKeys.self)
    
    try container.encode(self.id, forKey: AnsweredInfo.CodingKeys.id)
    try container.encode(self.answer, forKey: AnsweredInfo.CodingKeys.answer)
    try container.encode(self.outcome, forKey: AnsweredInfo.CodingKeys.outcome)
    try container.encode(self.timestamp, forKey: AnsweredInfo.CodingKeys.timestamp)
    try container.encode(self.timetoanswer, forKey: AnsweredInfo.CodingKeys.timetoanswer)
    try container.encode(self.gamenumber, forKey: AnsweredInfo.CodingKeys.gamenumber)
    try container.encode(self.movenumber, forKey: AnsweredInfo.CodingKeys.movenumber)
    try container.encode(self.row, forKey: AnsweredInfo.CodingKeys.row)
    try container.encode(self.col, forKey: AnsweredInfo.CodingKeys.col)
  }
}

enum AppVersionProvider {
    static func appVersion(in bundle: Bundle = .main) -> String {
        guard let x = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ,
              let y =  bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
            fatalError("CFBundlexxx missing from info dictionary")
        }
        return x + "." + y
    }
}
