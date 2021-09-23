//
//  LanguageView.swift
//  PulseEcoSwiftUI
//
//  Created by Darko Skerlevski on 21.9.21.
//

import SwiftUI

struct LanguageView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var refreshService: RefreshService
    
    var countries = Countries.countries(language: Trema.appLanguage)
    @State var selectedCountry: Country? = Countries.selectedCountry(for: Trema.appLanguage)
    @State var tappedCountry: Country?
    
    var body: some View {
        NavigationView {
            VStack {
                List{
                    ForEach(countries, id: \.self) { country in
                        CountryCellView(country: country,
                                      checked: country == self.selectedCountry,
                                      action: { tappedCountry in
                                        self.tappedCountry = tappedCountry
                                      })
                        
                    }
                }
            }
            .navigationBarColor(UIColor.white)
            .navigationBarTitle("Select language", displayMode: .inline)
            .navigationBarItems(trailing:
                                    Button(action: {
                                        self.appState.showSheet = false
                                    }, label: {
                                        Text(Trema.text(for: "cancel"))
                                    })
            )
        }
        
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
        self.refreshService.updateRefreshDate()
        self.dataSource.getValuesForCity(cityName: self.appState.cityName)
        self.appState.updateMapAnnotations = true
        self.appState.updateMapRegion = true
        self.appState.showSheet = false
    }
}

private struct CountryCellView: View {
    let country: Country
    let checked: Bool
    let action: (Country) -> ()
    
    var body: some View {
        HStack {
            Text(country.languageName)
            Spacer()
            if checked {
                Image(systemName: "checkmark")
                    .foregroundColor(.black)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !checked {
                action(country)
            }
        }
    }
}
