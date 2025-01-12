//
//  GameScreenExt.swift
//  basic
//
//  Created by bill donner on 8/4/24.
//

import SwiftUI

extension MainGameView /* actions */ {

  // Process single tap
  func onSingleTap(_ row: Int, _ col: Int) {
    var validTap = false

    // No taps on blocked cells
    if gs.cellstate[row][col] == .blocked { return }

    // If this cell is already played, trigger a full-screen cover to present it
    if gs.isAlreadyPlayed(row: row, col: col) {
      alreadyPlayed = Xdi(
        row: row, col: col, challenge: chmgr.everyChallenge[gs.board[row][col]])
      return
    }

    // When a player tries to start the game in a box other than a corner, show the appropriate alert
    if gs.playstate == .playingNow && (gs.movenumber == 0)
      && !gs.isCornerCell(row: row, col: col)
    {
      activeAlert = .mustStartInCorner
      return
    }

    // If a player tries to play a box that is not adjacent to a played box, show the adjacent-cell alert
    if gs.playstate == .playingNow && gs.movenumber != 0
      && !gs.isCornerCell(row: row, col: col)
      && !hasAdjacentNeighbor(
        withStates: [.playedCorrectly, .playedIncorrectly],
        in: gs.cellstate,
        for: Coordinate(row: row, col: col)
      )
    {
      activeAlert = .mustTapAdjacentCell
      return
    }

    // If not playing, ignore all other taps
    if gs.playstate == .playingNow,
      gs.cellstate[row][col] == .unplayed
    {
      // Consider valid tap if first move corner cell or not first and valid adjacent conditions
      validTap =
      gs.movenumber == 0 
        ? gs.isCornerCell(row: row, col: col)
        : (gs.isCornerCell(row: row, col: col)
          || hasAdjacentNeighbor(
            withStates: [.playedCorrectly, .playedIncorrectly],
            in: gs.cellstate,
            for: Coordinate(row: row, col: col)
          ))
    }

    if validTap {
      gs.lastmove = GameMove(row: row, col: col, movenumber: gs.movenumber)
      /**
      //firstMove = false
      // This kicks off the full-screen cover of the QandAScreen
      chal = IdentifiablePoint(
        row: row, col: col, status: chmgr.stati[row * gs.boardsize + col])
      */
      
      // in the new way of doing things just jump to the qanda view
      gs.currentView = .qanda(chmgr.everyChallenge[row * gs.boardsize + col], row, col)
    }
  }

  // Evaluate winners and losers
  func onChangeOfCellState() {
    let (path, isWinner) = winningPath(in: gs.cellstate)

    if isWinner {
      TSLog("--->YOU WIN path is \(path)")
      for p in path {
        gs.onwinpath[p.row][p.col] = true
      }
      isWinAlertPresented = true
      //activeAlert = .youWin
      return
    }

    if !isPossibleWinningPath(in: gs.cellstate) {
      TSLog("--->YOU LOSE")
      isLoseAlertPresented = true
     // activeAlert = .youLose
      return
    }

    // Check if any corner is marked as played incorrectly
    let incorrectInACorner =
      gs.cellstate[0][0] == .playedIncorrectly
      || gs.cellstate[gs.boardsize - 1][gs.boardsize - 1] == .playedIncorrectly
      || gs.cellstate[0][gs.boardsize - 1] == .playedIncorrectly
      || gs.cellstate[gs.boardsize - 1][0] == .playedIncorrectly

    // Check if two corners on the same side are marked as played correctly
    let twoCorrectInCornersOnSameSide =
      ((gs.cellstate[0][0] == .playedCorrectly
        && gs.cellstate[0][gs.boardsize - 1] == .playedCorrectly)
        || (gs.cellstate[gs.boardsize - 1][0] == .playedCorrectly
          && gs.cellstate[gs.boardsize - 1][gs.boardsize - 1]
            == .playedCorrectly)
        || (gs.cellstate[0][0] == .playedCorrectly
          && gs.cellstate[gs.boardsize - 1][0] == .playedCorrectly)
        || (gs.cellstate[0][gs.boardsize - 1] == .playedCorrectly
          && gs.cellstate[gs.boardsize - 1][gs.boardsize - 1]
            == .playedCorrectly))

    if gs.playstate == .playingNow {
      if incorrectInACorner {
        if activeAlert != .otherDiagonal {  // Show this alert only once
          otherDiagShownCount -= 1
          if otherDiagShownCount >= 0 {
            activeAlert = .otherDiagonal
          }
        } else if twoCorrectInCornersOnSameSide {
          if activeAlert != .sameSideDiagonal {  // Show this alert only once
            sameDiagShownCount -= 1
            if sameDiagShownCount >= 0 {
              activeAlert = .sameSideDiagonal
            }
          }
        }
      }
    }
  }

  func onAppearAction() {
    // On a completely cold start
    if gs.gamenumber == 0 {
      print(
        "//GameScreen OnAppear Coldstart size:\(gs.boardsize) topics: \(topics)"
      )
    } else {
      print(
        "//GameScreen OnAppear Warmstart size:\(gs.boardsize) topics: \(topics)"
      )
    }
    chmgr.checkAllTopicConsistency("gamescreen on appear")
  }

  func onCantStartNewGameAction() {
    print("//GameScreen onCantStartNewGameAction")
    activeAlert = nil
  }

  func onYouWin() {
    withAnimation {
      endGame(status: .justWon)
    }
  }

  func onYouLose() {
    withAnimation {
      endGame(status: .justLost)
    }
  }

  func onEndGamePressed() {
    withAnimation {
      endGame(status: .justAbandoned)
    }
  }

  func onBoardSizeChange() {
    // Placeholder for future logic
  }

  func onDump() {
    chmgr.dumpTopics()
  }

  func startTheGame(boardsize: Int) -> Bool {
    print("startTheGame gamestate is \(gs.playstate)")
    if gs.playstate == .playingNow {
      gs.teardownAfterGame(state: .justAbandoned, chmgr: chmgr)
    }
    resetAlerts()
    //isTouching = false  // Turn off overlay
    let ok = gs.setupForNewGame(boardsize: boardsize, chmgr: chmgr)
    if !ok {
      print(
        "Failed to allocate \(boardsize * boardsize) challenges for topics \(gs.topicsinplay.keys.joined(separator: ","))"
      )
      print("Consider changing the topics in settings and trying again ...")
      activeAlert = .cantStart
    } else {
    // all good, reset movenumber
      gs.movenumber = 0
      TSLog("--->NEW GAME STARTED")
    }
    return ok
  }

  func endGame(status: StateOfPlay) {
   // isTouching = false  // Turn off overlay
    chmgr.checkAllTopicConsistency("end game")
    gs.teardownAfterGame(state: status, chmgr: chmgr)
    let _ = gs.saveGameStateToFile()
  }

  private func resetAlerts() {
    activeAlert = nil
   // isTouching = false
  }
}
