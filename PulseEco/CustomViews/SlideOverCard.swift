import SwiftUI

struct SlideOverCard<Content: View>: View {
    @GestureState private var dragState = DragState.inactive
    @State var position: CGFloat
    var cardPosition: CardPosition
    
    var height: CGFloat
    var content: () -> Content
    
    init(height: CGFloat, proxy: GeometryProxy, content: @escaping () -> Content) {
        self.height = height
        self.content = content

        self.cardPosition = CardPosition(proxy: proxy, fullCardHeight: 550, middleCardHeight: height)
        self.position = abs(height - proxy.size.height)
        print("position: \(self.position)")
    }
    
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
//        .frame(height: UIScreen.main.bounds.height)
        .background(AppColors.white.color)
        .cornerRadius(30.0)
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
        .offset(y: max(self.position + self.dragState.translation.height, cardPosition.top - 120, 0))
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

        if cardTopEdgeLocation <= cardPosition.middle {
            positionAbove = cardPosition.top
            positionBelow = cardPosition.middle
        } else {
            positionAbove = cardPosition.middle
            positionBelow = cardPosition.middle
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
    var top: CGFloat
    var middle: CGFloat
    var bottom: CGFloat
    
    init(proxy: GeometryProxy, fullCardHeight: CGFloat, middleCardHeight: CGFloat) {
//        top = proxy.size.height - min(fullCardHeight, proxy.size.height - 10)
        top = 65
        middle = abs(middleCardHeight - proxy.size.height)
        bottom = proxy.size.height + 100
        print("proxy height: \(proxy.size.height) - top: \(top) - middle: \(middle) - bottom: \(bottom)")
    }
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
