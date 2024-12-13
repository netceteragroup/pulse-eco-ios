//
//  NewCityListView.swift
//  PulseEco
//
//  Created by Darko Skerlevski on 23.9.21.
//

import SwiftUI

struct CityListView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var refreshService: RefreshService
    @ObservedObject var viewModel: CityListViewModel
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var locationManager: LocationManager = LocationManager.shared
    var searchText: String
    
    var body: some View {
        if self.searchText.isEmpty {
            listAllCities
        } else {
            filteredCitiesList
        }
    }
    
    var filteredCitiesList: some View {
        
        let favouriteCitiesNames = getFavouriteCitiesNames()
        let foundCities = viewModel.getCities().filter { $0.cityName.lowercased().contains(self.searchText.lowercased()) ||
                                                                $0.countryName.lowercased().contains(self.searchText.lowercased())
        }
        
        return ScrollView {
            VStack {
                ForEach(foundCities, id: \.id) { city in
                    Button(action: {
                        if let city = self.viewModel.cityModel.first(where: { $0.cityName == city.cityName }) {
                            self.userSettings.addFavoriteCity(city)
                            self.appState.citySelectorClicked = false
                            if self.appState.selectedCity != city {
                                self.appState.selectedCity = city
                                self.appState.newCitySelected = true
                                self.presentationMode.wrappedValue.dismiss()
                            } else {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                            dismissSearch()
                        }
                    }, label: {
                        CityRowView(viewModel: city,
                                    addCheckMark: favouriteCitiesNames.contains(city.cityName),
                                    showCountryName: true)
                    })
                    
                    if city != foundCities.last {
                        Divider()
                            .background(AppColors.gray.color)
                    }
                }
                
                if foundCities.count > 0 {
                    Divider()
                        .background(AppColors.gray.color)
                }
                
                VStack {
                    Text(Trema.text(for: "city_missing_add_new"))
                        .font(.system(size: 14))
                        .foregroundColor(Color(AppColors.gray))
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
                .resignKeyboardOnDragGesture()
                .frame(maxWidth: .infinity)
                .background(Color.white)
            }
        }

    }
    
    var listAllCities: some View {
        
        let favouriteCitiesNames = getFavouriteCitiesNames()
        
        return ScrollView {
            ForEach(self.viewModel.getCountries(), id: \.self) { elem in
                Section(header:
                            HStack {
                    Text("\(elem)")
                        .padding()
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                    .frame(height: 30)
                    .background(Color(red: 240 / 255, green: 240 / 255, blue: 240 / 255))
                    .listRowInsets(.zero)) {
                        let citiesFromCountry = self.viewModel.getCities().filter {
                            elem == $0.countryName
                        }
                        ForEach(citiesFromCountry, id: \.id) { city in
                            Button(action: {
                                if let city = viewModel.cityModel
                                    .first(where: { $0.cityName == city.cityName }) {
                                    self.userSettings.addFavoriteCity(city)
                                    self.appState.citySelectorClicked = false
                                    if self.appState.selectedCity != city {
                                        self.appState.selectedCity = city
                                        self.appState.newCitySelected = true
                                    }
                                    dismissSearch()
                                }
                            }, label: {
                                CityRowView(viewModel: city,
                                            addCheckMark: favouriteCitiesNames.contains(city.cityName),
                                            showCountryName: false)
                            })
                            if city != citiesFromCountry.last {
                                Divider()
                                    .background(AppColors.gray.color)
                            }
                        }
                    }
            }
            Divider().background(AppColors.gray.color)
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
            .resignKeyboardOnDragGesture()
        }
    }
    
    private func getFavouriteCitiesNames() -> [String] {
        var favouriteCitiesNames = self.userSettings.favouriteCities.map { $0.cityName }
        if let currentCity = self.locationManager.currentCity {
            favouriteCitiesNames.append(currentCity.cityName)
        }
        return favouriteCitiesNames
    }
}

extension EdgeInsets {
    static let zero = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}
