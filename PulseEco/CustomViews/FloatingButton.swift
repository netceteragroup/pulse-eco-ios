//
//  FloatingButton.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 27.1.25.
//

import SwiftUI

struct FloatingButton: View {
    var image: String
    var onPress: (() -> Void)
    
    init(image: String, onPress: @escaping () -> Void) {
        self.image = image
        self.onPress = onPress
    }
    
    var body: some View {
        Image(systemName: image)
            .padding()
            .background(Color(AppColors.white))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    onPress()
                }
            }
    }
}

#Preview {
    FloatingButton(image: "clock") {
        print("floating button pressed")
    }
}
