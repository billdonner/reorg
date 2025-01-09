//
//  HighWaterMarkCircleView.swift
//  dmangler
//
//  Created by bill donner on 10/13/24.
//


import SwiftUI

struct HighWaterMarkCircleView: View {
    let text: String       // Text displayed inside the circle
    let percentage: Double // Value between 0 and 1 for the high water mark
    let size: CGFloat      // Circle size
    let color: Color       // Color used for gradient
  let plainTopicIndex: Bool
  @Binding var isTouching: Bool

  var body: some View {
    
    if plainTopicIndex
    {
      ZStack {
      Circle()
        .fill(color)
        .frame(width: size, height: size)
      // Show the text inside the circle
      if isTouching {
        Text(text)
          .font(.system(size: size * 0.4, weight: .bold))
          .foregroundColor(.primary)
      }
    }
    } else {
      ZStack {
        // Background circle with low opacity color (always visible)
        Circle()
          .fill(color.opacity(0.4))
          .frame(width: size, height: size)
        
        // Gradient fill from bottom up to the high water mark
        Circle()
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [color, color.opacity(0.4)]),
              startPoint: .bottom,
              endPoint: .top
            )
          )
          .mask(
            Rectangle()
              .frame(height: size * percentage)
              .offset(y: size * (1 - percentage) / 2)  // Align gradient to bottom
          )
          .frame(width: size, height: size)
        
        // Border circle
        Circle()
          .stroke(Color.gray, lineWidth: size * 0.05)
          .frame(width: size, height: size)
        
        // Show the text inside the circle
        Text(text)
          .font(.system(size: size * 0.4, weight: .bold))
          .foregroundColor(.primary)
      }
    }
  }
}
struct TestView : View {
    // Example percentages, size, and texts for the grid
    let percentages: [Double] = [0.2, 0.4, 0.6, 0.8, 1.0, 0.3, 0.5, 0.7, 0.9]
    let texts: [String] = ["superc", "B", "C", "D", "E", "F", "G", "H", "I"]
    let colors: [Color] = [.blue, .green, .orange, .red, .purple, .yellow, .pink, .cyan, .teal]
    let circleSize: CGFloat = 100
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(0..<percentages.count, id: \.self) { index in
                    HighWaterMarkCircleView(
                        text: texts[index],
                        percentage: percentages[index],
                        size: circleSize,
                        color: colors[index],
                        plainTopicIndex: true,
                        isTouching: .constant(true)
                    )
                }
            }
            .padding()
        }
    }
}


#Preview {
  TestView()
}
