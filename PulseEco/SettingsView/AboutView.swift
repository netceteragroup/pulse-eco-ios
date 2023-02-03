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
            Text("Pulse.eco is a crowdsourcing platform, which gathers and presents environmental data. Our network of sensor installations and other third-party sources gathers the data and translates them into visual and easy to understand information. You can learn about the pollution, humidity, temperature or noise in your surroundings with just a few clicks. Even better, you can participate in expanding our network and setup your own devices, to enrich the data sourcing.")
                .padding()
                .frame(width: 400)
                .lineSpacing(10)
        }
        .navigationTitle("About pulse.eco")
        .navigationBarBackButtonHidden(true)
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

