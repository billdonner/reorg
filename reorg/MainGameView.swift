//
//  MainGameView.swift
//  reorg
//
//  Created by bill donner on 12/25/24.
//

import SwiftUI


enum GameAlertType: Identifiable {
  case mustTapAdjacentCell
  case mustStartInCorner
  case cantStart
  case otherDiagonal
  case sameSideDiagonal
  case youWin
  case youLose
  
  var id: String {
    switch self {
    case .mustTapAdjacentCell: return "mustTapAdjacentCell"
    case .mustStartInCorner: return "mustStartInCorner"
    case .cantStart: return "cantStart"
    case .otherDiagonal: return "otherDiagonal"
    case .sameSideDiagonal: return "sameSideDiagonal"
    case .youWin: return "youWin"
    case .youLose: return "youLose"
    }
  }
}



// MARK: - MainGameView
struct MainGameView: View {
    var gs: GameState
  let chmgr: ChaMan
  
  @Binding var topics: [String: FreeportColor]
    var onQandA: (Challenge) -> Void // Pass the selected question
    var onSettings: () -> Void
  struct Xdi: Identifiable
  {
    let row:Int
    let col:Int
    let challenge: Challenge
    let id=UUID()
  }
  @State var alreadyPlayed: Xdi?
  
  @State var chal: IdentifiablePoint? = nil
  @State var activeAlert: GameAlertType?
  @State  var isWinAlertPresented = false
  @State  var isLoseAlertPresented = false
  
  @State var otherDiagShownCount = maxShowOtherDiag
  @State var sameDiagShownCount = maxShowSameDiag
   

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("QANDA Live Game")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button(action: onSettings) {
                    Image(systemName: "gear")
                        .font(.largeTitle)
                        .foregroundColor(.primary)
                }
                .padding(.trailing)
            }
           // .padding(.top)

Spacer()
          
          // Main game grid
          MainGridView(
            gs: gs,
            chmgr: gs.chmgr!,
            onSingleTap: { a,b in
              onSingleTap(a,b)
            }
          )

        
          
          

            Spacer()
          
          ScoreBarView (gs: gs)
        }
        .padding()
    }

}

#Preview {
  MainGameView(gs: GameState.mock, chmgr: ChaMan.mock, topics: .constant([:]), onQandA: {_ in }, onSettings: {})
}
 
