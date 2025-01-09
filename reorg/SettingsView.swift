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
      
      Button("Size") {showSizeScreen = true}
        .buttonStyle(.borderedProminent)
      
      Button("Topics") { showComingFromKwanduh = true}
        .buttonStyle(.borderedProminent)
      //ColorSchemePickerView
      Button("Colors") { showColorScreen = true}
        .buttonStyle(.borderedProminent)
      
      Button("Freeport") { gameState.gimmees += 5}
        .buttonStyle(.borderedProminent)
      
      Button(action: onNewRound) {
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
  }
}
