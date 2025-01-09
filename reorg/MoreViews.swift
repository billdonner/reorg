//
//  MoreViews.swift
//  reorg
//
//  Created by bill donner on 12/25/24.
//

import SwiftUI
 

// MARK: - YouLoseView
struct YouLoseView: View {
var onNewGame: () -> Void
var onSettings: () -> Void

@State private var titleOffset: CGFloat = -UIScreen.main.bounds.height
@State private var animationCompleted = false

var body: some View {
    VStack(spacing: 20) {
        // Title Bar Animation
        HStack {
            Spacer()
            Text("😢 You Lose 😢")
                .font(.largeTitle)
                .bold()
                .offset(y: titleOffset)
                .opacity(animationCompleted ? 1 : 0) // Ensure title fades in
            Spacer()
            Button(action: onSettings) {
                Image(systemName: "gear")
                    .font(.title)
                    .foregroundColor(.primary)
            }
            .padding(.trailing)
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
        .onAppear {
            startBounceAnimation()
        }

        Divider()

        Text("Don't worry, try again and you'll do better!")
            .multilineTextAlignment(.center)
            .padding(.horizontal)

        Spacer()

        Button("New Game", action: onNewGame)
            .buttonStyle(.borderedProminent)
            .padding()

        Spacer()

        LatinGunkView()
    }
}

private func startBounceAnimation() {
    withAnimation(.easeInOut(duration: 0.8)) {
        titleOffset = UIScreen.main.bounds.height * 0.3 // Bounce to the bottom
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0)) {
            titleOffset = 0 // Return to the top
            animationCompleted = true // Ensure the title is fully visible
        }
    }
}
}

// MARK: - YouWinView
struct YouWinView: View {
    var onNewGame: () -> Void
    var onSettings: () -> Void

    @State private var titleOffset: CGFloat = UIScreen.main.bounds.height
    @State private var confettiOpacity: Double = 1.0
    @State private var confettiActive: Bool = true

    var body: some View {
        VStack(spacing: 20) {
            // Title Bar Animation
            HStack {
                Spacer()
                Text("🎉 You Win! 🎉")
                    .font(.largeTitle)
                    .bold()
                    .offset(y: titleOffset)
                    .animation(.easeOut(duration: 1.5), value: titleOffset)
                Spacer()
                Button(action: onSettings) {
                    Image(systemName: "gear")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                .padding(.trailing)
            }
            .padding(.top, 20)
            .padding(.bottom, 10)

            Divider()

            Text("Congratulations on completing the challenge!")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button("New Game", action: onNewGame)
                .buttonStyle(.borderedProminent)
                .padding()

            Spacer()

            // Confetti Animation
            ZStack {
                if confettiActive {
                    ForEach(0..<50) { _ in
                        Circle()
                            .fill(randomColor())
                            .frame(width: 20, height: 20)
                            .offset(x: CGFloat.random(in: -150...150), y: CGFloat.random(in: -300...300))
                            .opacity(confettiOpacity)
                    }
                }
            }
        }
        .onAppear {
            titleOffset = 0 // Animate title to rise to the top
            fadeOutConfetti() // Start confetti fade-out
        }
    }

    private func fadeOutConfetti() {
        withAnimation(.easeOut(duration: 20)) {
            confettiOpacity = 0 // Gradually fade out the confetti
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            confettiActive = false // Remove confetti entirely after fade-out
        }
    }

    private func randomColor() -> Color {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]
        return colors.randomElement() ?? .gray
    }
}
// MARK: - ThumbsUpView
struct ThumbsUpView: View {
  let ch:Challenge
  var onBackToQandA: () -> Void

  @State private var cloudKitManager = CloudKitManager.shared
  @State private var message: String = ""
  @State private var selectedFeeling: String = "Insightful"
  @State private var showAlert = false
  
  let positiveFeelings = ["Good Explanation", "Good Hint",   "Stimulating", "Insightful", "Brilliant","Fun Fact","Interesting Fact","Other"]
  @Environment(\.dismiss) var dismiss  // Environment value for dismissing the view
  
  var body: some View {
    NavigationView {
      VStack {
        TextField("Enter thumbs up message", text: $message)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding()
        
        Picker("Select a feeling", selection: $selectedFeeling) {
          ForEach(positiveFeelings, id: \.self) { feeling in
            Text(feeling)
          }
        }
        .pickerStyle(MenuPickerStyle())
        .padding()
        
        Button(action: {
          if !cloudKitBypass {
            
            let timestamp = Date()
            cloudKitManager.saveLogRecord(
              message: message,
              sentiment: "Thumbs Up",
              predefinedFeeling: selectedFeeling,
              timestamp: timestamp,
              challengeIdentifier: ch.id
            ) { result in
              switch result {
              case .success(let record):
                print("Successfully saved positive sentiment record: \(record)")
                dismiss()
              case .failure(let error):
                print("Error saving positive sentiment record: \(error)")
                showAlert = true
              }
            }
          }
          else {
            dismiss() // dont send to cloudkit
          }
        }) {
          Text("Submit Thumbs Up")
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .alert(isPresented: $showAlert) {
          Alert(title: Text("Error"), message: Text(cloudKitManager.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
        }
      }
      .padding()

    }
    .withTitleBar(title: "Thumbs Up", onDismiss: onBackToQandA)
    .background(Color(.systemBackground))
  }
}
#Preview("Positive") {
  ThumbsUpView(ch:Challenge.amock ){}
}
// MARK: - ThumbsDownView
struct ThumbsDownView: View {
  let ch:Challenge
  var onBackToQandA: () -> Void

    let negativeFeelings = ["Incorrect", "Crazy", "Illogical", "Confusing", "Bad Explanation","Bad Hint","Boring", "I Hate It","Other"]
    @State private var cloudKitManager = CloudKitManager.shared
    @State private var message: String = ""
    @State private var selectedFeeling: String = "Incorrect"
    @State private var showAlert = false
    @Environment(\.dismiss) var dismiss  // Environment value for dismissing the view
    
    var body: some View {
      NavigationView {
        VStack {
          TextField("Enter thumbsdown message", text: $message)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
          
          Picker("Select a feeling", selection: $selectedFeeling) {
            ForEach(negativeFeelings, id: \.self) { feeling in
              Text(feeling)
            }
          }
          .pickerStyle(MenuPickerStyle())
          .padding()
          
          Button(action: {
            if !cloudKitBypass {
              
              let timestamp = Date()
              cloudKitManager.saveLogRecord(
                message: message,
                sentiment: "Thumbs Down",
                predefinedFeeling: selectedFeeling,
                timestamp: timestamp,
                challengeIdentifier:   ch.id
              ) { result in
                switch result {
                case .success(let record):
                  print("Successfully saved negative sentiment record: \(record)")
                  dismiss()
                case .failure(let error):
                  print("Error saving negative sentiment record: \(error)")
                  showAlert = true
                }
              }
            }
          }) {
            Text("Submit Thumbs Down")
              .padding()
              .background(Color.red)
              .foregroundColor(.white)
              .cornerRadius(8)
          }
          .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(cloudKitManager.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
          }
        }
        .padding()
       // .navigationTitle("Send Thumbs Down")
//        .toolbar {
//          ToolbarItem(placement: .navigationBarTrailing) {
//            Button(action: {
//              dismiss()
//            }) {
//              Image(systemName: "xmark")
//                .foregroundColor(.primary)  // Adjust the color as needed
//            }
//          }
//        }
      }
    .withTitleBar(title: "Thumbs Down", onDismiss:onBackToQandA)
    .background(Color(.systemBackground))
  }
}
#Preview("Negative") {
  ThumbsDownView(ch: Challenge.amock  ){}
}
// MARK: - HintView
struct HintView: View {

  let ch: Challenge
  var onBackToQandA: () -> Void
  var body: some View {
    NavigationView {
      VStack {
        Text(ch.hint )
          .padding()
      }
    } 
    .withTitleBar(title: "Hint", onDismiss: onBackToQandA)
    .background(Color(.systemBackground))
  }
}
#Preview("Hint") {
  HintView(ch: Challenge.amock  ){}
}
// MARK: - HintView
struct ReplacementPageView : View {

  let ch: Challenge
  var onBackToQandAPlus: (Challenge?) -> Void
  var body: some View {
    NavigationView {
      VStack {
        Text(         "I will replace this Question \nwith another from the same topic, \nif possible").font(.title)
          .padding()
        Text("I will charge you one gimmee")
      }
   
    .navigationTitle(Text("Replacement"))
    .navigationBarItems(
      leading: Button("Cancel") {
        onBackToQandAPlus(nil)
      },
      trailing: Button("Done") {
        onBackToQandAPlus(Challenge.bmock)
     
      })
    .background(Color(.systemBackground))
  }
  }
}
#Preview("ReplacementPageView") {
  ReplacementPageView(ch: Challenge.amock  ){ch in }
}
// MARK: - CorrectlyAnsweredView
struct CorrectlyAnsweredView: View {
  var challenge:Challenge
    var onBackToGame: () -> Void
  var body: some View {
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
        .withTitleBar(title: "Answered Correctly", onDismiss: onBackToGame)
        .background(Color(.systemBackground))
    }
}
#Preview("Correct") {
  CorrectlyAnsweredView(challenge: Challenge.amock, onBackToGame: {})
}
// MARK: - IncorrectlyAnsweredView
struct IncorrectlyAnsweredView: View {
    var challenge: Challenge
    var onBackToQandA: () -> Void
    var body: some View {
      VStack(spacing: 0) {
          // Display the Question
        Text("You answered incorrectly:").font(.subheadline)
        Spacer()
             Text( "\(challenge.question)")
              .padding()
              .multilineTextAlignment(.center)
        Spacer()
        Text("The correct answer was:")
             Text( "\(challenge.correct )")
              .padding()
              .multilineTextAlignment(.center)
          Spacer()
      }
        .withTitleBar(title: "Answered Incorrectly", onDismiss: onBackToQandA)
        .background(Color(.systemBackground))
    
    }
}
#Preview("InCorrect"){
  IncorrectlyAnsweredView(challenge:Challenge.amock, onBackToQandA: {})
}
// MARK: - FreePortView
struct FreePortView: View {
  var gameState: GameState
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Add 5 to Replacement Counter Button
            Button(action: {
                gameState.gimmees += 5
            }) {
                Text("Add 5 Replacements")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .withTitleBar(title: "FreePort", onDismiss: onDismiss)
        .background(Color(.systemBackground))
    }
}
// MARK: - ComingFromKwanduhView
struct ComingFromKwanduhView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("It will be the exact same for now.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .withTitleBar(title: "Coming from Kwanduh", onDismiss: onDismiss)
        .background(Color(.systemBackground))
    }
}
#Preview {
  ComingFromKwanduhView(){}
}
// MARK: - AppInfoFooterView

/// A small footer that displays the app’s name, version, and build,
/// using data from Info.plist (CFBundleName, CFBundleShortVersionString, CFBundleVersion).
struct AppInfoFooterView: View {
    // Grab values from Info.plist
    private let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown App"
    private let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0"
    private let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"

    var body: some View {
        Text("\(appName) v\(appVersion) (Build \(appBuild))")
            .font(.footnote)
            .foregroundColor(.primary)
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 1)
            )
            .padding(.bottom, 12)
    }
}
// MARK: - TitleBarModifier
struct TitleBarWithDismiss: ViewModifier {
    var title: String
    var onDismiss: () -> Void

    func body(content: Content) -> some View {
        VStack(spacing: 20) {
            // Top Bar
            HStack {
                Spacer()
                Text(title)
                    .font(.title)
                    .bold()
                Spacer()
              Button(action: onDismiss) {
                  Image(systemName: "xmark")
                      .font(.title)
                      .foregroundColor(.primary)
              }
              .padding(.trailing)
            }
            .padding(.top, 20)
            .padding(.bottom, 10)

            Divider()

            // Main Content
            content
        }
    }
}

extension View {
    func withTitleBar(title: String, onDismiss: @escaping () -> Void) -> some View {
        self.modifier(TitleBarWithDismiss(title: title, onDismiss: onDismiss))
    }
}
