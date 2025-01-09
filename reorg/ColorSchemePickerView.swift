import SwiftUI
struct ColorSchemePickerView: View {
    @Binding var gs: GameState
 
  
  @State var boardSize: Int = 8
  
    var colorPicker: some View {
        Picker("Color Palette", selection: $gs.currentscheme) {
            ForEach(Array(allSchemeNames.enumerated()), id: \.element) { index, name in
                Text(name)
                    .tag(index) // Use the index as the tag
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .background(colorPaletteBackground(for: gs.currentscheme).clipShape(RoundedRectangle(cornerRadius: 10)))
     
    }

    var body: some View {
        NavigationView {
          VStack{
          HStack { Spacer()
            PreviewGridView(gs: gs,  boardsize: $boardSize, scheme: $gs.currentscheme)
              .frame(width: 100, height: 100)
            Spacer()
          }
            Form {
              Section(header: Text("Color Scheme")) {
                colorPicker
                  .onChange(of: gs.currentscheme) {
                    withAnimation {
                      // Update any state or logic based on the current scheme
                      // Call the validation method to ensure all colors are present
                      //ColorManager.validateColorEntries()
                    }
                  }
              }
              
              Section(header: Text("Colors")) {
                
                
                // Use allColorsForScheme function and ensure it returns a [FreeportColor]
                List(allColorsForScheme(gs.currentscheme), id: \.self) { color in
                  //Text(color.name) // Assuming FreeportColor has a property 'name'
                  HStack {
                    Text(color.toColorName())
                    Spacer()
                    color.toColor().frame(width:100)
                  }
                }
              }
            }
                .navigationBarTitle("Choose Color Scheme")
            }
        }
    }
}

#Preview {
  ColorSchemePickerView(gs:.constant(GameState.mock))
}
