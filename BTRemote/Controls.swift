import SwiftUI

let groupFill = Color.secondary.opacity(0.16)
let cellGap: CGFloat = 6

struct PressGesture: ViewModifier {
    let onPress: () -> Void
    let onRelease: () -> Void
    @Binding var pressed: Bool

    func body(content: Content) -> some View {
        content.gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !pressed {
                        pressed = true
                        Haptics.tap()
                        onPress()
                    }
                }
                .onEnded { _ in
                    pressed = false
                    onRelease()
                }
        )
    }
}

struct HoldButton<Background: View, Label: View>: View {
    let onPress: () -> Void
    let onRelease: () -> Void
    @ViewBuilder var background: () -> Background
    @ViewBuilder var label: () -> Label
    var repeatInterval: TimeInterval? = nil
    @State private var pressed = false
    @State private var repeatTimer: Timer?

    var body: some View {
        ZStack {
            background()
            label().foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(pressed ? 0.5 : 1)
        .contentShape(Rectangle())
        .modifier(PressGesture(onPress: handlePress, onRelease: handleRelease, pressed: $pressed))
        .onDisappear {
            if pressed {
                pressed = false
                handleRelease()
            } else {
                stopRepeating()
            }
        }
    }

    private func handlePress() {
        onPress()
        guard let repeatInterval, repeatInterval > 0 else { return }
        stopRepeating()
        repeatTimer = Timer.scheduledTimer(withTimeInterval: repeatInterval, repeats: true) { _ in
            onPress()
        }
    }

    private func handleRelease() {
        stopRepeating()
        onRelease()
    }

    private func stopRepeating() {
        repeatTimer?.invalidate()
        repeatTimer = nil
    }
}
