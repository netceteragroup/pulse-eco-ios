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
    @Binding var showPicker: Bool
    @State private var showAlert = false
    @State var selectedCountry = Countries.selectedCountry(for: UserDefaults.standard.string(forKey: "AppLanguage") ?? "en")
    var countries = Countries.countries(language: UserDefaults.standard.string(forKey: "AppLanguage") ?? "en")
    
    var body: some View {
        
        VStack {
            VStack(spacing: 0) {
                Spacer()
                HStack{
                    Button(Trema.text(for: "cancel", language: self.appVM.appLanguage)) {
                        self.showPicker = false
                    }.padding(.leading, 20)
                    Spacer()
                        .padding([.leading], 30)
                    Button(Trema.text(for: "done", language: self.appVM.appLanguage)) {
                        if (self.selectedCountry.shortName != self.appVM.appLanguage) {
                            self.showAlert = true
                        } else {
                            self.showPicker = false
                        }
                    }.padding(.trailing, 20)
                        .alert(isPresented: $showAlert) {
                            return Alert(title: Text(Trema.text(for: "change_app_language", language: self.appVM.appLanguage)),
                                         message: Text(String(format: Trema.text(for: "change_language_message",
                                                                                 language: self.appVM.appLanguage),
                                                              selectedCountry.languageName)),
                                         primaryButton: .destructive(
                                            Text(Trema.text(for: "cancel", language: self.appVM.appLanguage)),
                                            action: { self.showAlert = false}),
                                         secondaryButton: .default (
                                            Text(Trema.text(for: "proceed", language: self.appVM.appLanguage)),
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
            }.animation(.linear(duration: 0.8))
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    func changeLanguage(toLanguage: String) {
        self.showPicker = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.appVM.appLanguage = toLanguage
            UserDefaults.standard.set(toLanguage, forKey: "AppLanguage")
            self.dataSource.loadingCityData = true
            self.dataSource.getMeasures()
            self.dataSource.getValuesForCity(cityName: self.appVM.cityName)
        }
    }
    
}
