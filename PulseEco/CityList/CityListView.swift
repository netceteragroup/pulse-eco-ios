//
//  NewCityListView.swift
//  PulseEco
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
                                        .background(Color(red: 240 / 255, green: 240 / 255, blue: 240 / 255))
                                        .listRowInsets(.zero)) {
                                let favouriteCitiesNames = self.userSettings.favouriteCities.map { $0.cityName }
                                let citiesFromCountry = self.viewModel.getCities().filter {
                                    elem == $0.countryName
                                }
                                ForEach(citiesFromCountry, id: \.id) { city in
                                    Button(action: {
                                        if let city = viewModel.cityModel
                                            .first(where: { $0.cityName == city.cityName }) {
                                            self.userSettings.addFavoriteCity(city)
                                            if self.appState.selectedCity != city {
                                                self.appState.selectedCity = city
                                                self.appState.newCitySelected = true
                                                self.presentationMode.wrappedValue.dismiss()
                                            } else {
                                                self.presentationMode.wrappedValue.dismiss()
                                                self.appState.citySelectorClicked = false
                                            }
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
            .navigationBarColor(AppColors.white)
            .navigationBarTitle(Trema.text(for: "select_city"), displayMode: .inline)
        }
        .if(.pad, transform: {
            $0.navigationViewStyle(StackNavigationViewStyle())
        })
    }

    var listCities: some View {
        let favouriteCitiesNames = userSettings.favouriteCities.map { $0.cityName }
        let foundCities = viewModel.getCities()
            .filter { $0.siteName.lowercased()
                .contains(self.searchText.lowercased()) || $0.countryName.lowercased()
                .contains(self.searchText.lowercased())
            }

        return VStack {
            ForEach(foundCities, id: \.id) { city in
                Button(action: {
                    if let city = self.viewModel.cityModel.first(where: { $0.cityName == city.cityName }) {
                        self.userSettings.addFavoriteCity(city)
                        if self.appState.selectedCity != city {
                            self.appState.selectedCity = city
                            self.appState.newCitySelected = true
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            self.presentationMode.wrappedValue.dismiss()
                            self.appState.citySelectorClicked = false
                        }
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
        }
    }
}

extension EdgeInsets {
    static let zero = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}
