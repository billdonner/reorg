//
//  Page1.swift
//  AllAboard
//
//  Created by bill donner on 11/5/24.
//

import SwiftUI

let totalPages = 17

#Preview {
Page14()
//OuterOnboardingView(isOnboardingComplete: .constant(false))
}

// was OB13
struct Page1: View {
  var body: some View {
    VStack {
  Spacer()
      Image("Watermark")
        .resizable()
        .scaledToFit()
   //     .frame(width:300, height:300)
        .padding()
        
      Text("Do you know enough to win?")
        .font(.title2)
        .bold()
  
        ScrollView {

            Text(
                """
                    In this game where you start in one corner of a grid and have to get to the corner diagonally opposite, a question pops up whenever you touch a square on the board. If you answer the question correctly, you move towards your goal.  If not, you're blocked and you have to find a different way to reach the far corner. Questions come from a stash of 5000, divided into 50 topics.  You choose the topics in your game.
                    """
            
            )
        }
         .padding()
         .font(.title3)

        

      Text("If you win and how fast depends on how much you know. . .")
        .font(.title2)
        .bold()
        .padding()
 
    }

    }
  }
#Preview {
  Page1()
}


//was ob06
struct Page6: View {
 var body: some View {
      ZStack {
  Spacer()
          VStack {
  
              Text("Your goal is to create a path of correctly answered questions from one corner of the grid to the corner diagonally opposite it.\n\n")
                  .font(.title2)
                  .padding()
 
         HStack {
             VStack {
                 Text("Going Up")
                     .font(.title3)
  
                 Image("Up")
                     .resizable()
                     .scaledToFit()
   
             }
                 VStack{
                     Text("or Going Down")
                         .font(.title3)
 
                     Image("Down")
                         .resizable()
                         .scaledToFit()
                 }
                 
             }
                  
          }
  
        }
      }
    }
  

#Preview {
  Page6()
}



#Preview {
  Page1()
}
//was OB02
struct Page2: View {
  var body: some View {
    ZStack {

      VStack {
        Text("How to Play Kwanduh")
          .font(.title2)
          .bold()
  
          .padding()

        Image("GameBoard")
          .resizable()
          .scaledToFit()
 
          .padding()

        Text(
          "The Kwanduh game board is a grid of color-coded boxes. Each color represents a different topic."
        )
        .font(.title2)
 
        .padding()
     }
    }
  }
}
#Preview {
  Page2()
}
//was OB11
struct Page3: View {
  var body: some View {
 
      VStack {

        Text("Press on a box and a question related to that topic pops up.")
          .font(.title2)
  
          .padding()
        Image("QuestionAnswer")
          .resizable()
          .scaledToFit()
          .padding()
      }
  }
}

#Preview {
  Page3()
}

// was ob40
struct Page4: View {
  var body: some View {
      ZStack {
Spacer()
        VStack {
 
            ScrollView {
                
                Text(
                    """
\n\n 
If you don't like the question, you can ask for another one. Hit the 'gimme' icon in the upper left corner of the question box.
""")
                    .font(.title3)
 
                    .padding()

            }
            Spacer()
            
         Image("PointToGimme")
         .resizable()
         .scaledToFit()
  
                .padding()
 
            ScrollView {
                Text(
"""
Gimmes are tokens which you collect when you win games. You buy new questions using gimmes.
""")
                    .font(.title3)
                    .padding()
                Spacer()
            }
 
        }
      }
    }
  }

#Preview {
  Page4()
}


//was ob04
struct Page5: View {
  var body: some View {
    VStack (alignment: .center, spacing:0 )
      {
  
     ScrollView {
        
        Text(
          "If you answer the question correctly, a green square is displayed in the box. \n\nIf you answer the question incorrectly, a red square is displayed."
        ).font(.title2)
        
      }
      .padding()
        Spacer()
        
        Image("Questions")
          .resizable()
          .scaledToFit()
          .padding()
      
      Spacer(minLength: 100)
    }.padding()
  }
}

#Preview {
  Page5()
}





struct Page11: View {
  var body: some View {
      VStack {
Spacer()
        Text("When there is no game being played, the game board fades to gray.  If you tap the circular menu icon in the upper right of the game screen you can select topics, change the size of your game board, and choose a different color scheme.")
          .font(.title2)

              .padding()

        Image("MenuPointer")
          .resizable()
          .scaledToFit()
          .padding()
Spacer()
      }
    }
  }

#Preview {
  Page11()
}

struct Page12: View {
  var body: some View {

    ZStack {

      VStack {
        Text(
          "On the Select Topics Screen you increase your odds of winning by choosing topics you know well. You can add and remove topics until you're satisfied."
        )
        .font(.title2)
 
        .padding()

        Image("Topics")
          .resizable()
          .scaledToFit()
  
          .padding()

      }
    }
  }
}
#Preview {
  Page12()
}

struct Page13: View {
  var body: some View {
      ZStack {
        VStack {
            
            ScrollView{
                Text(
"""
 \n\nAcross the top of the screen is a row of colored circles with a topic name beneath each. These are the topics you've currently chosen for your games. 
""")
        .font(.title2)
 
Spacer()
            }
            .padding()
  
            Image("Topics")
              .resizable()
              .scaledToFit()
              .padding()
            Spacer()
 
            Text("To remove a topic, click on the circle for that topic.")
                .padding()
                .font(.title2)
            Spacer()
     



        }
      }
    }
  }
#Preview {
  Page13()
}


struct Page14: View {
  var body: some View {
      ZStack {
  Spacer()
        VStack {
  Spacer()
            ScrollView{
   
                Text(
                    """
Topics you can add are listed under the 'Available Topics' heading. To add a topic, click on the 'Add' button next to the topic. To see all your Chosen topics, swipe left on the Chosen Topics.
""")
  
            }
            .font(.title2)
            .padding()

  Spacer()
            
            Image("Topics")
              .resizable()
              .scaledToFit()
              .padding()
 Spacer()
            
            Text("You use gimmes to buy new topics.")
                .font(.title2)
                .padding()
            Spacer()
 
        }
      }
    }
  }
#Preview {
  Page14()
}

struct Page15: View {
    var body: some View {
        
        VStack(alignment: .leading,spacing: 20)
        {
            Spacer()
            Image("TopicNumbers")
                .resizable()
                .scaledToFit()
            
            ScrollView {
                
                Text(
 """
 The number in the center of the circle is the number of questions left in that topic.  Every topic starts with 100 questions.  The same question is never given twice so as you play a certain topic, the number of questions left decreases.\n\nWhen the number of questions reaches 0, the topic will disappear from your screen.\n\nThere must always be enough questions in your chosen topics to assign a question to each box in your gameboard.  If you don't have enough questions, you'll be prompted to add topics or make your board size smaller.
 """
                )
                
            }
            .padding()
        }
        
    }
}
#Preview {
  Page15()
}

struct Page16: View {
    var body: some View {
        
        
        ZStack {

            VStack {
 
                ScrollView{
                    Text(
                        """
To change the size of the game board or the color scheme, tap on your preference in the row of options.
"""
                    )
                    .font(.title2)
                    .padding()              }
                    

                    Text("Game Board")
                        .font(.title2)
                    Image("GameBoardSize")
                        .resizable()
                        .scaledToFit()
   
                    Text("Color Scheme")
                        .font(.title2)
                    Image("ColorScheme")
                        .resizable()
                        .scaledToFit()
                }
  
                    .padding()
            }
        }
        
    }
    

 
#Preview {
  Page16()
}

struct Page17: View {
  var body: some View {
 

      VStack {

        Image("Watermark")  // Name of your watermark image
          .resizable()
          .scaledToFit()
          .padding()
      }
  }
}
#Preview {
  Page17()
}



struct Page8: View {
  var body: some View {
      ZStack {
          VStack {
              Text("A winning path doesn't have to be a straight line as long as it goes from one diagonal corner to another.  Here are examples of winning boards.")
                  .font(.title3)
 
                  .padding()
       
                  Image("NotStraight1")
                      .resizable()
                      .scaledToFit()
   
                      .padding()
             }
          }
  
        }
      }
    

#Preview {
  Page8()
}

struct Page9: View {
  var body: some View {
      ZStack {
          VStack {
 
                  Image("NotStraight2")
                      .resizable()
                      .scaledToFit()
 
             }
          }
  
        }
      }
    

#Preview {
  Page9()
}

struct Page10: View {
  var body: some View {
      ZStack {
          VStack {
 
                  Image("NotStraight3")
                      .resizable()
                      .scaledToFit()
 
                  
             }
          }
  
        }
      }
    

#Preview {
  Page10()
}

struct Page7: View {
    var body: some View {
        ZStack {
            
            VStack {
                Text("You can't use black boxes to make your paths. These are 'Roadblocks' you must get around to win. ")
                    .font(.title3)
   
                    .padding()
                
                Image("BlackBoxes")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
            }
        }
    }
}

#Preview {
  Page7()
}

// OnboardingView shows  paginated screens with exit and play options
struct OnboardingView: View {
  let pageIndex: Int
  var body: some View {

    switch pageIndex {
    case 0: Page1()
    case 1: Page2()
    case 2: Page3()
    case 3: Page4()
    case 4: Page5()
    case 5: Page6()
    case 6: Page7()
    case 7: Page8()
    case 8: Page9()
    case 9: Page10()
    case 10: Page11()
    case 11: Page12()
    case 12: Page13()
    case 13: Page14()
    case 14: Page15()
    case 15: Page16()
    case 16: Page17()

    default:
      Image(systemName: "gamecontroller")
        .resizable()
        .scaledToFit()
        .frame(width: 100, height: 100)
        .padding()

      // Display a sample title and description for each onboarding page
      Text("Dummy Feature \(pageIndex + 1)")
        .font(.largeTitle)
        .padding()

      Text(
        "Put your own content here. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent interdum tincidunt erat, ut convallis lorem faucibus in."
      )
      .multilineTextAlignment(.center)
      .padding(.horizontal)
    }

  }

}

struct OuterOnboardingView: View {
  @Binding var isOnboardingComplete: Bool

  @State private var currentPage = 0

  var body: some View {
    ZStack(alignment: .topTrailing) {

      TabView(selection: $currentPage) {
        ForEach(0..<totalPages, id: \.self) { index in
          OnboardingView(pageIndex: currentPage)
         
        }
      }
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
      // Dismiss button in the upper-right corner
            Button(action: {
                isOnboardingComplete = true
            }) {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding()
                    .foregroundColor(.gray)
            }
        }
    .background(Color.gray.opacity(0.2).ignoresSafeArea())    }

}

//// Single onboarding page with text, image, and exit/play buttons
///
// Single onboarding page with text, image, and exit/play buttons
//private struct OnboardingPageView: View {
//  //let pageIndex: Int
//  let totalPages: Int
//  @Binding var isOnboardingComplete: Bool
//  @Binding var currentPage: Int
//
//  var body: some View {
//    VStack(spacing: 20) {
//      Spacer()
//
//      OnboardingView(pageIndex: currentPage)
//
//      Spacer()
//
//      // Exit button allows users to skip onboarding
//      HStack {
//        if currentPage == 0 {
//          Button("PLAY") {
//            isOnboardingComplete = true
//          }.buttonStyle(.borderedProminent)
//        } else {
//          Button("Exit") {
//            isOnboardingComplete = true
//          }
//        }
//        Spacer()
//
//        // Display Next button or Play button on the last page
//        if currentPage < totalPages - 1 {
//          Button("Next") {
//            withAnimation {
//              currentPage += 1
//            }
//          }
//          .buttonStyle(.borderedProminent)
//        } else {
//          Button("PLAY") {
//            isOnboardingComplete = true
//          }
//          .buttonStyle(.borderedProminent)
//        }
//      }
//    }
//    .padding()
//    .background(Color(UIColor.systemBackground))
//    .cornerRadius(15)
//    .shadow(radius: 10)
//    .padding(.horizontal)
//  }
//}
//struct OnboardingPageView: View {
//    let pageIndex: Int
//    let totalPages: Int
//    @Binding var isOnboardingComplete: Bool
//    @Binding var currentPage: Int
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Spacer()
//
//            // Display a sample title and description for each onboarding page
//            Text("Game Feature \(pageIndex + 1)")
//                .font(.largeTitle)
//                .padding()
//
//            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent interdum tincidunt erat, ut convallis lorem faucibus in.")
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//
//            // Placeholder image
//            Image(systemName: "gamecontroller")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 100, height: 100)
//                .padding()
//
//            Spacer()
//
//            // Exit button allows users to skip onboarding
//            HStack {
//
//                Button("Exit") {
//                    isOnboardingComplete = true
//                }
//                .padding()
//              Spacer()
//
//            // Display Next button or Play button on the last page
//            if pageIndex < totalPages - 1 {
//                Button("Next") {
//                    withAnimation {
//                        currentPage += 1
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//            } else {
//                Button("Play") {
//                    isOnboardingComplete = true
//                }
//                .buttonStyle(.borderedProminent)
//            }
//            }
//        }
//        .padding()
//        .background(Color(UIColor.systemBackground))
//        .cornerRadius(15)
//        .shadow(radius: 10)
//        .padding(.horizontal)
//    }
//}
//struct SampleOnboardingView: View {
//    @Binding var isOnboardingComplete: Bool
//    private let totalPages = 3
//    @State private var currentPage = 0
//
//    var body: some View {
//        VStack {
//            TabView(selection: $currentPage) {
//                ForEach(0..<totalPages, id: \.self) { index in
//                    OnboardingPageView(
//                        pageIndex: index,
//                        totalPages: totalPages,
//                        isOnboardingComplete: $isOnboardingComplete,
//                        currentPage: $currentPage
//                    )
//                }
//            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
//        }
//    }
//}
