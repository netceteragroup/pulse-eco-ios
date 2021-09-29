//
//  NewCityListView.swift
//  PulseEcoSwiftUI
//
//  Created by Darko Skerlevski on 23.9.21.
//

import SwiftUI

struct CityListView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var refreshService: RefreshService
    @ObservedObject var viewModel: CityListViewModel
    @ObservedObject var userSettings: UserSettings
    @State var searchText = ""
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                HStack {
                    SearchBar(text: $searchText,
                              placeholder: Trema.text(for: "search_city_or_country"))
                        .padding(.leading, 10)
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text(Trema.text(for: "cancel"))
                    })
                    .padding(.trailing, 15)
                }
                
                ScrollView {
                    if self.searchText.isEmpty {
                        ForEach(self.viewModel.getCountries(), id: \.self) { elem in
                            Section(header:
                                        HStack {
                                            Text("\(elem)")
                                                .padding()
                                                .font(.system(size: 16, weight: .bold))
                                            Spacer()
                                        }
                                        .frame(height: 30)
                                        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.gray), alignment: .top)
                                        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.gray), alignment: .bottom)
                                        .background(Color(red: 250 / 255, green: 250 / 255, blue: 250 / 255))
                                        .listRowInsets(.zero)) {
                                
                                let favouriteCitiesNames = self.userSettings.favouriteCities.map{$0.cityName}
                                let citiesFromCountry = self.viewModel.getCities().filter {
                                    elem == $0.countryName
                                }
                                ForEach(citiesFromCountry, id: \.id) { city in
                                    Button(action: {
                                        if let city = self.viewModel.cityModel.first(where: { $0.cityName == city.cityName }) {
                                            self.userSettings.favouriteCities.insert(city)
                                            self.appState.cityName = city.cityName
                                            self.appState.newCitySelected = true
                                            self.presentationMode.wrappedValue.dismiss()
                                        }
                                    }, label: {
                                        CityRowView(viewModel: city,
                                                    addCheckMark: favouriteCitiesNames.contains(city.cityName),
                                                    showCountryName: false)
                                    })
                                    
                                    if (city != citiesFromCountry.last) {
                                        Divider()
                                            .background(Color.gray)
                                    }
                                }
                            }
                        }
                        Divider().background(Color.gray)
                    } else {
                        self.listCities
                    }
                    VStack {
                        Text(Trema.text(for: "city_missing_add_new"))
                            .font(.system(size: 14)).foregroundColor(Color(AppColors.gray))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        Button(action: {
                            guard let url = URL(string: "https://pulse.eco/addcity") else { return }
                            UIApplication.shared.open(url)
                        }) {
                            Text("https://pulse.eco/addcity")
                                .font(.system(size: 14))
                        }
                    }
                    .padding(.all)
                }
                .resignKeyboardOnDragGesture()
            }
            .navigationBarColor(UIColor.white)
            .navigationBarTitle("Select city", displayMode: .inline)
        }
        .if(.pad, transform: {
            $0.navigationViewStyle(StackNavigationViewStyle())
        })
    }
    
    var listCities: some View {
        
        let favouriteCitiesNames = self.userSettings.favouriteCities.map{$0.cityName}
        let foundCities = self.viewModel.getCities().filter{ $0.cityName.lowercased().contains(self.searchText.lowercased()) || $0.countryName.lowercased().contains(self.searchText.lowercased())
        }
        
        return VStack {
            ForEach(foundCities, id: \.id) { city in
                Button(action: {
                    if let city = self.viewModel.cityModel.first(where: { $0.cityName == city.cityName }) {
                        self.userSettings.favouriteCities.insert(city)
                        self.appState.cityName = city.cityName
                        self.appState.newCitySelected = true
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }, label: {
                    CityRowView(viewModel: city, addCheckMark: favouriteCitiesNames.contains(city.cityName), showCountryName: true)
                })
                if (city != foundCities.last){
                    Divider()
                        .background(Color.gray)
                }
            }
            if (foundCities.count > 0){
                Divider()
                    .background(Color.gray)
            }
        }
    }
}

extension EdgeInsets {
    static let zero = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}
