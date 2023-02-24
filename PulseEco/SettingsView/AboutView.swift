//
//  AboutView.swift
//  PulseEco
//
//  Created by Veselinka Lokvenec on 3.2.23.
//

import Foundation
import SwiftUI

struct AboutView : View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    
    var body: some View {
        VStack {
            Text(Trema.text(for: "settings_about_pulse_eco_paragraph"))
                .padding()
                .frame(width: 400)
                .lineSpacing(10)
        }
        .navigationTitle(Text(Trema.text(for: "settings_about_pulse_eco_paragraph")))
        .navigationBarBackButtonHidden(true)
        .navigationBarColor(AppColors.white)
        .navigationBarItems(leading:
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }, label: {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(Color(AppColors.darkblue))
                                        .font(.system(size: 14, weight: .semibold))
                                })
        )

               
    }
    
}

