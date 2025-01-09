//
//  AnswerButtonView.swift
//  qandao
//
//  Created by bill donner on 9/18/24.
//
import SwiftUI

struct SoloAnswerButtonView: View {
  internal init(answer: String, row: Int, col: Int, buttonWidth: CGFloat, buttonHeight: CGFloat, colorScheme: ColorScheme, borderColor:Color , taller:Bool = false, disabled : Bool = false, handler: @escaping (String, Int, Int) -> Void) {
    self.answer = answer
    self.row = row
    self.col = col
    self.buttonWidth = buttonWidth
    self.buttonHeight = buttonHeight
    self.colorScheme = colorScheme
    self.taller = taller
    self.borderColor = borderColor
    self.disabled = disabled
    self.handler = handler
  }
  
  let answer: String
  let row:Int
  let col:Int
  let buttonWidth: CGFloat
  let buttonHeight: CGFloat
  let colorScheme: ColorScheme
  let borderColor:Color
  let disabled:Bool
  let taller:Bool
  let handler: (String,Int,Int) -> Void
  

  var body: some View {
  Button(action: { 
    if !disabled {handler(answer,row,col)}
  },label:
    {
     // let ch = chmgr.everyChallenge[gs.board[row][col]]
      Text(answer)
        .font(isIpad ? .title:.body)
        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        .padding()
      .frame(width:max(20, buttonWidth*0.9), height: max(20,buttonHeight*0.9)) // clamp up
      .border(borderColor ,width:2)
      .background(colorScheme == .dark ? Color.black : Color.white)  // Change background based on mode
        .cornerRadius(3)  // Make the buttons rounded rectangles
        .minimumScaleFactor(0.5)  // Adjust font size to fit
        .lineLimit(8)
    }
  )
  }
}
#Preview {
  SoloAnswerButtonView(answer: "A Much Much Longish Answer", row: 0, col: 0, buttonWidth: 120, buttonHeight: 120, colorScheme: .light ,borderColor: .red   ){ _,_,_ in }.preferredColorScheme(.light)
}
#Preview {
  SoloAnswerButtonView(answer: "A Much Much Longish Answer", row: 0, col: 0, buttonWidth: 120, buttonHeight: 120, colorScheme: .dark,borderColor: .green ){ _,_,_ in }.preferredColorScheme(.dark)
}
