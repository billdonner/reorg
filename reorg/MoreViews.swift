//
//  MoreViews.swift
//  reorg
//
//  Created by bill donner on 12/25/24.
//

import SwiftUI
 


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
