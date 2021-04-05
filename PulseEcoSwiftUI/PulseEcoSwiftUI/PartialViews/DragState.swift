////
////  DragState.swift
////  PulseEcoSwiftUI
////
////  Created by Maja Mitreska on 1/26/21.
////  Copyright © 2021 Monika Dimitrova. All rights reserved.
////
//
//import SwiftUI
//
//enum DragState {
//    case inactive
//    case dragging(translation: CGSize)
//    var translation: CGSize {
//        switch self {
//        case .inactive:
//            return .zero
//        case .dragging(let translation):
//            return translation
//        }
//    }
//    var isDragging: Bool {
//        switch self {
//        case .inactive:
//            return false
//        case .dragging:
//            return true
//        }
//    }
//}
