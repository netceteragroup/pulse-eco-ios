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
    @State private var disclaimer = false
    
    var body: some View {
        NavigationLink(destination: LanguageView(), isActive: $didTap) { EmptyView() }
        NavigationLink(destination: DisclaimerView(), isActive: $disclaimer) { EmptyView() }
        VStack(alignment: .leading, spacing: 0) {
            List {
                Button(action: {didTap = true}){
                    HStack {
                        Text("Change Language")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .padding()
                    }
                }
                Divider()
                Button(action: {}) {
                    HStack {
                        Text("Used Libraries")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .padding()
                    }
                }
                Divider()
                Button(action: {}) {
                    HStack {
                        Text("About pulse.eco")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .padding()
                    }
                }
                Divider()
                Button(action: {disclaimer = true}) {
                    HStack {
                        Text("Disclaimer")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .padding()
                    }
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
            HStack(alignment: .center, spacing: 33) {
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
