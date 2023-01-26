//
//  SettingsView.swift
//  PulseEco
//
//  Created by Veselinka Lokvenec on 20.1.23.
//

import Foundation
import SwiftUI

struct SettingsView : View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var refreshService: RefreshService
    
    var body: some View {
        VStack {
            Label("My Account", systemImage: "arrow.forward")
            
            Label("Change Language", systemImage: "arrow")
            
            Text("About Pulse.Eco")
        }
    }
}
