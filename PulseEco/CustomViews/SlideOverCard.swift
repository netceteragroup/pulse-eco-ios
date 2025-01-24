import SwiftUI

struct SlideOverCard<Content: View>: View {
    @GestureState private var dragState = DragState.inactive
    @State var position: CGFloat = 0
    @Binding var height: CGFloat
    @Binding var topLimit: CGFloat
    let proxy: GeometryProxy
    
    var cardPosition: CardPosition {
        CardPosition(proxy: proxy, topLimit: topLimit, middleCardHeight: height)
    }
    
    var content: () -> Content

    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, _ in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)

        return VStack {
            self.content()
                .background(GeometryReader { geometry in
                    Color.clear
                        .onAppear() {
                            self.topLimit = geometry.size.height
                        }
                        .onChange(of: geometry.size) { newValue in
                            self.topLimit = newValue.height
                        }
                })
                .frame(maxWidth: .infinity)
                .clipped()
            Spacer()
        }
        .background(AppColors.white.color)
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
        .offset(y: max(self.position + self.dragState.translation.height, cardPosition.top - 120, 0))
        .animation(self.dragState.isDragging ? nil : .interpolatingSpring(stiffness: 250,
                                                                          damping: 30.0,
                                                                          initialVelocity: 10),
                   value: dragState.isDragging)
        .gesture(drag)
        .onAppear {
            updatePosition()
        }
        .onChange(of: [height, proxy.size.height]) { _ in
            updatePosition()
        }
    }

    private func updatePosition() {
        position = abs(height - proxy.size.height)
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
    
    init(proxy: GeometryProxy, topLimit: CGFloat, middleCardHeight: CGFloat) {
        top = abs(topLimit - proxy.size.height) - 30
        middle = abs(middleCardHeight - proxy.size.height)
        bottom = proxy.size.height + 100
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
