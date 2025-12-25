//
//  FloatingButton.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 27.1.25.
//

import SwiftUI

struct FloatingButton: View {
    let image: String?
    let text: String?
    let onPress: (() -> Void)
    
    init(image: String, onPress: @escaping () -> Void) {
        self.image = image
        self.onPress = onPress
        text = nil
    }
    
    init(text: String, onPress: @escaping () -> Void) {
        self.text = text
        self.onPress = onPress
        image = nil
    }
    
    var body: some View {
        contentView
    }
    
    @ViewBuilder
    private var contentView: some View {
        if let image {
            Image(uiImage: UIImage(named: image) ?? UIImage())
                .padding()
                .background(Color(AppColors.white))
                .tint(Color(AppColors.firstButtonColor))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        onPress()
                    }
                }
        }
        if let text {
            Text(text)
                .font(.headline)
                .foregroundColor(Color(AppColors.firstButtonColor))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(AppColors.white))
                .frame(width: 70, height: 70)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        onPress()
                    }
                }
        }
    }
}

#Preview {
    FloatingButton(image: "clock") {
        print("floating button pressed")
    }
}
