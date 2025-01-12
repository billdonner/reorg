//
//  QandAButtons.swift
//  basic
//
//  Created by bill donner on 8/11/24.
//

import SwiftUI

let freeportButtons = false
let buttSize = 45.0
let buttRadius = 8.0
let buttFont : Font = isIpad ? .title : .headline

extension QandAScreen {
  
   var hintButton: some View {
       Button(action: {
         showHint.toggle()  
       }) {
           Image(systemName: "lightbulb")
               .font(buttFont)
               //.frame(width: buttSize, height:buttSize)
               .cornerRadius(buttRadius)
       }
       .disabled(chmgr.everyChallenge[gs.board[row][col]].hint.count <= 1 )
       .opacity(chmgr.everyChallenge[gs.board[row][col]].hint.count <= 1 ? 0.5:1.0)
   }
   var thumbsUpButton: some View {
       Button(action: {
         
         showThumbsUp =  chmgr.everyChallenge[row*gs.boardsize+col]
       }){
         Image(systemName: "hand.thumbsup")
           .font(buttFont)
               .cornerRadius(buttRadius)
               //.symbolEffect(.wiggle,isActive: true)
       }
   }
   var thumbsDownButton: some View {
       Button(action: {
         showThumbsDown =  chmgr.everyChallenge[row*gs.boardsize+col]
       }){
         Image(systemName: "hand.thumbsdown")
           .font(buttFont)
               .cornerRadius(buttRadius)
              // .symbolEffect(.wiggle,isActive: true)
       }
   }


   var gimmeeButton: some View {
     Button(action: {
       showReplacementPage =  chmgr.everyChallenge[row*gs.boardsize+col]
     }) {
       Image(systemName: "arrow.trianglehead.2.clockwise")
         .font(buttFont)
         //.frame(width: buttSize, height: buttSize)
         .cornerRadius(buttRadius)
     }
     .disabled(gs.gimmees<1)
     .opacity(gs.gimmees<1 ? 0.5:1)
     
   }
   var infoButton: some View {
     Button(action: {
       showInfo = true
     }) {
       Image(systemName: "info.circle")
         .font(buttFont)
        // .frame(width: buttSize, height: buttSize)
         .cornerRadius(buttRadius)
     }
   }

}
