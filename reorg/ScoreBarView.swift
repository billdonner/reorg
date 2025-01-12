//
//  ScoreBarView.swift
//  qdemo
//
//  Created by bill donner on 5/24/24.
//

import SwiftUI
func formattedElapsedTime(_ elapsedTime:TimeInterval)-> String {
  let minutes = Int(elapsedTime) / 60
  let seconds = Int(elapsedTime) % 60
  return String(format: "%02d:%02d", minutes, seconds)
}

struct ScoreBarView:View {

  let gs: GameState
  
  var body: some View{
    let realScore :Double = gs.totaltime == 0.0 ? 0.0 : ( Double(gs.totalScore())   * 100.0 / gs.totaltime)
    HStack {
      VStack(spacing: 0){
        HStack {
          Text(formattedElapsedTime(gs.totaltime))
              .font(.system(size: 36))
          Text("score:").font(isIpad ? .body:.footnote);
          Text(String(format: "%.2f", realScore))
            .font(.system(size: 36))
          Text("gimmees:").font(isIpad ? .body:.footnote);
          Text("\(gs.gimmees)")
            .font(.system(size: 36))
        }
        //stats is another line
        HStack {
          Text("won:");Text("\(gs.woncount)")
          Text("lost:");Text("\(gs.lostcount)")
          Text("right:");Text("\(gs.rightcount)")
          Text("wrong:");Text("\(gs.wrongcount)")
          
        }.opacity(0.8)
          .font(isIpad ? .title:.footnote)
      }
    }
  }
}


#Preview {
  @Previewable
  @State var marqueeMessage = "blah blah"
  ScoreBarView(gs: GameState.mock)//, marqueeMessage: $marqueeMessage )
}
