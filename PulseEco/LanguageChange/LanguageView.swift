//
//  LanguageView.swift
//  PulseEcoSwiftUI
//
//  Created by Darko Skerlevski on 21.9.21.
//

import SwiftUI

struct LanguageView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var refreshService: RefreshService
    
    var countries = Countries.countries(language: Trema.appLanguage)
    @State var selectedCountry: Country? = Countries.selectedCountry(for: Trema.appLanguage)
    @State var tappedCountry: Country?
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(countries, id: \.self) { country in
                        VStack(spacing: 0) {
                            Button {
                                if (self.selectedCountry != country) {
                                    self.tappedCountry = country
                                }
                            } label: {
                                CountryCellView(country: country,
                                                checked: country == self.selectedCountry)
                            }
                            .padding()
                            Divider()
                        }
                        .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarColor(AppColors.white)
            .navigationBarTitle(Trema.text(for: "change_app_language"), displayMode: .inline)
            .navigationBarItems(trailing:
                                    Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                    }, label: {
                                        Text(Trema.text(for: "cancel"))
                                    })
            )
        }
        .if(.pad, transform: {
            $0.navigationViewStyle(StackNavigationViewStyle())
        })
        
        
        .alert(item: $tappedCountry) { item in
            return Alert(title: Text(Trema.text(for: "change_app_language")),
                         message: Text(String(format: Trema.text(for: "change_language_message_ios"),
                                              tappedCountry?.languageName ?? "")),
                         primaryButton: .cancel(
                            Text(Trema.text(for: "cancel")),
                            action: { self.tappedCountry = nil }),
                         secondaryButton: .default (
                            Text(Trema.text(for: "proceed")),
                            action: {
                                self.selectCountry(country: item)
                            }))
        }
    }
    
    
    func selectCountry(country: Country) {
        self.tappedCountry = nil
        self.selectedCountry = country
        Trema.appLanguage = country.shortName
        self.appState.selectedLanguage = Trema.appLanguage
        self.dataSource.getMeasures()
        self.dataSource.loadingMeasures = true
        self.refreshService.updateRefreshDate()
        self.dataSource.getValuesForCity(cityName: self.appState.selectedCity.cityName)
        presentationMode.wrappedValue.dismiss()
    }
}

private struct CountryCellView: View {
    let country: Country
    let checked: Bool
    
    var body: some View {
        HStack {
            Text(country.languageName)
            Spacer()
            if checked {
                Image(systemName: "checkmark")
                    .foregroundColor(Color(AppColors.darkblue))
            }
        }
    }
}