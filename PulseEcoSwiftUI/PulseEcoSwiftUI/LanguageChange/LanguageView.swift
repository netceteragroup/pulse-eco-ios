//
//  LanguageView.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 29.3.21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct LanguageView: View {
    
    @EnvironmentObject var appVM: AppVM
    @EnvironmentObject var dataSource: DataSource
    @EnvironmentObject var refreshService: RefreshService
    @Binding var showPicker: Bool
    @State private var showAlert = false
    @State var selectedCountry = Countries.selectedCountry(for: Trema.appLanguage)
    var countries = Countries.countries(language: Trema.appLanguage)
    
    var body: some View {
        
        VStack {
            VStack(spacing: 0) {
                Spacer()
                HStack{
                    Button(Trema.text(for: "cancel")) {
                        self.showPicker = false
                    }.padding(.leading, 20)
                    Spacer()
                        .padding([.leading], 30)
                    Button(Trema.text(for: "done")) {
                        if (self.selectedCountry.shortName != Trema.appLanguage) {
                            self.showAlert = true
                        } else {
                            self.showPicker = false
                        }
                    }.padding(.trailing, 20)
                        .alert(isPresented: $showAlert) {
                            return Alert(title: Text(Trema.text(for: "change_app_language")),
                                         message: Text(String(format: Trema.text(for: "change_language_message"),
                                                              selectedCountry.languageName)),
                                         primaryButton: .cancel(
                                            Text(Trema.text(for: "cancel")),
                                            action: { self.showAlert = false}),
                                         secondaryButton: .default (
                                            Text(Trema.text(for: "proceed")),
                                            action: {
                                                withAnimation(Animation.linear.delay(1)){
                                                    self.changeLanguage(toLanguage: self.selectedCountry.shortName)
                                                }
                                         }))
                    }
                }.frame(height: 50, alignment: .center)
                    .background(Color(AppColors.lightGray))
                    .border(Color.gray, width: 0.5)
                
                Picker("Language", selection: $selectedCountry) {
                    ForEach(countries, id: \.self) { country in
                        HStack{
                            Text(country.flagImageName)
                            Text(country.languageName)
                        }
                    }
                }.labelsHidden()
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                    .edgesIgnoringSafeArea([.leading, .trailing])
                    .background(Color(AppColors.lightGray))
                    .edgesIgnoringSafeArea(.bottom)
            }.animation(.easeInOut(duration: 0.5))
                .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    func changeLanguage(toLanguage: String) {
        self.showPicker = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Trema.appLanguage = toLanguage
            self.dataSource.loadingCityData = true
            self.dataSource.getMeasures()
            self.refreshService.updateRefreshDate()
            self.dataSource.getValuesForCity(cityName: self.appVM.cityName)
            self.appVM.updateMapAnnotations = true
            self.appVM.updateMapRegion = true
            self.appVM.selectedLanguage = toLanguage
        }
    }
    
}
