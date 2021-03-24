//
//  View+PartialSheetModifier.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 1/26/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import SwiftUI

extension View {
    /**
     Add a PartialSheet to the current view. You should attach it to your Root View.
     Use the PartialSheetManager as an environment object to present it whenever you want.
     - parameter style: The style configuration for the Partial Sheet.
     */
    public func addPartialSheet(
        style: PartialSheetStyle = PartialSheetStyle.defaultStyle()) -> some View {
        self.modifier(
            PartialSheet(
                style: style
            )
        )
    }
}
