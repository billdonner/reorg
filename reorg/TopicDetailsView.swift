//
//  TopicDetailsView.swift
//  basic
//
//  Created by bill donner on 7/30/24.
//

import SwiftUI
func isUsedup(_ status:ChallengeStatus) -> Bool {
  switch status {
  case .abandoned:
    return true
  case .playedCorrectly:
    return true
  case .playedIncorrectly:
    return true
  default:
    return false
  }
}
struct TopicDetailsView: View {
  let topic:String
  let gs:GameState
  let chmgr:ChaMan
  let background:Color
  let foreground:Color
  
  @State private var showApview:Challenge?  = nil

  var body: some View {
    let tinfo = chmgr.tinfo[topic]
    let freecount = tinfo?.freecount ?? 0
    
    if let tinfo = tinfo {
      let (chas, stas) = tinfo.getChallengesAndStatuses(chmgr: chmgr)

      VStack {
        ZStack {
          background
            .ignoresSafeArea(edges: .top)
          
          VStack {
            Text(topic)
              .font(.largeTitle)
              .fontWeight(.bold)
            // .shadow(color: .black, radius: 1, x: 0, y: 1)
              .padding(.top, 50)
            Text("\(chas.count) challenges in this topic")
              .font(.footnote)
            Text("\(freecount) free")
              .font(.footnote)
            //  .shadow(color: .black, radius: 1, x: 0, y: 1)
          }
          .foregroundColor(foreground)
          .padding()
        }
        List {
          ForEach(0..<chas.count, id: \.self) { idx in
            if isUsedup(stas[idx]) {
              HStack {
                let ansinfo = chmgr.ansinfo[chas[idx].id]
                if let ansinfo = ansinfo
                {
                  let s = "\(ansinfo.movenumber).circle"
                  Image(systemName: s) .font(.headline)
                  //  .foregroundColor(colorScheme == .light ? .black : .white )
                }
                VStack(alignment: .leading) {
                  Text(truncatedText(chas[idx].question, count: 200))
                  let tt =  switch stas[idx] {
                  case .playedCorrectly: "✅"
                  case .playedIncorrectly:"❌"
                  case .abandoned:"💤"
                  default:"⁉️"
                  }
                  Text(tt).font(.headline)
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .foregroundColor(.gray)
              }
              .contentShape(Rectangle()) // Make the entire HStack tappable
              .onTapGesture {
                showApview = chas[idx]
              }
            }
          }
        }
    
//        .sheet(item: $showApview) { challenge in
//          if let ansinfo = chmgr.ansinfo [challenge.id] {
////          ReplayingScreen(ch: challenge,ansinfo: ansinfo,  gs:gs)
//            EmptyView()
//          }
//        }
      }
//      .dismissButton(backgroundColor:.red)//gs.topicsinplay[ topic]?.toColor() ?? .red) // put a dismiss button up there
 
    }  
  }
}

#Preview {
 let topic = "Fun"
  let gs = GameState.mock
  if let freeportColor = gs.topicsinplay[topic] {
    let bkg = freeportColor.toColor()
    TopicDetailsView(topic:"topic",gs:gs,
                     chmgr: ChaMan.mock, background:bkg , foreground: contrastingTextColor(for: colorToRGB(color: bkg)))
    
  }
}
