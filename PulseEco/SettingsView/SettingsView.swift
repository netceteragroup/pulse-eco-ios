//
//  SettingsView.swift
//  PulseEco
//
//  Created by Veselinka Lokvenec on 20.1.23.
//

import Foundation
import SwiftUI

enum SettingsSubView {
    case language
    case libraries
    case about
    case disclaimer
}

struct SettingsView : View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    
    var body : some View {
        
        VStack(alignment: .leading, spacing: 0) {
            List {
                NavigationLink(Trema.text(for: "settings_option_sub_title_language"), value: SettingsSubView.language)
                NavigationLink(Trema.text(for: "settings_option_title_libraries"), value: SettingsSubView.libraries)
                NavigationLink(Trema.text(for: "settings_option_title_about"), value: SettingsSubView.about)
                NavigationLink(Trema.text(for: "disclaimer"), value: SettingsSubView.disclaimer)
            }
            .listRowInsets(EdgeInsets())
            .listStyle(SidebarListStyle())
            .navigationDestination(for: SettingsSubView.self) { subView in
                switch subView {
                case .about:
                    AboutView()
                case .disclaimer:
                    DisclaimerView()
                case .language:
                    LanguageView()
                case .libraries:
                    Text("Libraries")
                }
            }
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
