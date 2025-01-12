//
//  SingleCellView.swift
//  basic
//
//  Created by Bill Donner on 7/30/24.
//

import SwiftUI

/// A view modifier that sets a cell’s frame size and opacity.
struct SingleCellViewModifier: ViewModifier {
  let cellSize: CGFloat
  let cornerRadius: CGFloat
  let opacity: Double
  
  func body(content: Content) -> some View {
    content
      .frame(width: cellSize, height: cellSize)
      .opacity(opacity)
  }
}

extension View {
  /// Applies the SingleCellViewModifier for consistency across cells.
  func singleFormat(cellSize: CGFloat, cornerRadius: CGFloat, opacity: Double) -> some View {
    self.modifier(
      SingleCellViewModifier(cellSize: cellSize,
                             cornerRadius: cornerRadius,
                             opacity: opacity)
    )
  }
}

/// A SwiftUI view representing a single cell in the game grid.
struct SingleCellView: View {
  @Bindable var gs: GameState
  let chmgr: ChaMan
  let row: Int
  let col: Int
  let chidx: Int
  let status: GameCellState
  let cellSize: CGFloat
  let onSingleTap: (_ row: Int, _ col: Int) -> Void
  
  @Environment(\.colorScheme) var colorScheme
  
  // MARK: - Computed Properties

  /// True if this cell should show the "blue" circle indicator (adjacent/corner logic).
  private var showBlue: Bool {
    gs.playstate == .playingNow &&
    (gs.isCornerCell(row: row, col: col) ||
     hasAdjacentNeighbor(withStates: [.playedCorrectly, .playedIncorrectly],
                         in: gs.cellstate, for: Coordinate(row: row, col: col)))
  }
  
  /// True if this cell should show the "red" circle indicator (gimme-ed).
  private var showRed: Bool {
    !gs.replaced[row][col].isEmpty
  }
  
  /// True if this cell is the last move made in the game.
  private var isLastMove: Bool {
    gs.lastmove?.row == row && gs.lastmove?.col == col
  }
  
  // MARK: - Target Logic

  private func showTargetFor(row: Int, col: Int) -> Bool {
    guard gs.playstate == .playingNow else {
      return false
    }
    guard gs.cellstate[row][col] == .unplayed else {
      return false
    }
    guard let (orow, ocol) = gs.oppositeCornerCell(row: row, col: col) else {
      return false
    }
    guard gs.movenumber != 0 else {
      // For the very first move, show the target if it’s a valid corner.
      return true
    }
    // Opposite corner must be unplayed or correct
    guard gs.cellstate[orow][ocol] == .unplayed
       || gs.cellstate[orow][ocol] == .playedCorrectly else {
      return false
    }
    // Check left and right neighbor corners
    guard let (lrow, lcol) = gs.lhCornerCell(row: row, col: col),
          let (rrow, rcol) = gs.rhCornerCell(row: row, col: col) else {
      return false
    }
    let rNeighborState = gs.cellstate[rrow][rcol]
    let lNeighborState = gs.cellstate[lrow][lcol]
    
    switch (rNeighborState, lNeighborState) {
    case (.unplayed, .unplayed),
         (.playedIncorrectly, .playedIncorrectly),
         (.playedCorrectly, .playedCorrectly),
         (.playedIncorrectly, .unplayed),
         (.unplayed, .playedIncorrectly),
         (.playedCorrectly, .playedIncorrectly),
         (.playedIncorrectly, .playedCorrectly):
      return true
    case (.playedCorrectly, .unplayed),
         (.unplayed, .playedCorrectly),
         (.blocked, _),
         (_, .blocked):
      return false
    }
  }
  
  // MARK: - Indicators

  /// Shows an orange circle to indicate the last move.
  private func lastMoveIndicator() -> some View {
    Circle()
      .fill(Color.orange)
      .frame(width: cellSize / 6, height: cellSize / 6)
      .offset(x: -cellSize / 2 + 10, y: -cellSize / 2 + 10)
  }
  
  /// Shows a "target" system image (SF Symbol) to highlight this cell.
  private func targetIndicator(challenge: Challenge) -> some View {
    Image(systemName: "target")
      .symbolEffect(.breathe.pulse.byLayer)
      .font(.largeTitle)
      .foregroundColor(
        foregroundColorFrom(
          backgroundColor: gs.topicsinplay[chidx < 0 ? Challenge.amock.topic : challenge.topic]?.toColor() ?? .red
        )
        .opacity(0.4)
      )
      .frame(width: cellSize, height: cellSize)
  }
  
  /// Shows a move index or circle for the move order.
  private func moveIndicator() -> some View {
    let moveIndex = gs.moveindex[row][col]
    switch moveIndex {
    case -1:
      return AnyView(Text("???").font(.footnote).opacity(0.0))
    case 0...50:
      return AnyView(
        Image(systemName: "\(moveIndex).circle")
          .font(.largeTitle)
          .frame(width: cellSize, height: cellSize)
          .opacity(0.7)
          .foregroundColor(colorScheme == .light ? .black : .white)
      )
    default:
      return AnyView(Text("\(moveIndex)").font(.footnote).opacity(1.0))
    }
  }
  
  // MARK: - Bottom Layer

  /// Renders the bottom layer of the cell, including backgrounds and border overlays.
  private func bottomLayer(challenge: Challenge) -> some View {
    VStack(alignment: .center, spacing: 0) {
      switch gs.cellstate[row][col] {
      case .playedCorrectly:
        textBody(challenge: challenge)
          .overlay(
            Circle()
              .stroke(Color.green, lineWidth: Double(singleCellBorderBloatedSize - gs.boardsize))
          )
          .singleFormat(cellSize: cellSize, cornerRadius: 10, opacity: playingNowOpacity())
        
      case .playedIncorrectly:
        textBody(challenge: challenge)
          .overlay(
            Circle()
              .stroke(Color.red, lineWidth: Double(singleCellBorderBloatedSize - gs.boardsize))
          )
          .singleFormat(cellSize: cellSize, cornerRadius: 10, opacity: playingNowOpacity())
        
      case .unplayed:
        if gs.playstate == .playingNow {
          textBody(challenge: challenge)
            .singleFormat(cellSize: cellSize, cornerRadius: 10, opacity: playingNowOpacity())
        } else {
          // For unplayed cells outside of .playingNow, show a neutral circular background
          let diameter = cellSize * 0.9
          (colorScheme == .dark ? Color.offBlack : Color.offWhite)
            .frame(width: diameter, height: diameter)
            .clipShape(Circle())
            .singleFormat(cellSize: cellSize, cornerRadius: 10, opacity: playingNowOpacity())
        }
        
      case .blocked:
        // Blocked cells also appear as circles
        let diameter = cellSize * 0.9
        
        /**
         
         Make blocking cells completely mesh with the background rendering them invisible
         */
       // (colorScheme == .light ? Color.offBlack : Color.offWhite) // makes them contrasting
        Color(.systemBackground)
          .frame(width: diameter, height: diameter)
          .clipShape(Circle())
          .singleFormat(cellSize: cellSize, cornerRadius: 10, opacity: 1.0)
      }
    }
  }
  
  // MARK: - Text Body

  /// Draws the circular background (and text, if desired).
  private func textBody(challenge: Challenge) -> some View {
    let diameter = cellSize * 0.9  // 10% smaller than cellSize
    let colormix = gs.topicsinplay[challenge.topic]?.toColor() ?? .red
    let foregroundcolor = foregroundColorFrom(backgroundColor: colormix)
    
    return Text("") // Use challenge.question if you prefer text inside the circle
      .font(UIScreen.main.bounds.width > 768 ? .title : .caption)
      .padding(10)
      .frame(width: diameter, height: diameter)
      .background(colormix)
      .clipShape(Circle())
      .foregroundColor(foregroundcolor)
      .opacity(playingNowOpacity())
  }
  
  /// Returns 100% opacity if game is currently playing, else 50%.
  private func playingNowOpacity() -> Double {
    gs.playstate == .playingNow ? 1.0 : 0.5
  }
  
  /// Action handler for when this cell is tapped.
  private func handleTap() {
    onSingleTap(row, col)
  }
  
  // MARK: - Body

  var body: some View {
    let inBounds = row < gs.boardsize && col < gs.boardsize
    let challenge = (chidx < 0) ? Challenge.amock : chmgr.everyChallenge[chidx]
    
    return ZStack {
      if inBounds {
        bottomLayer(challenge: challenge)
        if isLastMove {
          lastMoveIndicator()
        }
        if showTargetFor(row: row, col: col) {
          targetIndicator(challenge: challenge)
        }
        // Example if you want the moveIndicator, or other overlays:
        // moveIndicator()
      }
    }
    .onTapGesture {
      handleTap()
    }
  }
}

// MARK: - Preview

#Preview("No Touching", traits: .sizeThatFitsLayout) {
  let gs = GameState.mock
  gs.cellstate[0][0] = .playedCorrectly
  
  return SingleCellView(
    gs: gs,
    chmgr: ChaMan(playData: PlayData.mock),
    row: 0,
    col: 0,
    chidx: 0,
    status: .unplayed,
    cellSize: 250,
    onSingleTap: { _, _ in }
  )
}

/*
 // If you want to show additional indicators (blue/red corner indicators, move index, etc.),
 // you could uncomment this and incorporate it into the ZStack.

 private func touchingIndicators() -> some View {
   Group {
     // Blue indicates a legal move
     if showBlue {
       Circle()
         .fill(Color.blue)
         .frame(width: cellSize / 6, height: cellSize / 6)
         .offset(x: cellSize / 2 - 7, y: -cellSize / 2 + 10)
     }
     
     // Red indicates challenge was gimmeed in this cell
     if showRed {
       Circle()
         .fill(Color.neonRed)
         .frame(width: cellSize / 6, height: cellSize / 6)
         .offset(x: -cellSize / 2 + 10, y: cellSize / 2 - 10)
     }
     
     // Show move number
     moveIndicator()
     
     // Checkmark for a winning path
     if gs.onwinpath[row][col] {
       Image(systemName: "checkmark")
         .resizable()
         .aspectRatio(contentMode: .fit)
         .frame(width: cellSize / 8, height: cellSize / 8)
         .offset(x: cellSize / 3 - 1, y: cellSize / 3 - 1)
         .foregroundColor(.green)
     }
   }
 }
*/
