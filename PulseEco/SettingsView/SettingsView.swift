//
//  SettingsView.swift
//  PulseEco
//
//  Created by Veselinka Lokvenec on 20.1.23.
//

import Foundation
import SwiftUI

struct SettingsView : View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var refreshService: RefreshService
    
    @State private var didTap = false
    
    var body: some View {
        NavigationLink(destination: LanguageView(), isActive: $didTap) { EmptyView() }
        VStack(alignment: .leading, spacing: 0) {
            List {
                Button(action: {}) {
                    Text("My Account")
                }
                Divider()
                Button(action: {didTap = true}){
                    Text("Change Language")
                }
                Divider()
                Button(action: {}) {
                    Text("Used Libraries")
                }
                Divider()
                Button(action: {}) {
                    Text("Disclaimer")
                }
                
                
            }
            .listRowInsets(EdgeInsets())
            .listStyle(SidebarListStyle())
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColor(AppColors.white)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            HStack(alignment: .center, spacing: 25) {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(AppColors.darkblue))
                        .font(.system(size: 14, weight: .semibold))
                    Text("SETTINGS")
                        .foregroundColor(Color(AppColors.darkblue))
                        .font(.system(size: 14, weight: .semibold))
                }
                Spacer()
                Image(uiImage: UIImage(named: "logo-pulse") ?? UIImage())
                    .imageScale(.large)
                    //.padding(.trailing, (UIWidth)/4)
            }
            //.padding(.trailing, 8)
        }))
    }
}
