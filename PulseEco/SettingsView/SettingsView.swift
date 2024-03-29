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
    
    @State private var didTap = false
    @State private var disclaimer = false
    @State private var flag = false

    
    var body : some View {
        
        NavigationLink(destination: LanguageView(), isActive: $didTap) { EmptyView() }
        NavigationLink(destination: AboutView(), isActive: $flag) { EmptyView() }
        NavigationLink(destination: DisclaimerView(), isActive: $disclaimer) { EmptyView() }
        
        VStack(alignment: .leading, spacing: 0) {
            List {
                Button(action: {didTap = true}){
                    HStack {
                        Text(Trema.text(for: "settings_option_sub_title_language"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .padding()
                    }
                }
                Divider()
                Button(action: {}) {
                    HStack {
                        Text(Trema.text(for: "settings_option_title_libraries"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .padding()
                    }
                }
                Divider()
                Button(action: {flag = true}) {
                    HStack {
                        Text(Trema.text(for: "settings_option_title_about"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .padding()
                    }
                }
                Divider()
                Button(action: {disclaimer = true}) {
                    HStack {
                        Text(Trema.text(for: "disclaimer"))
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
                    Text(Trema.text(for: "settings_view"))
                        .foregroundColor(Color(AppColors.darkblue))
                        .font(.system(size: 14, weight: .semibold))
                }
            }
        }))
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                HStack {
                    Image(uiImage: UIImage(named: "logo-pulse") ?? UIImage())
                        .imageScale(.large)
                        .padding(.trailing, (UIWidth)/2.7)
                        
                            }
                        }
        }
    }
}
