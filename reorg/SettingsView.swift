//
//  SettingsView.swift
//  reorg
//
//  Created by bill donner on 12/25/24.
//

import SwiftUI
// MARK: - SettingsView
struct SettingsView: View {
  var gameState: GameState
  var onNewRound: () -> Void
  @State var showComingFromKwanduh = false
  var body: some View {
    VStack(spacing: 20) {
      Text("Settings")
        .font(.largeTitle)
        .bold()
        .padding(.top)
      
      Text("Replacements Left: \(gameState.gimmees)")
        .font(.subheadline)
      
      Button("Size") {showComingFromKwanduh = true}
        .buttonStyle(.borderedProminent)
      
      Button("Topics") { showComingFromKwanduh = true}
        .buttonStyle(.borderedProminent)
      
      Button("Colors") { showComingFromKwanduh = true}
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
  }
}
