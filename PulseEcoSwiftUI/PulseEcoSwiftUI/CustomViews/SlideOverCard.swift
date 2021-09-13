import SwiftUI

struct SlideOverCard<Content: View> : View {
    @GestureState private var dragState = DragState.inactive
    @State var position: CGFloat = CardPosition.middle
    
    var content: () -> Content
    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)
        
        return Group {
//            Spacer()
//            Handle()
            self.content()
        }
        .frame(height: UIScreen.main.bounds.height)
        .background(Color.white)
        .cornerRadius(30.0)
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
        .offset(y: max(self.position + self.dragState.translation.height, CardPosition.top - 120))
        .animation(self.dragState.isDragging ? nil : .interpolatingSpring(stiffness: 250, damping: 30.0, initialVelocity: 10))
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
            positionBelow = CardPosition.middle //.bottom
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

//enum CardPosition: CGFloat {
//    case top = UIScreen.main.width.bounds
//    case middle = 500
//    case bottom = 650
//}

struct CardPosition {
    static let top: CGFloat = UIScreen.main.bounds.height - 575// - 550
    static let middle: CGFloat = UIScreen.main.bounds.height - 130 //- 350
    static let bottom: CGFloat = UIScreen.main.bounds.height + 100 //- 150
}

//enum CardPosition: CGFloat {
//    case top = 100
//    case middle = 500
//    case bottom = 650
//}


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

