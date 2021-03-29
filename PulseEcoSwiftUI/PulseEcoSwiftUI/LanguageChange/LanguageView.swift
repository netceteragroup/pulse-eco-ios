//
//  Language.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 16.3.21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct LanguageView: View {
    
    @EnvironmentObject var appVM: AppVM
    @Binding var showPicker: Bool
    @State private var showAlert = false
    @State private var buttonDisabled = false
    @State var selectedCountry = Countries.selectedCountry(for: UserDefaults.standard.string(forKey: "AppleLanguage") ?? "en")
    var countries = Countries.countries(language: UserDefaults.standard.string(forKey: "AppleLanguage") ?? "en")
    
    var body: some View {
        
        VStack {
            VStack(spacing: 0) {
                Spacer()
                HStack{
                    Button(Trema.text(for: "Cancel", lang: self.appVM.appLanguage)) {
                        self.showPicker = false
                    }.padding(.leading, 20)
                    
                    Spacer()
                        .padding([.leading], 30)
                    
                    Button(Trema.text(for: "Done", lang: self.appVM.appLanguage)) {
                        
                        if (self.selectedCountry.shortName != self.appVM.appLanguage) {
                            self.showAlert = true
                        } else {
                            self.showPicker = false
                        }
                    }.padding(.trailing, 20)
                        .alert(isPresented: $showAlert) {
                            return Alert(title: Text(Trema.text(for: "Change App Language", lang: self.appVM.appLanguage)),
                                         message: Text(String(format: Trema.text(for: "Change language message",
                                                                                 lang: self.appVM.appLanguage),
                                                              selectedCountry.languageName)),
                                         
                                         primaryButton: .destructive(
                                            Text(Trema.text(for: "Cancel", lang: self.appVM.appLanguage)),
                                            action: { self.showAlert = false}),
                                         secondaryButton: .default (
                                            Text(Trema.text(for: "Proceed", lang: self.appVM.appLanguage)), action: {
                                                withAnimation(Animation.linear.delay(1)){
                                                    self.changeLanguage(toLanguage: self.selectedCountry.shortName)
                                                }
                                         }))
                    }
                }.frame(height: 50, alignment: .center)
                    .background(Color(red: 0.97, green: 0.96, blue: 0.94, opacity: 1))
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
                    .background(Color(red: 0.97, green: 0.96, blue: 0.94, opacity: 1))
                    .edgesIgnoringSafeArea(.bottom)
            }//.transition(.move(edge: .bottom))
                .animation(.linear(duration: 0.8))
                .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    func changeLanguage(toLanguage: String) {
        self.showPicker = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.appVM.appLanguage = toLanguage
            UserDefaults.standard.set(toLanguage, forKey: "AppleLanguage")
        }
    }
    
}
