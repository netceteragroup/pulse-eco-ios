//
//  NewLanguageView.swift
//  PulseEcoSwiftUI
//
//  Created by Darko Skerlevski on 21.9.21.
//

import SwiftUI

struct NewLanguageView: View {
    
    @EnvironmentObject var appState: AppState
    //@EnvironmentObject var dataSource: AppDataSource
    //@EnvironmentObject var refreshService: RefreshService
    @State private var showAlert = false
    //@State var selectedLanguage: String? = Countries.selectedCountry(for: Trema.appLanguage).languageName
    var countries = Countries.countries(language: Trema.appLanguage)
    @State var selectedCountry: Country? = Countries.selectedCountry(for: Trema.appLanguage)
    
    var body: some View{
        VStack{
            HStack{
                //Text("Done")
                Spacer()
                Text("Select language")
                    .padding(.trailing, -45)
                Spacer()
                Button(action: {
                    self.appState.showSheet = false
                }, label: {
                    Text(Trema.text(for: "cancel"))
                })
                .padding(.trailing, 10)
            }
            .padding(.top, 20)
            List{
                ForEach(countries, id: \.self) { country in
                    SelectionCell(country: country, selectedCountry: self.$selectedCountry)
                }
            }
        }
    }
    
    struct SelectionCell: View {
        
        @EnvironmentObject var appState: AppState
        @EnvironmentObject var dataSource: AppDataSource
        @EnvironmentObject var refreshService: RefreshService
        let country: Country
        @Binding var selectedCountry: Country?
        @State var showAlert: Bool = false
        
        
        var body: some View {
            HStack {
                Text(country.languageName)
                Spacer()
                if country.shortName == selectedCountry!.shortName {
                    Image(systemName: "checkmark")
                        .foregroundColor(.black)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if (self.selectedCountry != self.country) {
                    self.showAlert = true
                }
                
            }
            .alert(isPresented: self.$showAlert) {
                 return Alert(title: Text(Trema.text(for: "change_app_language")),
                              message: Text(String(format: Trema.text(for: "change_language_message_ios"), self.country.languageName)),
                             primaryButton: .cancel(
                                Text(Trema.text(for: "cancel")),
                                action: { self.showAlert = false}),
                             secondaryButton: .default (
                                Text(Trema.text(for: "proceed")),
                                action: {
                                        self.changeLanguage(toLanguage: self.country.shortName)
                                        self.appState.showSheet = false
                                }))
            }
            
        }
        func changeLanguage(toLanguage: String) {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Trema.appLanguage = toLanguage
                self.dataSource.loadingCityData = true
                self.dataSource.getMeasures()
                self.refreshService.updateRefreshDate()
                self.dataSource.getValuesForCity(cityName: self.appState.cityName)
                self.appState.updateMapAnnotations = true
                self.appState.updateMapRegion = true
                self.appState.selectedLanguage = toLanguage
            }
        }
        
    }
}
