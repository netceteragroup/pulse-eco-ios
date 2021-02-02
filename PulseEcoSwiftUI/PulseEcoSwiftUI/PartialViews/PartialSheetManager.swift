//
//  PartialSheetManager.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 1/26/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

public enum PartialSheetState: String {
    case hidden
    case partial
    case expanded
}




public class PartialSheetManager: ObservableObject {
    
    // Published var to present or hide the partial sheet
    @Published var isPresented: PartialSheetState = .hidden {
        didSet {
            if isPresented == .hidden {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                    self?.content = AnyView(EmptyView())
                    self?.onDismiss = nil
                }
            }
        }
    }
    // The content of the sheet
    @Published private(set) var content: AnyView
    // the onDismiss code runned when the partial sheet is closed
    
    private(set) var onDismiss: (() -> Void)?
    
    public init() {
        self.content = AnyView(EmptyView())
    }

    /*
      Presents a **Partial Sheet**  with a dynamic height based on his content.
     - parameter content: The content to place inside of the Partial Sheet.
     - parameter onDismiss: This code will be runned when the sheet is dismissed.
     */
    public func showPartialSheet<T>(_ onDismiss: (() -> Void)?, @ViewBuilder content: @escaping () -> T) where T: View {
        self.content = AnyView(content())
        self.onDismiss = onDismiss
        DispatchQueue.main.async {
            withAnimation {
                self.isPresented = .expanded
            }
        }
    }

    /*
     Updates some properties of the **Partial Sheet**
    - parameter isPresented: If the partial sheet is presented
    - parameter content: The content to place inside of the Partial Sheet.
    - parameter onDismiss: This code will be runned when the sheet is dismissed.
    */
    public func updatePartialSheet<T>(isPresented: PartialSheetState? = nil, content: (() -> T)? = nil, onDismiss: (() -> Void)?) where T: View {
        if let content = content {
            self.content = AnyView(content())
        }
        if let onDismiss = onDismiss {
            self.onDismiss = onDismiss
        }
        if let isPresented = isPresented {
            withAnimation {
                self.isPresented = isPresented
            }
        }
    }

    // Close the Partial Sheet and run the onDismiss function if it has been previously specified
    public func closePartialSheet() {
        self.isPresented = .hidden
        self.onDismiss?()
    }
}
