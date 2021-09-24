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
    
    
    var body: some View {
        NavigationView{
            VStack {
                HStack {
                    SearchBar(text: self.$viewModel.searchText,
                              placeholder: Trema.text(for: "search_city_or_country"))
                        .padding(.leading, 10)
                    Button(action: {
                        self.appState.showSheet = false
                    }, label: {
                        Text(Trema.text(for: "cancel"))
                    })
                    .padding(.trailing, 15)
                }
                ScrollView {
                    if self.viewModel.searchText.isEmpty {
                        ForEach(self.viewModel.getCountries(), id: \.self) { elem in
                            Section(header: HStack {
                                Text("\(elem)")
                                    .padding()
                                Spacer()
                            }.frame(height: 30)
                            .background(Color(red: 250 / 255, green: 250 / 255, blue: 250 / 255))
                            .listRowInsets(EdgeInsets(
                                            top: 0,
                                            leading: 0,
                                            bottom: 0,
                                            trailing: 0))
                            ) {
                                let favouriteCitiesNames = self.userSettings.favouriteCities.map{$0.cityName}
                                ForEach(self.viewModel.getCities().filter {
                                    elem == $0.countryName
                                }, id: \.id) { city in
                                    CityRowView(viewModel: city, addCheckMark: favouriteCitiesNames.contains(city.cityName)).onTapGesture {
                                        if let city = self.viewModel.cityModel.first(where: { $0.cityName == city.cityName }) {
                                            self.userSettings.favouriteCities.insert(city)
                                            self.appState.cityName = city.cityName
                                            self.appState.newCitySelected = true
                                            self.presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                    Divider()
                                        .background(Color.gray)
                                }
                            }
                        }
                    } else {
                        self.listCities
                    }
                    Text(Trema.text(for: "city_missing_add_new"))
                        .multilineTextAlignment(.center)
                    Button(action: {
                        guard let url = URL(string: "https://pulse.eco/addcity") else { return }
                        UIApplication.shared.open(url)
                    }) {
                        Text("https://pulse.eco/addcity")
                    }
                }
                .resignKeyboardOnDragGesture()
            }
            .navigationBarColor(UIColor.white)
            .navigationBarTitle("Select city", displayMode: .inline)
        }
    }
    
    var listCities: some View {
        
        let favouriteCitiesNames = self.userSettings.favouriteCities.map{$0.cityName}
        
        return ForEach(self.viewModel.getCities().filter{ $0.cityName.lowercased().contains(self.viewModel.searchText.lowercased()) || $0.countryName.lowercased().contains(self.viewModel.searchText.lowercased())
        }, id: \.id) { city in
            CityRowView(viewModel: city, addCheckMark: favouriteCitiesNames.contains(city.cityName))
                .onTapGesture {
                    if let city = self.viewModel.cityModel.first(where: { $0.cityName == city.cityName }) {
                        self.userSettings.favouriteCities.insert(city)
                        self.appState.cityName = city.cityName
                        self.appState.newCitySelected = true
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
        }
    }
}
