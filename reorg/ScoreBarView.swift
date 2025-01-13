import SwiftUI

func formattedElapsedTime(_ elapsedTime: TimeInterval) -> String {
    let minutes = Int(elapsedTime) / 60
    let seconds = Int(elapsedTime) % 60
    return String(format: "%02d:%02d", minutes, seconds)
}

struct ScoreBarView: View {
    let gs: GameState
    
    var body: some View {
        let realScore: Double = gs.totaltime == 0.0
            ? 0.0
            : (Double(gs.totalScore()) * 100.0 / gs.totaltime)
        
        VStack(spacing: 16) {
            // Top row: Time, Score, Gimmees
            HStack(spacing: 32) {
                VStack {
                    Text("TIME")
                        .font(.caption)
                    Text(formattedElapsedTime(gs.totaltime))
                        .font(.system(size: 48, weight: .regular, design: .monospaced))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                
                VStack {
                    Text("SCORE")
                        .font(.caption)
                    // %.0f => no decimal places
                    Text(String(format: "%.0f", realScore))
                        .font(.system(size: 48, weight: .regular, design: .monospaced))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                
                VStack {
                    Text("GIMMEES")
                        .font(.caption)
                    Text("\(gs.gimmees)")
                        .font(.system(size: 48, weight: .regular, design: .monospaced))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
            }
            
            // Bottom row: Won, Lost, Right, Wrong
            HStack(spacing: 24) {
                VStack {
                    Text("WON")
                        .font(.caption)
                    Text("\(gs.woncount)")
                        .font(.system(size: 24, design: .monospaced))
                }
                
                VStack {
                    Text("LOST")
                        .font(.caption)
                    Text("\(gs.lostcount)")
                        .font(.system(size: 24, design: .monospaced))
                }
                
                VStack {
                    Text("RIGHT")
                        .font(.caption)
                    Text("\(gs.rightcount)")
                        .font(.system(size: 24, design: .monospaced))
                }
                
                VStack {
                    Text("WRONG")
                        .font(.caption)
                    Text("\(gs.wrongcount)")
                        .font(.system(size: 24, design: .monospaced))
                }
            }
            .opacity(0.8)
        }
        //.padding()
    }
}

#Preview {
    ScoreBarView(gs: GameState.mock)
}
