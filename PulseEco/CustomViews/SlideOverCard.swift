import SwiftUI

struct SlideOverCard<Content: View>: View {
    @GestureState private var dragState = DragState.inactive
    @State var position: CGFloat = CardPosition.middle

    var content: () -> Content
    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, _ in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)

        return VStack {
            self.content()
            Spacer()
        }
        .frame(height: UIScreen.main.bounds.height)
        .background(AppColors.white.color)
        .cornerRadius(30.0)
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
        .offset(y: max(self.position + self.dragState.translation.height, CardPosition.top - 120, 0))
        .animation(self.dragState.isDragging ? nil : .interpolatingSpring(stiffness: 250,
                                                                          damping: 30.0,
                                                                          initialVelocity: 10),
                   value: dragState.isDragging)
        .gesture(drag)
    }

    private func onDragEnded(drag: DragGesture.Value) {
        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardTopEdgeLocation = self.position + drag.translation.height
        let positionAbove: CGFloat
        let positionBelow: CGFloat
        let closestPosition: CGFloat

        if cardTopEdgeLocation <= CardPosition.middle {
            positionAbove = CardPosition.top
            positionBelow = CardPosition.middle
        } else {
            positionAbove = CardPosition.middle
            positionBelow = CardPosition.middle
        }

        if (cardTopEdgeLocation - positionAbove) < (positionBelow - cardTopEdgeLocation) {
            closestPosition = positionAbove
        } else {
            closestPosition = positionBelow
        }

        if verticalDirection > 0 {
            self.position = positionBelow
        } else if verticalDirection < 0 {
            self.position = positionAbove
        } else {
            self.position = closestPosition
        }
    }
}

struct CardPosition {
    private static let fullCardHeight: CGFloat = min(550, UIScreen.main.bounds.height)
    private static let middleCardHeight: CGFloat = 125
    static let top: CGFloat = UIScreen.main.bounds.height - fullCardHeight // - 550
    static let middle: CGFloat = UIScreen.main.bounds.height - middleCardHeight // - 350
    static let bottom: CGFloat = UIScreen.main.bounds.height + 100 // - 150
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)

    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }

    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}
