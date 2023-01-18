//
//  SettingsView.swift
//  PulseEco
//
//  Created by Veselinka Lokvenec on 10.1.23.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var refreshService: RefreshService
    
    @State var selection: Int
    @State var options: [String]
    
    
        var body: some View {
            VStack {
            Picker("View", selection: $selection) {
                ForEach(options.indices, id: \.self) { i in
                    if i == selection {
                        Text(options[i])
                        .onTapGesture {
                            background(Color(AppColors.darkblue))
                        }
                    }
                }
            }
        }
    }
}
