///
///
///
//
//  GameStateExt.swift
//  kwanduh
//
//  Created by bill donner on 10/27/24.
//

import SwiftUI

extension GameState {

func totalScore() -> Int {

  if gamenumber == 0 { return 0 }

  let baseScore =
    switch difficultylevel {
    case 0:  //.easy:
      0
    case 1:  //.normal:
      5
    case 2:  //.hard:
      10
    default: 0
    }

  let incremental =
    woncount * bonusPerWin
    - lostcount * penaltyPerLoss
    + rightcount * bonusPerRight
    - wrongcount * penaltyPerLoss
    - replacedcount * penaltyPerReplaced

  let total = baseScore + incremental
  if total < 0 { return 0 }
  return total

}

func cellsToBlock() -> Set<Coordinate> {
    // Define a tight configuration for generating blocked cells
  let config = boardsize == 3 ? MatrixConfiguration(
    maxBlockedPercentage: 25,          // Up to 40% blocked cells
    minBlockedPercentage:10,          // At least 20% blocked cells
    maxBlockedPerRowCol: 70,           // Max 50% blocked cells per row/column
    maxBlockedPerDiagonal: 30,         // Max 30% blocked cells per diagonal
    cornersRequireAdjacentUnplayed: 1,
    maxAdjacentBlockedPercentage: 10  // Each corner must have 1 unplayed neighbor
  )
  :
  MatrixConfiguration(
      maxBlockedPercentage: 40,          // Up to 50% blocked cells
      minBlockedPercentage: 20,          // At least 20% blocked cells
      maxBlockedPerRowCol: 50,           // Max 50% blocked cells per row/column
      maxBlockedPerDiagonal: 40,         // Max 40% blocked cells per diagonal
      cornersRequireAdjacentUnplayed: 2,
      maxAdjacentBlockedPercentage: 10  // Corners must have 2 unplayed neighbors
  )

    // Call the generateRandomMatrix function with the current board size and configuration
    let randomMatrix = generateRandomMatrix(size: boardsize, configuration: config)

    // Convert blocked cells in the matrix to a set of coordinates
    var blockedCells: Set<Coordinate> = []
    for row in 0..<boardsize {
        for col in 0..<boardsize {
            if randomMatrix[row][col] == .blocked {
                blockedCells.insert(Coordinate(row: row, col: col))
            }
        }
    }

    return blockedCells
}
// does not reset movenumber
func setupForNewGame(boardsize: Int, chmgr: ChaMan) -> Bool {
  // assume all cleaned up, using size
  var allocatedChallengeIndices: [Int] = []

  self.gamestart = Date()
  self.lastmove = nil
  self.boardsize = boardsize
  ///////////////
  self.board = Array(
    repeating: Array(repeating: -1, count: boardsize), count: boardsize)
  self.moveindex = Array(
    repeating: Array(repeating: -1, count: boardsize), count: boardsize)
  self.onwinpath = Array(
    repeating: Array(repeating: false, count: boardsize), count: boardsize)
  self.cellstate = Array(
    repeating: Array(repeating: .unplayed, count: boardsize), count: boardsize
  )
  self.replaced = Array(
    repeating: Array(repeating: [], count: boardsize), count: boardsize)
  // give player a few gimmees depending on boardsize - moved until after
  if self.veryfirstgame { self.gimmees += boardsize - 1 }
  // new **** - figure how many to blank out
  // put these challenges into the board
  // set cellstate to unplayed or blocked

  let blockedCells = cellsToBlock()

  let blankout = blockedCells.count

  // use topicsinplay and allocated fresh challenges
  let result: AllocationResult = chmgr.allocateChallenges(
    forTopics: Array(topicsinplay.keys),
    count: boardsize * boardsize - blankout)
  switch result {
  case .success(let x):
    conditionalAssert(x.count == boardsize * boardsize - blankout)
    // print("Success:\(x.count)")
    allocatedChallengeIndices = x.shuffled()
  //continue after the error path

  case .error(let err):
    print(
      "Allocation failed for topics \(topicsinplay),count :\(boardsize*boardsize-blankout)"
    )
    print("Error: \(err)")
    switch err {
    case .emptyTopics:
      print("EmptyTopics")
    case .invalidTopics(let names):
      print("Invalid Topics \(names)")
    case .insufficientChallenges(let avail):
      print("Insufficient Challenges - only have \(avail) available")
    case .invalidDeallocIndices(let indices):
      print("Indices cant be deallocated \(indices)")
    }
    return false
  }
  // put these challenges into the board
  // set cellstate to unplayed or blocked
  //    allocatedChallengeIndices = x.shuffled()

  var allocIdx = 0
  //deliberately in transposed order
  for col in 0..<boardsize {
    for row in 0..<boardsize {
      let coordinate = Coordinate(row: row, col: col)
      if blockedCells.contains(coordinate) {
        // Mark as blocked cell
        board[row][col] = -1
        cellstate[row][col] = .blocked
      } else {
        // Assign a challenge from allocatedChallengeIndices
        board[row][col] = allocatedChallengeIndices[allocIdx]
        cellstate[row][col] = .unplayed
        allocIdx += 1
      }
    }
  }

  playstate = .playingNow
  saveGameState()
  return true
}

func teardownAfterGame(state: StateOfPlay, chmgr: ChaMan) {
  var challenge_indexes: [Int] = []
  playstate = state
  // examine each board cell and recycle everything thats unplayed
  for row in 0..<boardsize {
    for col in 0..<boardsize {
      if cellstate[row][col] == .unplayed {
        let idx = board[row][col]
        if idx != -1 {  // hack or not?
          challenge_indexes.append(idx)
        }
      }
    }
  }
  // dealloc at indices first before resetting
  let allocationResult = chmgr.deallocAt(challenge_indexes)
  switch allocationResult {
  case .success(_): break
  // print("dealloc succeeded")
  case .error(let err):
    print("dealloc failed \(err)")
  }
  chmgr.resetChallengeStatuses(at: challenge_indexes)

  // if we actually did anything then bump the game number
  if challenge_indexes.count != boardsize * boardsize {
    self.gamenumber += 1
  }

  // clear out last move
  lastmove = nil
  saveGameState()
}

func checkVsChaMan(chmgr: ChaMan, message: String) -> Bool {
  let a = chmgr.correctChallengesCount()
  if a != rightcount {
    print(
      "*** \(message) -  correct challenges count \(a) is wrong \(rightcount)"
    )
    return false
  }
  let b = chmgr.incorrectChallengesCount()
  if b != wrongcount {
    print(
      "*** \(message) - incorrect challenges count \(b) is wrong \(wrongcount)"
    )
    return false
  }
  if playstate != .initializingApp {
    // check everything on the board is consistent
    for row in 0..<boardsize {
      for col in 0..<boardsize {
        let j = board[row][col]
        if j != -1 {
          let x: ChallengeStatus = chmgr.stati[j]
          switch cellstate[row][col] {
          case .playedCorrectly:
            if x != ChallengeStatus.playedCorrectly {
              print(
                "*** \(message) - cellstate is wrong for \(row), \(col) playedCorrectly says \(x)"
              )
              return false
            }
          case .playedIncorrectly:
            if x != ChallengeStatus.playedIncorrectly {
              print(
                "*** \(message) - cellstate is wrong for \(row), \(col) playedIncorrectly says \(x)"
              )
              return false
            }
          case .unplayed:
            if x != ChallengeStatus.allocated {
              print(
                "*** \(message) -cellstate is wrong for \(row), \(col) unplayed says \(x)"
              )
              return false
            }
          case .blocked:
            return true  // for now there's nothing there to check
          }  // switch
          if x == ChallengeStatus.abandoned {
            print(
              "*** \(message) -cellstate is wrong for \(row), \(col) abandoned says \(x)"
            )
            return false
          }
          if x == ChallengeStatus.inReserve {
            print(
              "*** \(message) -cellstate is wrong for \(row), \(col) reserved says \(x)"
            )
            return false
          }
        }
      }
    }
  }
  return true
}

func previewColorMatrix(size: Int, scheme: ColorSchemeName) -> [[Color]] {
  var cm = Array(
    repeating: Array(repeating: Color.black, count: size), count: size)
  for row in 0..<size {
    for col in 0..<size {
      cm[row][col] = colorForSchemeAndTopic(
        scheme: scheme, index: (row * size + col) %  colors_per_scheme
      ).toColor()
    }
  }
  return cm
}
// this returns unplayed challenges and their indices in the challengestatus array
func resetBoardReturningUnplayed() -> [Int] {
  var unplayedInts: [Int] = []
  for row in 0..<boardsize {
    for col in 0..<boardsize {
      if cellstate[row][col] == .unplayed {
        unplayedInts.append((row * boardsize + col))
      }
    }
  }
  return unplayedInts
}


/*******/
  
}

 
extension GameState {
  
  // call After Dimiss of QandA view
 func markReplacementMove(chmgr:ChaMan,row:Int,col:Int,elapsedTime:TimeInterval) {
    let idx = board[row][col]
    let result = chmgr.replaceChallenge(at:board[row][col])
    switch result {
    case .success(let index):
      gimmees -= 1
      board[row][col] = index[0]
      cellstate[row][col] = .unplayed
      replaced[row][col] += [idx] // keep track of what we are replacing
      replacedcount += 1
      print("Gimmee realloation successful \(index)")
      
    case .error(let error):
      print("Couldn't handle gimmee reallocation \(error)")
    }
    saveGameState()
   chmgr.save()
  }
  
  // call After Dimiss of QandA view
  func markCorrectMove(chmgr:ChaMan,  row: Int,col: Int, ch: Challenge,  answered: String,elapsedTime:TimeInterval) {
    movenumber += 1
    moveindex[row][col] = movenumber
    cellstate[row][col] = .playedCorrectly
    rightcount += 1
    chmgr.bumpRightcount(topic: ch.topic)
    chmgr.stati[board[row][col]] = .playedCorrectly  // ****
    chmgr.ansinfo[ch.id]  =
    AnsweredInfo(id: ch.id, answer: answered, outcome:.playedCorrectly,
                 timestamp: Date(), timetoanswer:elapsedTime, gamenumber: gamenumber, movenumber: movenumber,row:row,col:col)
    saveGameState()
    chmgr.save()
  }
  // call After Dimiss of QandA view
  func markIncorrectMove(chmgr:ChaMan,row: Int,col: Int,ch: Challenge,  answered: String,elapsedTime:TimeInterval){
    movenumber += 1
    moveindex[row][col] = movenumber
    cellstate[row][col] = .playedIncorrectly
    wrongcount += 1
    chmgr.bumpWrongcount(topic: ch.topic)
    chmgr.stati[board[row][col]] = .playedIncorrectly  // ****
    chmgr.ansinfo[ch.id]  =
    AnsweredInfo(id: ch.id, answer: answered, outcome:.playedIncorrectly,
                 timestamp: Date(), timetoanswer: elapsedTime, gamenumber: gamenumber, movenumber: movenumber,row:row,col:col)
    saveGameState()
    chmgr.save()
  }
  ////////
  
  func moveHistory() -> [GameMove] {
    var moves: [GameMove] = []
    for row in 0..<boardsize {
      for col in 0..<boardsize {
        //yikes
        if cellstate[row][col] != .unplayed && cellstate[row][col] != .blocked {
          moves.append(
            GameMove(row: row, col: col, movenumber: moveindex[row][col]))
        }
      }
    }
    return moves.sorted(by: { $0.movenumber < $1.movenumber })
  }
  func indexInPath(row: Int, col: Int, path: [Coordinate]) -> Int? {
    for (idx, p) in path.enumerated() {
      if p.row == row && p.col == col { return idx }
    }
    return nil
  }
  func winningPathOfGameMoves() -> [GameMove] {
    
    let (path, found) = winningPath(in: cellstate)
    if !found { return [] }
    
    var z: [GameMove] = []
    for row in 0..<boardsize {
      for col in 0..<boardsize {
        if let x = indexInPath(row: row, col: col, path: path) {
          z.append(GameMove(row: row, col: col, movenumber: x))
        }
      }
    }
    return z.sorted(by: { $0.movenumber < $1.movenumber })
  }
  func prettyPathOfGameMoves() -> String {
    let moves = winningPathOfGameMoves()
    var out = ""
    for move in moves {
      out.append("(\(move.row),\(move.col))")
    }
    return out
  }
  
  func isCornerCell(row: Int, col: Int) -> Bool {
    return (row == 0 && col == 0) || (row == 0 && col == boardsize - 1)
    || (row == boardsize - 1 && col == 0)
    || (row == boardsize - 1 && col == boardsize - 1)
  }
  func isAdjacentToCornerCell(row: Int, col: Int) -> Bool {
    // Define the coordinates of the four corners
    let corners = [
      (0, 0),
      (0, boardsize - 1),
      (boardsize - 1, 0),
      (boardsize - 1, boardsize - 1),
    ]
    
    // Define directions for all 8 possible adjacent cells
    let directions = [
      (-1, -1), (-1, 0), (-1, 1),
      (0, -1), (0, 1),
      (1, -1), (1, 0), (1, 1),
    ]
    
    // Check if the cell is adjacent to any of the corners
    for corner in corners {
      for direction in directions {
        let adjacentRow = corner.0 + direction.0
        let adjacentCol = corner.1 + direction.1
        if adjacentRow == row && adjacentCol == col {
          return true
        }
      }
    }
    
    return false
  }
  func oppositeCornerCell(row: Int, col: Int) -> (Int, Int)? {
    switch (row, col) {
      
    case (0, 0): return (self.boardsize - 1, self.boardsize - 1)
    case (self.boardsize - 1, self.boardsize - 1): return (0, 0)
    case (0, self.boardsize - 1): return (self.boardsize - 1, 0)
    case (self.boardsize - 1, 0): return (0, self.boardsize - 1)
    default: return nil
    }
  }
  func rhCornerCell(row: Int, col: Int) -> (Int, Int)? {
    switch (row, col) {
      
    case (0, 0): return (0, self.boardsize - 1)
    case (self.boardsize - 1, self.boardsize - 1):
      return (self.boardsize - 1, 0)
    case (0, self.boardsize - 1):
      return (self.boardsize - 1, self.boardsize - 1)
    case (self.boardsize - 1, 0): return (0, 0)
    default: return nil
    }
  }
  func lhCornerCell(row: Int, col: Int) -> (Int, Int)? {
    switch (row, col) {
    case (0, 0): return (self.boardsize - 1, 0)
    case (self.boardsize - 1, self.boardsize - 1):
      return (0, self.boardsize - 1)
    case (0, self.boardsize - 1): return (0, 0)
    case (self.boardsize - 1, 0):
      return (self.boardsize - 1, self.boardsize - 1)
    default: return nil
    }
  }
  func isAlreadyPlayed(row: Int, col: Int) -> (Bool) {
 (self.cellstate[row][col] == .playedCorrectly
              || self.cellstate[row][col] == .playedIncorrectly)
   
  }
  func hasAtLeastTwoNonBlockedNeighbors(_ row: Int, _ col: Int) -> Bool {
    var nonBlockedNeighborCount = 0
    let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
    for direction in directions {
      let newRow = row + direction.0
      let newCol = col + direction.1
      if newRow >= 0, newRow < boardsize, newCol >= 0, newCol < boardsize {
        if cellstate[newRow][newCol] != .blocked {
          nonBlockedNeighborCount += 1
        }
      }
    }
    return nonBlockedNeighborCount >= 2
  }
  func hasAtLeastOneNonBlockedNeighbors(_ row: Int, _ col: Int) -> Bool {
    var nonBlockedNeighborCount = 0
    let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
    for direction in directions {
      let newRow = row + direction.0
      let newCol = col + direction.1
      if newRow >= 0, newRow < boardsize, newCol >= 0, newCol < boardsize {
        if cellstate[newRow][newCol] != .blocked {
          nonBlockedNeighborCount += 1
        }
      }
    }
    return nonBlockedNeighborCount >= 1
  }
  
}
extension GameState {
  func basicTopics() -> [BasicTopic] {
    return topicsinplay.keys.map { BasicTopic(name: $0) }
  }

  private static func indexOfTopic(_ topic: String, within: [String]) -> Int? {
    return within.firstIndex(where: { $0 == topic })
  }
  private func indexOfTopic(_ topic: String) -> Int? {
    Self.indexOfTopic(topic, within: Array(self.topicsinplay.keys))
  }



  static func minTopicsForBoardSize(_ size: Int) -> Int {
    switch size {
    case 3: return 1
    case 4: return 1
    case 5: return 1
    case 6: return 1
    case 7: return 1
    case 8: return 1
    default: return 1
    }
  }

  static func maxTopicsForBoardSize(_ size: Int) -> Int {
    switch size {
    case 3: return 5
    case 4: return 5
    case 5: return 5
    case 6: return 5
    case 7: return 5
    case 8: return 5
    default: return 5
    }
  }

  static func preselectedTopicsForBoardSize(_ size: Int) -> Int {

    switch size {
    case 3: return 3
    case 4: return 3
    case 5: return 3
    case 6: return 3
    case 7: return 3
    case 8: return 3
    default: return 3
    }
  }
  
  // Get the file path for storing challenge statuses
  static func getGameStateFilePath() -> URL {
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    return urls[0].appendingPathComponent("gameBoard.json")
  }

  func saveGameState() {
    //TSLog("SAVE GAMESTATE")
    let filePath = Self.getGameStateFilePath()
    do {
      let data = try JSONEncoder().encode(self)
      try data.write(to: filePath)
    } catch {
      print("Failed to save gs: \(error)")
    }
  }
  // Load the GameBoard
  static func loadGameState() -> GameState? {
    let filePath = getGameStateFilePath()
    do {
      let data = try Data(contentsOf: filePath)
      let gb = try JSONDecoder().decode(GameState.self, from: data)
      switch compareVersionStrings(
        gb.swversion, AppVersionProvider.appVersion())
      {

      case .orderedAscending:
        TSLog(
          "sw version changed from \(gb.swversion) to \(AppVersionProvider.appVersion())"
        )
      case .orderedSame:
        break  //TSLog("sw version is the same")
      case .orderedDescending:
        TSLog("yikes! sw version went backwards")
      }
      // Let's check right now to make sure the software version has not changed
      if haveMajorComponentsChanged(
        gb.swversion, AppVersionProvider.appVersion())
      {
        print("***major sw version change ")
        deleteAllState()
        return nil  // version change
      }
      return gb
    } catch {
      print("Failed to load gs: \(error)")
      deleteAllState()
      return nil
    }
  }
  
   
  static func documentsDirectory() -> URL {
      FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  }

  func saveGameStateToFile() -> URL? {
      let fileName = "gameState_\(UUID().uuidString.prefix(8))_\(Date().timeIntervalSince1970).json"
      let fileURL = Self.documentsDirectory().appendingPathComponent(fileName)
      
      do {
          let data = try JSONEncoder().encode(self)
          try data.write(to: fileURL)

    
        savedGamePaths += [fileURL.path]
     
          saveGameState() // Save the updated paths to persistent storage
          
          return fileURL
      } catch {
          print("Failed to save game state to file: \(error)")
          return nil
      }
  }

  static func loadGameStateFromFile(at path: String) -> GameState? {
      let fileURL = URL(fileURLWithPath: path)
      do {
          let data = try Data(contentsOf: fileURL)
          let gameState = try JSONDecoder().decode(GameState.self, from: data)
          return gameState
      } catch {
          print("Failed to load game state from file: \(error)")
          return nil
      }
  }
}
