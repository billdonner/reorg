//
//  File.swift
//  reorg
//
//  Created by bill donner on 1/12/25.
//
import SwiftUI
// MARK: - CorrectlyAnsweredView
struct CorrectlyAnsweredView: View {
 
    let gs:GameState
    let row:Int
    let col:Int
  
   var onBackToQandA: () -> Void
      var body: some View {
        let chmgr = gs.chmgr
        let challenge = chmgr!.everyChallenge[ row*gs.boardsize +  col]
        
        VStack(spacing: 0) {
            // Display the Question
          Text("You answered correctly:").font(.subheadline)
          Spacer()
               Text( "\(challenge.question)")
                .padding()
                .multilineTextAlignment(.center)
          Spacer()
               Text( "\(challenge.correct )")
                .padding()
                .multilineTextAlignment(.center)
            Spacer()
        }
        .withTitleBar(title: "Answered Correctly 😀", onDismiss: onBackToQandA)
        .background(Color(.systemBackground))
    }
}
#Preview("Correct") {
  CorrectlyAnsweredView(gs:GameState.mock, row: 0, col: 0,  onBackToQandA: {})
}

