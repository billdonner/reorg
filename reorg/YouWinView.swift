
// MARK: - YouWinView
struct YouWinView: View {
  let ch:Challenge
    var onNewGame: () -> Void
    var onSettings: () -> Void

    @State private var titleOffset: CGFloat = UIScreen.main.bounds.height
    @State private var confettiOpacity: Double = 1.0
    @State private var confettiActive: Bool = true

    var body: some View {
        VStack(spacing: 20) {
            // Title Bar Animation
            HStack {
                Spacer()
                Text("🎉 You Win! 🎉")
                    .font(.largeTitle)
                    .bold()
                    .offset(y: titleOffset)
                    .animation(.easeOut(duration: 1.5), value: titleOffset)
                Spacer()
                Button(action: onSettings) {
                    Image(systemName: "gear")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                .padding(.trailing)
            }
            .padding(.top, 20)
            .padding(.bottom, 10)

            Divider()

            Text("Congratulations on completing the challenge!")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
          VStack(spacing: 0) {
              // Display the Question
            Text("You answered the final question correctly:").font(.subheadline)
          
                 Text( "\(ch.question)")
                  .padding()
                  .multilineTextAlignment(.center)
          
                 Text( "\(ch.correct )")
                  .padding()
                  .multilineTextAlignment(.center)
              Spacer()
          }

            Spacer()

            Button("New Game", action: onNewGame)
                .buttonStyle(.borderedProminent)
                .padding()

            Spacer()

            // Confetti Animation
            ZStack {
                if confettiActive {
                    ForEach(0..<50) { _ in
                        Circle()
                            .fill(randomColor())
                            .frame(width: 20, height: 20)
                            .offset(x: CGFloat.random(in: -150...150), y: CGFloat.random(in: -300...300))
                            .opacity(confettiOpacity)
                    }
                }
            }
        }
        .onAppear {
            titleOffset = 0 // Animate title to rise to the top
            fadeOutConfetti() // Start confetti fade-out
        }
    }

    private func fadeOutConfetti() {
        withAnimation(.easeOut(duration: 20)) {
            confettiOpacity = 0 // Gradually fade out the confetti
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            confettiActive = false // Remove confetti entirely after fade-out
        }
    }

    private func randomColor() -> Color {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]
        return colors.randomElement() ?? .gray
    }
}
#Preview {
  YouWinView(ch: Challenge.amock, onNewGame: {}, onSettings: {})
}