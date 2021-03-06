//
//  PartialSheetViewModifier.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 1/26/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import SwiftUI
import Combine

struct PartialSheet: ViewModifier {
    
    // MARK: - Public Properties
    /// The Partial Sheet Style configuration
    var style: PartialSheetStyle
    
    // MARK: - Private Properties
    @EnvironmentObject private var manager: PartialSheetManager
    
    /// The rect containing the presenter
    @State private var presenterContentRect: CGRect = .zero
    
    /// The rect containing the sheet content
    @State private var sheetContentRect: CGRect = .zero
    
    /// The offset for keyboard height
    @State private var offset: CGFloat = 0
    
    /// The offset for the drag gesture
    @State private var dragOffset: CGFloat = 0
    
    /// The point for the top anchor
    private var topAnchor: CGFloat {
        return max(presenterContentRect.height +
            (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) -
            sheetContentRect.height - handlerSectionHeight,
                   style.minTopDistance)
    }
    
    /// The point for the bottom anchor
    private var bottomAnchor: CGFloat {
        return UIScreen.main.bounds.height + 5
    }
    
    /// The current anchor point, based if the **presented** property is true or false
    private var currentAnchorPoint: CGFloat {
        return manager.isPresented != .hidden ?
            topAnchor :
        bottomAnchor
    }
    
    /// The height of the handler bar section
    private var handlerSectionHeight: CGFloat {
        return 30
    }
    
    /// Calculates the sheets y position
    private var sheetPosition: CGFloat {
        if self.manager.isPresented != .hidden {
            let topInset = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20.0 // 20.0 = To make sure we dont go under statusbar on screens without safe area inset
            let position = self.topAnchor + self.dragOffset - self.offset
            if position < topInset {
                return topInset
            }
            
            return position
        } else {
            return self.bottomAnchor - self.dragOffset
        }
    }
    
    /// Background of sheet
    private var background: AnyView {
        switch self.style.background {
        case .solid(let color):
            return AnyView(color)
        case .blur(let effect):
            return AnyView(BlurEffectView(style: effect).background(Color.clear))
        }
    }
    
    // MARK: - Content Builders
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .background(
                    GeometryReader { proxy in
                        // Add a tracking on the presenter frame
                        Color.clear.preference(
                            key: PresenterPreferenceKey.self,
                            value: [PreferenceData(bounds: proxy.frame(in: .global))]
                        )
                    }
            )
                .onAppear{
                    let notifier = NotificationCenter.default
                    let willShow = UIResponder.keyboardWillShowNotification
                    let willHide = UIResponder.keyboardWillHideNotification
                    notifier.addObserver(forName: willShow,
                                         object: nil,
                                         queue: .main,
                                         using: self.keyboardShow)
                    notifier.addObserver(forName: willHide,
                                         object: nil,
                                         queue: .main,
                                         using: self.keyboardHide)
            }
            .onDisappear {
                let notifier = NotificationCenter.default
                notifier.removeObserver(self)
            }
            .onPreferenceChange(PresenterPreferenceKey.self, perform: { (prefData) in
                self.presenterContentRect = prefData.first?.bounds ?? .zero
            })
            
            
            // if the device type is an iPhone,
            // display the sheet content as a draggableSheet
            
            iPhoneSheet()
                .edgesIgnoringSafeArea(.vertical)
            
        }
    }
}

//MARK: - Platform Specific Sheet Builders
extension PartialSheet {
    //MARK: - Mac and iPad Sheet Builder
    /*
     //This is the builder for the sheet content for iPad and Mac devices only
     private func iPadAndMacSheet() -> some View {
     VStack {
     HStack {
     Spacer()
     Button(action: {
     self.manager.isPresented = false
     }, label: {
     Image(systemName: "xmark")
     .foregroundColor(style.handlerBarColor)
     .padding(.horizontal)
     .padding(.top)
     })
     }
     self.manager.content
     Spacer()
     }.background(self.background)
     }
     */
    //MARK: - iPhone Sheet Builder
    /// This is the builder for the sheet content for iPhone devices only
    private func iPhoneSheet()-> some View {
        // Build the drag gesture
        let drag = dragGesture()
        
        return ZStack {
            
            //MARK: - iPhone Cover View
            if manager.isPresented != .hidden {
                Group {
                    if style.enableCover {
                        Rectangle()
                            .foregroundColor(style.coverColor)
                    }
                    if style.blurEffectStyle != nil {
                        BlurEffectView(style: style.blurEffectStyle ?? UIBlurEffect.Style.systemChromeMaterial)
                    }
                }
                .edgesIgnoringSafeArea(.vertical)
                .onTapGesture {
                    withAnimation {
                        self.manager.isPresented = .hidden
                        self.dismissKeyboard()
                        self.manager.onDismiss?()
                    }
                }
            }
            // The SHEET VIEW
            Group {
                VStack(spacing: 0) {
                    // This is the little rounded bar (HANDLER) on top of the sheet
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: CGFloat(5.0) / 2.0)
                            .frame(width: 40, height: 3.0)
                            .foregroundColor(self.style.handlerBarColor)
                        Spacer()
                    }
                    .frame(height: handlerSectionHeight)
                    VStack {
                        // Attach the SHEET CONTENT
                        self.manager.content
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.preference(key: SheetPreferenceKey.self, value: [PreferenceData(bounds: proxy.frame(in: .global))])
                                }
                        )
                    }
                    Spacer()
                }
                .onPreferenceChange(SheetPreferenceKey.self, perform: { (prefData) in
                    self.sheetContentRect = prefData.first?.bounds ?? .zero
                })
                    .frame(width: UIScreen.main.bounds.width)
                    .background(self.background)
                    .cornerRadius(style.cornerRadius)
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
                    .offset(y: self.sheetPosition)
                    .gesture(drag)
            }
        }
    }
}

// MARK: - Drag Gesture & Handler
extension PartialSheet {
    
    /// Create a new **DragGesture** with *updating* and *onEndend* func
    private func dragGesture() -> _EndedGesture<_ChangedGesture<DragGesture>> {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged(onDragChanged)
            .onEnded(onDragEnded)
    }
    
    private func onDragChanged(drag: DragGesture.Value) {
        self.dismissKeyboard()
        let yOffset = drag.translation.height
        let threshold = CGFloat(-50)
        let stiffness = CGFloat(0.3)
        if yOffset > threshold {
            dragOffset = drag.translation.height
        } else if
            // if above threshold and belove ScreenHeight make it elastic
            -yOffset + self.sheetContentRect.height <
                UIScreen.main.bounds.height + self.handlerSectionHeight
        {
            let distance = yOffset - threshold
            let translationHeight = threshold + (distance * stiffness)
            dragOffset = translationHeight
        }
    }
    
    /// The method called when the drag ends. It moves the sheet in the correct position based on the last drag gesture
    private func onDragEnded(drag: DragGesture.Value) {
        /// The drag direction
        //        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        
        // Set the correct anchor point based on the vertical direction of the drag
        if drag.translation.height < -50 {
            DispatchQueue.main.async {
                withAnimation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0)) {
                    self.dragOffset = 0
                    self.manager.isPresented = .expanded
                    //self.manager.onDismiss?()
                }
            }
        } else if drag.translation.height > 50 {
            withAnimation {
                dragOffset = 0
                self.manager.isPresented = .hidden
            }
        } else {
            /// The current sheet position
            let cardTopEdgeLocation = topAnchor + drag.translation.height
            
            // Get the closest anchor point based on the current position of the sheet
            let closestPosition: CGFloat
            
            if (cardTopEdgeLocation - topAnchor) < (bottomAnchor - cardTopEdgeLocation) {
                closestPosition = topAnchor
            } else {
                closestPosition = bottomAnchor
            }
            
            withAnimation {
                dragOffset = 0
                if closestPosition == topAnchor {
                    self.manager.isPresented = .expanded
                } else {
                    self.manager.isPresented = .partial
                }
                if manager.isPresented == .hidden {
                    manager.onDismiss?()
                }
            }
        }
    }
}

// MARK: - Keyboard Handlers Methods
extension PartialSheet {
    
    /// Add the keyboard offset
    private func keyboardShow(notification: Notification) {
        let endFrame = UIResponder.keyboardFrameEndUserInfoKey
        if let rect: CGRect = notification.userInfo![endFrame] as? CGRect {
            let height = rect.height
            let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom
            withAnimation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0)) {
                self.offset = height - (bottomInset ?? 0)
            }
        }
    }
    
    /// Remove the keyboard offset
    private func keyboardHide(notification: Notification) {
        DispatchQueue.main.async {
            withAnimation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0)) {
                self.offset = 0
            }
        }
    }
    
    /// Dismiss the keyboard
    private func dismissKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        DispatchQueue.main.async {
            UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - PreferenceKeys Handlers
extension PartialSheet {
    
    /// Preference Key for the Sheet Presener
    struct PresenterPreferenceKey: PreferenceKey {
        static func reduce(value: inout [PartialSheet.PreferenceData], nextValue: () -> [PartialSheet.PreferenceData]) {
            value.append(contentsOf: nextValue())
        }
        static var defaultValue: [PreferenceData] = []
    }
    
    /// Preference Key for the Sheet Content
    struct SheetPreferenceKey: PreferenceKey {
        static func reduce(value: inout [PartialSheet.PreferenceData], nextValue: () -> [PartialSheet.PreferenceData]) {
            value.append(contentsOf: nextValue())
        }
        static var defaultValue: [PreferenceData] = []
    }
    
    /// Data Stored in the Preferences
    struct PreferenceData: Equatable {
        let bounds: CGRect
    }
    
}

struct PartialSheetAddView<Base: View, InnerContent: View>: View {
    @EnvironmentObject var partialSheetManager: PartialSheetManager
    
    @Binding var isPresented: PartialSheetState
    let content: () -> InnerContent
    let base: Base
    
    @State var model = Model()
    
    var body: some View {
        
        if model.update(value: isPresented) != .hidden {
            DispatchQueue.main.async(execute: updateContent)
        }
        return base
    }
    
    func updateContent() {
        partialSheetManager.updatePartialSheet(isPresented: isPresented, content: content, onDismiss: {
            self.isPresented = .expanded
        })
    }
    
    // hack around .onChange not being available in iOS13
    class Model {
        private var savedValue: PartialSheetState = .hidden
        func update(value: PartialSheetState) -> PartialSheetState {
            guard value != savedValue else { return .hidden }
            savedValue = value
            return .expanded
        }
    }
}

public extension View {
    func partialSheet<Content: View>(isPresented: Binding<PartialSheetState>, @ViewBuilder content: @escaping () -> Content) -> some View {
        PartialSheetAddView(isPresented: isPresented, content: content, base: self)
    }
}
