import SwiftUI

struct BoardSizeScreen: View {

  @Binding var gs: GameState
  @Binding var showSettings: Bool
  @State private var l_boardsize: Int
  @State var firstOnAppear = true
  @State private var showSizeChangeAlert = false
  @State var cpv: [[Color]] = []
  
  @Environment(\.dismiss) var dismiss
  
  init(  gs: Binding<GameState>, //lrdb: LeaderboardService,
       showSettings: Binding<Bool>) {
    self._gs = gs
    self._showSettings = showSettings
    l_boardsize = gs.boardsize.wrappedValue
  }
  
  
  var body: some View {
    NavigationView {
      Form {
        
        Section(header: Text("Board")) {
          VStack(alignment: .center) {
            SizePickerView(chosenSize: $l_boardsize)
            
            
            PreviewGridView(gs: gs,  boardsize: $l_boardsize, scheme: $gs.currentscheme)
              .frame(width: 200, height: 200)
          }
        }
        
        
        Section(header: Text("About QANDA")) {
          VStack {
            HStack { Spacer()
              AppVersionInformationView(
                name: AppNameProvider.appName(),
                versionString: AppVersionProvider.appVersion(),
                appIcon: AppIconProvider.appIcon()
              )
              Spacer()
            }
            
          }
        }
      }
      .onAppear {
        if firstOnAppear {
          firstOnAppear = false
         // gs.chmgr.checkAllTopicConsistency("BoardSizeScreen onAppear")
        }
        cpv = gs.previewColorMatrix(size: l_boardsize, scheme: gs.currentscheme)
        TSLog("SettingsScreen onAppear")
      }
      .navigationBarTitle("Choose Board Size")
      .navigationBarItems(
        leading: Button("Cancel") {
          dismiss()
        },
        trailing: Button("Done") {
     onDonePressed()
          /* adjust */
          dismiss()
        })
    }
  }
  private func onDonePressed() {
      // Copy every change into GameState
    gs.boardsize = l_boardsize
      gs.board = Array(repeating: Array(repeating: -1, count: l_boardsize), count: l_boardsize)
      gs.cellstate = Array(repeating: Array(repeating: .unplayed, count: l_boardsize), count: l_boardsize)
      gs.moveindex = Array(repeating: Array(repeating: -1, count: l_boardsize), count: l_boardsize)
      gs.onwinpath = Array(repeating: Array(repeating: false, count: l_boardsize), count: l_boardsize)
      gs.replaced = Array(repeating: Array(repeating: [], count: l_boardsize), count: l_boardsize)

    //gs. checkAllTopicConsistency("BoardSizeScreen onDonePressed")
      gs.saveGameState()
  }
}


#Preview {
  BoardSizeScreen(gs: .constant(GameState.mock), showSettings: (.constant(true)))
}
struct SizePickerView: View {
   @Binding   var chosenSize: Int
    var body: some View {
        // Horizontal Picker
        Picker("Select a number", selection: $chosenSize) {
          ForEach(3...8, id: \.self) { number in
            Text("\(number)x\(number)").tag(number)
          }
        }
        .pickerStyle(SegmentedPickerStyle())

    }
    
    // Function to return a paragraph of text based on the selected number
    func descriptionForNumber(_ number: Int) -> (String ,String){
        switch number {
        case 3:
            return ("Three is often considered a lucky number in various cultures and represents harmony, wisdom, and understanding.","9 cells, face up, play anywhere")
        case 4:
            return ("Four is a number of stability and balance, symbolizing the four elements, four seasons, and four cardinal directions.","16 cells, face up, play anywhere")
        case 5:
            return ("Five is associated with dynamic energy and the balance between material and spiritual aspects of life.","25 cells, face down, play anywhere")
        case 6:
            return ("Six is often seen as a number of love, family, and domestic happiness, representing harmony and balance.","36 cells, face down, corner rules")
        case 7:
            return ("Seven is a mystical number, often associated with spiritual awakening, introspection, and inner wisdom.","49 cells,face down,corner rules")
        case 8:
            return ("Eight is a symbol of abundance, success, and material wealth, often seen as a number of power and ambition.","64 cells,face down, corner rules")
        default:
            return ("","")
        }
    }
}
struct PreviewGridView : View {
  let gs:GameState
  @Binding var  boardsize: Int
  @Binding var  scheme:ColorSchemeName
  
  var body: some View {
    AltGridView(gs: gs,
                 boardsize:boardsize,
                scheme:scheme
    )
  }
}
#Preview ("PreviewGridView") {
  PreviewGridView(gs: GameState.mock,
                  boardsize: .constant(GameState.mock.boardsize),
                  scheme:.constant(2)
     )
  .frame(width: 300,height: 300)
}

struct AltGridView : View {
  let gs:GameState

  let boardsize: Int
  let scheme: ColorSchemeName
   
  var body: some View { 
    let spacing: CGFloat = 1.0 * (isIpad ? 1.2 : 1.0)
    return   GeometryReader { geometry in
      let totalSpacing = spacing * CGFloat(boardsize + 1)
      let axisSize = min(geometry.size.width, geometry.size.height) - totalSpacing
      let cellSize = (axisSize / CGFloat(boardsize)) //* shrinkFactor  // Apply shrink factor
      let colorPreviewValues:[[Color]] = gs.previewColorMatrix(size: boardsize , scheme: scheme)
      VStack(alignment:.center, spacing: spacing) {
        ForEach(0..<boardsize, id: \.self) { row in
          HStack(spacing:0) {
            Spacer(minLength:spacing/2)
            ForEach(0..<boardsize, id: \.self) { col in
              // i keep getting row and col out of bounds, so clamp it
              if row < boardsize  && col < boardsize
              { // ensure its inbounds and allocated
                  let color = colorPreviewValues[row][col]
                  color
                    .frame(width: cellSize, height: cellSize)
                }
                   
              else {
                Color.clear
                  .frame(width: cellSize, height: cellSize)
              }
              Spacer(minLength:spacing/2)
            }
          }
        }
      }
    }
  }
}

struct AppVersionInformationView: View {
   // # 1
  let name:String
    let versionString: String
    let appIcon: String

    var body: some View {
        //# 1
        HStack(alignment: .center, spacing: 12) {
          // # 2
           VStack(alignment: .leading) {
               Text("App")
                   .bold()
               Text("\(name)")
           }
           .font(.caption)
           .foregroundColor(.primary)
            //# 3
            // App icons can only be retrieved as named `UIImage`s
            // https://stackoverflow.com/a/62064533/17421764
            if let image = UIImage(named: appIcon) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
           // # 4
            VStack(alignment: .leading) {
                Text("Version")
                    .bold()
                Text("v\(versionString)")
            }
            .font(.caption)
            .foregroundColor(.primary)
        }
        //# 5
        .fixedSize()
        //# 6
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("App version \(versionString)")
    }
}


struct AppVersionInformationView_Previews: PreviewProvider {
  static var previews: some View {
    AppVersionInformationView(
        name:AppNameProvider.appName(),
        versionString: AppVersionProvider.appVersion(),
        appIcon: AppIconProvider.appIcon()
    )
  }
}
