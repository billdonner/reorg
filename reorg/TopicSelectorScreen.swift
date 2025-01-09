//
//  TopicSelectorView.swift
//  dmangler
//
//  Created by bill donner on 10/5/24.
//


import SwiftUI



func dumpTopicsAndColors(_ comment:String,from selectedTopics:[String:FreeportColor]) {
  print("---> \(comment)")
  for (topic, color) in selectedTopics {
    print("\(topic) : \(color)")
  }
}

struct TopicSelectorScreen: View {
  let gs:GameState
  let chmgr:ChaMan
  @Binding var  gimmeCount: Int // Gimme count passed as a binding
  @Binding var  isTouching: Bool
  
  // Temporary state to handle topic selections
  
  @State private var tempGimmeeCount: Int = 0
  @State private var tempTopicsInPlay: [String: FreeportColor] = [:]
  
  @State private var tempTopicsInOrder: [String] = []

  // Alert state
  @State private var showNoGimmeeAlert = false
  @State private var showMinimumSelectionAlert = false  // New alert state for minimum selection
  @State private var showMaximumSelectionAlert = false  // New alert state for maximum selection
  
  @Environment(\.presentationMode) var presentationMode
  
  var body: some View {
    NavigationView {
      VStack {
        // Use the modified TopicIndexView with a binding to tempSelectedTopics
        TopicIndexView(gs:gs,chmgr:chmgr, selectedTopics: $tempTopicsInPlay, topicsInOrder:$tempTopicsInOrder, opType: .removeTopic, isTouching: .constant(true))
          .frame(height: 100)
          .padding(.top, 8)
        
        // Gimme count display at the top
        Text("Gimmees: \(tempGimmeeCount)")
          .font(tempGimmeeCount <= 0 ? .largeTitle : .headline)
          .foregroundColor(.secondary)
          .padding(.top, 8)

        
        // List of available topics
        List {
          Section(header: Text("Available Topics")) {
            let tempAvailableTopics = removeInstances(from: chmgr.everyTopicName, removing: flattenDictionaryKeys( tempTopicsInPlay))
            ForEach(tempAvailableTopics, id: \.self) { topic in
              HStack {
                Text(topic)
                Spacer()
                Button("Add?") {
                  withAnimation {
                    addTopic(topic)
                  }
                }
               // .disabled(tempGimmeeCount <= 0)  // Disable if gimme count is zero or less
              }
            }
          }
        }
      }
      .navigationBarItems(
        leading: Button("Cancel") {
          print("Cancelling selection")
          cancelSelection()
        },
        trailing: Button("Done") {
          print("Finalizing selection")
          finalizeSelection()//save changes, sets bool below
          if !showMinimumSelectionAlert {
            presentationMode.wrappedValue.dismiss()
          }
        }
      )
      .navigationTitle("Select Topics")
      .onAppear {
        setupView()
      }

      
      .alert(isPresented: Binding<Bool>(
          get: {
              showMinimumSelectionAlert || showMaximumSelectionAlert || showNoGimmeeAlert
          },
          set: { _ in
              // Reset all alerts when dismissed
              showMinimumSelectionAlert = false
              showMaximumSelectionAlert = false
              showNoGimmeeAlert = false
          }
      )) {
          if showMinimumSelectionAlert {
            let tpc = GameState.minTopicsForBoardSize(gs.boardsize) == 1 ? "topic" : "topics"
            let msg = "Please select at least \(GameState.minTopicsForBoardSize(gs.boardsize)) \(tpc)."
            return Alert(title: Text(msg), message: nil, dismissButton: .default(Text("OK")))
          } else if showMaximumSelectionAlert {
            return Alert(title: Text("Maximum Reached"), message: Text("You cannot select more than \(GameState.maxTopicsForBoardSize(gs.boardsize)) topics."), dismissButton: .default(Text("OK")))
          } else if showNoGimmeeAlert {
              return Alert(title: Text("No Gimmees"), message: Text("You have no gimmees left to add or remove topics."), dismissButton: .default(Text("OK")))
          } else {
              return Alert(title: Text("Unknown"), message: Text("An unknown alert was triggered."), dismissButton: .default(Text("OK")))
          }
      }
    }
  }
  
  // MARK: - Action Methods
  
  private func addTopic(_ topic: String) {
    if tempGimmeeCount <= 0 {
      showNoGimmeeAlert = true
    } else
    if tempTopicsInPlay.count >= GameState.maxTopicsForBoardSize(gs.boardsize) {
      showMaximumSelectionAlert = true
    } else {
      let active = flattenDictionaryValues(tempTopicsInPlay)// active colors from topics
      let avail = removeInstances(from: availableColorsForScheme(gs.currentscheme), removing: active)
      guard  let color = avail.randomElement()  else {
        print("Could not get random Color for scheme \(gs.currentscheme) in addtopic")
        return}
      // print("Add topic \(topic) with color \(color)")
       tempTopicsInPlay[topic] = color
      tempTopicsInOrder.insert(topic,at:0) // to add to left
        tempGimmeeCount -= 1
       //dumpTopicsAndColors("added topic \(topic) with color \(color) scheme \(gs.currentscheme)",from:tempSelectedTopics)
 
    }
  }
   
  private func cancelSelection() {  // Restore the initial gimme count
    presentationMode.wrappedValue.dismiss()  // Dismiss without saving changes
  }

  private func finalizeSelection() {
    if tempTopicsInPlay.count < GameState.minTopicsForBoardSize(gs.boardsize) {
      showMinimumSelectionAlert = true
    } else {
      
      gimmeCount = tempGimmeeCount
      gs.topicsinplay = tempTopicsInPlay  // Persist the changes
      gs.topicsinorder = tempTopicsInOrder
      //dumpTopicsAndColors("finalized selection for scheme \(gs.currentscheme)", from: gs.topicsinplay)
      gs.saveGameState()
      presentationMode.wrappedValue.dismiss()  // Dismiss and save changes
    }
  }
  
  private func setupView() {
    tempGimmeeCount = gimmeCount  // Store the initial gimme count
    tempTopicsInPlay = gs.topicsinplay // Load the selected topics
    tempTopicsInOrder = gs.topicsinorder
    if tempGimmeeCount <= 0 {
      showNoGimmeeAlert = true
    }
  }
}
struct TopicSelectorView_Previews: PreviewProvider {
  @State static private var gimmeCount: Int = 5  // Example gimme count
  
  static var previews: some View {

    
    return TopicSelectorScreen(gs:GameState.mock, chmgr:ChaMan.mock, gimmeCount: $gimmeCount,isTouching:.constant(true))
      .previewLayout(.device)
      .previewDisplayName("Topic Selector View")
      .environment(\.colorScheme, .light)  // You can also test dark mode by setting .dark
  }
}

 
