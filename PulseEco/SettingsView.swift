//
//  SettingsView.swift
//  PulseEco
//
//  Created by Veselinka Lokvenec on 10.1.23.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    
    @State var options = ["Dashboard view", "Map view", "Settings"] // 1
     @State var selectedItem = "Map view" // 2
    
        var body: some View {
            Picker("Pick a view", selection: $selectedItem) { // 3
                ForEach(options, id: \.self) { item in // 4
                    Text(item) // 5
                }
            }
        }
}
