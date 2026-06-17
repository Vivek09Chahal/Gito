import SwiftUI

struct DragGestureView: View {
    @State private var isDragging = false

    // 1. Tracks the total distance moved during the active drag interaction
    @State private var currentOffset = CGSize.zero

    // 2. Permanently saves the position coordinate where the view was last dropped
    @State private var accumulatedOffset = CGSize.zero

    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                self.isDragging = true
                // 3. Update the temporary distance as the finger slides
                self.currentOffset = value.translation
            }
            .onEnded { value in
                self.isDragging = false
                // 4. Lock in the new coordinates permanently by combining existing and new translations
                self.accumulatedOffset.width += value.translation.width
                self.accumulatedOffset.height += value.translation.height

                // 5. Clear the temporary active offset values back to zero
                self.currentOffset = .zero
            }
    }

    var body: some View {
        Circle()
            .fill(self.isDragging ? Color.red : Color.blue)
            .frame(width: 100, height: 100)
            // 6. Combine the saved position and current active translation together
            .offset(
                x: accumulatedOffset.width + currentOffset.width,
                y: accumulatedOffset.height + currentOffset.height
            )
            // Apply a smooth spring animation when the finger lets go
//            .animation(.spring(), value: isDragging)
            .gesture(drag)
    }
}

#Preview {
    DragGestureView()
}
