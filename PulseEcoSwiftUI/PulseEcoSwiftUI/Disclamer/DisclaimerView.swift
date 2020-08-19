//
//  Disclaimer.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/25/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI

struct DisclaimerView: View {
    
    @Environment(\.presentationMode) var presentationMode
    private var viewModel = DisclaimerVM()
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(uiImage: self.viewModel.disclaimerCloseImage)
                        .padding([.top, .trailing], 26.0)
                        .frame(width: 20.0, height: 22.0)
                }
            }
            Spacer()
            Image(uiImage: self.viewModel.disclaimerImage)
            Text(self.viewModel.title)
                .foregroundColor(Color(AppColors.darkblue)).padding(.vertical, 20)
            Text(self.viewModel.message)
                .font(.system(size: self.viewModel.messageFontSize))
                .foregroundColor(Color(AppColors.darkblue))
                .lineLimit(nil).multilineTextAlignment(.center)
                .padding(.horizontal, 20).fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
}
