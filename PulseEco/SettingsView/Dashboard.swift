//
//  Dashboard.swift
//  PulseEco
//
//  Created by Veselinka Lokvenec on 15.2.23.
//

import Foundation
import SwiftUI

struct Dashboard : View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    
    var body : some View {
        VStack {
            HStack {
                Text("Dashboard View")
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColor(AppColors.white)
    }
}
