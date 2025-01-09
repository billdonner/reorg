//
//  File.swift
//  qandao
//
//  Created by bill donner on 9/19/24.
//

import SwiftUI
  

struct AnswerButtonsView: View {

  
  let row: Int
  let col: Int
  let answers:[String]
  let geometry: GeometryProxy
  let colorScheme: ColorScheme
  let disabled: Bool
  @Binding var answerGiven: String?
  @Binding var answerCorrect: Bool
  let handler: (String,Int,Int) -> Void //{ answer,row,col in handleAnswerSelection(answer: answer,row:row,col:col)}
  
  func colorForBorder() -> Color {
    if answerGiven != nil {
       if answerCorrect {return .green} else {return .red}
    }
      if colorScheme == .dark {return Color.white}  else {return Color.black}
  }
  var body: some View
  {
    
    
    let paddingWidth = geometry.size.width * 0.1
    let contentWidth = geometry.size.width - paddingWidth
    
    if answers.count >= 5 {
      let buttonWidth = (contentWidth / 2.5) - 10 // Adjust width to fit 2.5 buttons
      let buttonHeight = buttonWidth * 1.57 // 57% higher than the four-answer case
      return AnyView(
        VStack {
          ScrollView(.horizontal) {
            HStack(spacing: 15) {
              ForEach(Array(answers.enumerated()), id: \.offset) { index, answer in
                SoloAnswerButtonView(answer: answer, row: row, col: col, buttonWidth: buttonWidth, buttonHeight: buttonHeight, colorScheme: colorScheme, borderColor: colorForBorder(), taller: true) { answer,row,col in handler(answer,row,col)}
              }
            }
            .padding(.horizontal)
            .disabled(disabled)  // Disable all answer buttons after an answer is given
          }
          Image(systemName: "arrow.right")
            .foregroundColor(.gray)
            .padding(.top, 10)
        }
          .frame(width: contentWidth) // Set width of the scrolling area
      )
    } else if answers.count == 3 {
      return AnyView(
        VStack(spacing: 15) {
          SoloAnswerButtonView(answer: answers[0], row: row, col: col, buttonWidth: contentWidth / 2, buttonHeight: contentWidth / 2, colorScheme: colorScheme, borderColor: colorForBorder()  ) { answer,row,col in handler(answer,row,col)}
          HStack {
            SoloAnswerButtonView(answer: answers[1], row: row, col: col, buttonWidth: contentWidth / 2.5, buttonHeight: contentWidth / 2.5, colorScheme: colorScheme, borderColor: colorForBorder() )  { answer,row,col in handler(answer,row,col)}
            SoloAnswerButtonView(answer: answers[2], row: row, col: col, buttonWidth: contentWidth / 2.5, buttonHeight: contentWidth / 2.5, colorScheme: colorScheme, borderColor: colorForBorder() )  { answer,row,col in handler(answer,row,col)}
          }
        }
          .padding(.horizontal)
          .disabled(disabled)  // Disable all answer buttons after an answer is given
      )
    } else {
      let buttonWidth = min(geometry.size.width / 3 - 20, isIpad ? 200:100) * 1.5
      let buttonHeight = buttonWidth * 0.8 // Adjust height to fit more lines
      return AnyView(
        VStack(spacing: 10) {
          HStack {
            SoloAnswerButtonView(answer: answers[0], row: row, col: col, buttonWidth: buttonWidth, buttonHeight: buttonHeight, colorScheme: colorScheme,borderColor: colorForBorder()) { answer,row,col in handler(answer,row,col)}
            SoloAnswerButtonView(answer: answers[1], row: row, col: col, buttonWidth: buttonWidth, buttonHeight: buttonHeight, colorScheme: colorScheme, borderColor: colorForBorder() ) { answer,row,col in handler(answer,row,col)}
          }
          HStack {
            SoloAnswerButtonView(answer: answers[2], row: row, col: col, buttonWidth: buttonWidth, buttonHeight: buttonHeight, colorScheme: colorScheme, borderColor: colorForBorder() ) { answer,row,col in handler(answer,row,col)}
            SoloAnswerButtonView(answer: answers[3], row: row, col: col, buttonWidth: buttonWidth, buttonHeight: buttonHeight, colorScheme: colorScheme, borderColor: colorForBorder() ) { answer,row,col in handler(answer,row,col)}
          }
        }
          .padding(.horizontal)
          .disabled(disabled)  // Disable all answer buttons after an answer is given
      )
    }
  }
}
