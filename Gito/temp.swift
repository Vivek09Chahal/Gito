import SwiftUI

struct AnimatedScrollView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(0..<10) { index in
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.indigo.gradient)
                        .frame(width: 250, height: 400)
                        .overlay(
                            Text("Card \(index)")
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                        )
                        // 1. Attach the visualEffect modifier
                        .visualEffect { content, proxy in
                            content
                                // 2. Calculate effects based on the X position
                                .scaleEffect(scale(for: proxy))
                                .rotation3DEffect(
                                    .degrees(rotation(for: proxy)),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                        }
                }
            }
            .padding(40)
        }
    }

    // Helper function to determine scale based on screen position
    func scale(for proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .global).minX
        let screenWidth = UIScreen.main.bounds.width

        // If the card is near the center, scale is 1.0. If it moves away, it shrinks.
        let distance = abs(screenWidth / 2 - (minX + 125))
        let scale = 1 - (distance / 1000)

        return max(0.8, scale) // Don't let it shrink below 0.8
    }

    // Helper function to add a slight 3D rotation
    func rotation(for proxy: GeometryProxy) -> Double {
        let minX = proxy.frame(in: .global).minX
        let screenWidth = UIScreen.main.bounds.width
        let distance = screenWidth / 2 - (minX + 125)

        return Double(distance / -20)
    }
}

#Preview {
    AnimatedScrollView()
}
