//
//  SettingsView.swift
//  reorg
//
//  Created by bill donner on 12/25/24.
//

import SwiftUI
// MARK: - SettingsView
struct SettingsView: View {
  @Binding var gameState: GameState
 let chmgr: ChaMan
  var onNewRound: () -> Void
  @State var showComingFromKwanduh = false
  @State var showSizeScreen = false
  @State var showColorScreen = false
  @State var showTopicsScreen = false
  var body: some View {
    VStack(spacing: 20) {
      Text("Settings")
        .font(.largeTitle)
        .bold()
        .padding(.top)
      
      Text("Replacements Left: \(gameState.gimmees)")
        .font(.subheadline)
      
      Button("Size") {withAnimation {showSizeScreen = true}}
        .buttonStyle(.borderedProminent)
      
      Button("Topics"){withAnimation { showTopicsScreen = true}}
        .buttonStyle(.borderedProminent)
      //ColorSchemePickerView
      Button("Colors") {withAnimation { showColorScreen = true}}
        .buttonStyle(.borderedProminent)
      
      Button("Freeport") {withAnimation { gameState.gimmees += 5}}
        .buttonStyle(.borderedProminent)
      
      Button(action: {withAnimation { onNewRound() }} ){
        Text("Start New Round")
          .font(.title2)
          .bold()
          .frame(maxWidth: .infinity, minHeight: 60)
          .foregroundColor(.white)
          .background(Color.blue)
          .cornerRadius(10)
          .padding()
      }
      
      
      // ---- Here’s your new footer at the bottom ----
      AppInfoFooterView()
    } .sheet(isPresented: $showComingFromKwanduh){
      ComingFromKwanduhView() {
        showComingFromKwanduh = false
      }
    }
    .sheet(isPresented: $showSizeScreen) {
      BoardSizeScreen(gs: $gameState)
    }
    .sheet(isPresented: $showColorScreen) {
      ColorSchemePickerView(gs: $gameState)
    }
    .sheet(isPresented: $showTopicsScreen){/**
                                            struct TopicSelectorScreen: View {
                                              let gs:GameState
                                              let chmgr:ChaMan
                                              @Binding var  gimmeCount: Int // Gimme count passed as a binding
                                              @Binding var  isTouching: Bool
                                            */
      TopicSelectorScreen(gs: gameState,chmgr:gameState.chmgr!,
                          gimmeCount: $gameState.gimmees,
                          isTouching: .constant(false))
    }
  }
}
