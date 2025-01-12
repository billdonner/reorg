//
//  QandAScreenExt.swift
//  basic
//
//  Created by bill donner on 8/3/24.
//

import SwiftUI


extension QandAScreen {
  func questionAndAnswersSectionVue(chmgr:ChaMan,ch:Challenge,geometry: GeometryProxy,colorScheme: ColorScheme,answerGiven:Binding<String?>,answerCorrect:Binding<Bool> ) -> some View {

    VStack(spacing: 10) {
     // let _ = print("\nQandAScreen \(ch)")
      questionSectionVue(geometry: geometry,ch:ch  )
        .frame(maxWidth: max(0, geometry.size.width), maxHeight: max(0, geometry.size.height * 0.4))//make bigger when bottom buttons gone
      //shuffle the questions
      AnswerButtonsView(row: row,col: col,answers: ch.answers.shuffled(), geometry: geometry, colorScheme: colorScheme,disabled:questionedWasAnswered,answerGiven: answerGiven,answerCorrect: answerCorrect)
      { answer,row,col in
        handleAnswerSelection(ch:ch,answer: answer,row:row,col:col)
      }
    }
    .padding(.horizontal)
    .padding(.bottom)
    
    // Invalid frame dimension (negative or non-finite).?
    .frame(maxWidth: max(0, geometry.size.width), maxHeight: max(0, geometry.size.height * 0.8))//make bigger when bottom buttons gone
  }
  
  func questionSectionVue(geometry: GeometryProxy,ch:Challenge) -> some View {
    let paddingWidth = geometry.size.width * 0.1
    let contentWidth = geometry.size.width - paddingWidth
      let topicColor =   gs.topicsinplay[ch.topic]?.toColor() ?? .red
   // let _ = print("\nquestionSectionVue \(ch)")
      
      return ZStack {
        RoundedRectangle(cornerRadius: 10).fill(topicColor.opacity(1.0))
        // Invalid frame dimension (negative or non-finite).?
        
        VStack(spacing:0) {
          HStack(spacing:10) {
            HStack(spacing:isIpad ? 25:15){
              gimmeeButton
              thumbsUpButton
              thumbsDownButton
            }
            Spacer()
    
            // hintButton
            
            Button(action: {
              showHint.toggle()
            }) {
              Image(systemName: "lightbulb")
                .font(buttFont)
              //.frame(width: buttSize, height:buttSize)
                .cornerRadius(buttRadius)
            }
            .disabled( chmgr.everyChallenge[gs.board[row][col]]
                   .hint.count <= 1 )
            .opacity( chmgr.everyChallenge[gs.board[row][col]]
          .hint.count  <= 1 ? 0.5:1.0)
          }
            .foregroundColor(foregroundColorFrom( backgroundColor: topicColor ))
            .padding([.top,.horizontal])
            .debugBorder()
          Spacer()
          Text(ch.question)
            .font(isIpad ? .largeTitle:.title3)
            .padding(.horizontal)//([.top,.horizontal])
            .lineLimit(8)
            .foregroundColor(foregroundColorFrom( backgroundColor: topicColor ))
            .frame(width: max(0,contentWidth), height:max(0,  geometry.size.height * 0.25))//0.2
            .fixedSize(horizontal: false, vertical: true)
            .debugBorder()
          Spacer()
        }
      }
      // .frame(width: max(0,contentWidth), height:max(0,  geometry.size.height * 0.33))
  
  }


}
enum QARBOp : Equatable {
  case correct(row:Int,col:Int,elapsed:TimeInterval,ch:Challenge,answered:String)
  case incorrect(row:Int,col:Int,elapsed:TimeInterval,ch:Challenge,answered:String)
  case replace(row:Int,col:Int,elapsed:TimeInterval)
  case donothing(row:Int,col:Int,elapsed:TimeInterval)
  
  func description() -> String {
    switch self {
    case .correct: return "Correct"
    case .incorrect: return "Incorrect"
    case .replace: return "Replace"
    case .donothing: return "Donothing"
    }
  }
}


extension QandAScreen {
  
//func handleDismissal(toRoot:Bool) {
//    if toRoot {
//     // withAnimation(.easeInOut(duration: 0.75)) { // Slower dismissal
//        isPresentingDetailView = false
//        dismiss()
//     // }
//    } else {
//      answerGiven = nil //showAnsweredAlert = false
//      showHint=false //  showHintAlert = false
//    }
//  }
  

  func qarbswitcher(qarb:QARBOp,chmgr:ChaMan){
    switch qarb {
      
    case .correct(let row, let col, let elapsed, let ch, let answered):
      gs.markCorrectMove(chmgr: chmgr, row: row, col:  col, ch: ch, answered:  answered, elapsedTime:  elapsed)
    case .incorrect(let row, let col, let elapsed, let ch, let answered):
      gs.markIncorrectMove(chmgr: chmgr, row: row, col:  col, ch: ch, answered:  answered, elapsedTime:  elapsed)
    case .replace(let row, let col, let elapsed):
      gs.markReplacementMove(chmgr: chmgr, row:  row, col: col, elapsedTime: elapsed)
    case .donothing :
      // should increase elapsed time
      break
    }
  }

  
  func gimmeeRequested(row:Int,col:Int,elapsed:TimeInterval){

    killTimer = true

    qarbswitcher( qarb: QARBOp.replace(row:row,col:col,elapsed:elapsed),chmgr: chmgr)
  }
  
  func noAnswerGiven(row:Int,col:Int,elapsed:TimeInterval){
    killTimer=true

    qarbswitcher( qarb: QARBOp.donothing(row:row,col:col,elapsed:elapsed),chmgr: chmgr)
  }
  
  func answeredCorrectly(_ ch:Challenge,row:Int,col:Int,answered:String,elapsed:TimeInterval) {
    answerCorrect = true
    killTimer=true
    chmgr.checkAllTopicConsistency("mark correct before")
    conditionalAssert(gs.checkVsChaMan(chmgr: chmgr,message:"answeredCorrectly"))
    qarbswitcher(  qarb: QARBOp.correct(row: row,col:col,elapsed:elapsed,ch: ch, answered: answered),chmgr: chmgr)
  }
  func answeredIncorrectly(_ ch:Challenge,row:Int,col:Int,answered:String,elapsed:TimeInterval) {
    answerCorrect = false
    killTimer=true
    chmgr.checkAllTopicConsistency("mark incorrect before")
    conditionalAssert(gs.checkVsChaMan(chmgr: chmgr,message:"answeredInCorrectly"))
    qarbswitcher(qarb:  QARBOp.incorrect(row: row,col:col,elapsed:elapsed,ch: ch, answered: answered),chmgr: chmgr)
  }
  func handleAnswerSelection(ch:Challenge,answer: String,row:Int,col:Int) {
    if !questionedWasAnswered { // only allow one answer
      //let ch = chmgr.everyChallenge[gs.board[row][col]]
      killTimer=true
      answerCorrect = (answer == ch.correct)
      questionedWasAnswered = true
      answerGiven = answer //triggers the alert
      if answerCorrect {
         answeredCorrectly(
          ch, row: row, col: col, answered: answer,
          elapsed: elapsedTime)
        
        if isWinningPath(in:gs.cellstate) {
          onYouWin()
          
        } else {
          onCorrect()
        }
      } else {
        answeredIncorrectly(
          ch, row: row, col: col, answered: answer,
          elapsed: elapsedTime)
        
        if !isPossibleWinningPath(in:gs.cellstate){
          onYouLose()
        } else {
          onIncorrect()
        }
      }
    } else {
      print("dubl tap \(answer)")
    }
  }
}
