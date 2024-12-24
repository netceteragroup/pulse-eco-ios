//
//  CityListView.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/17/20.
//

import SwiftUI
import MapKit

struct FavouriteCitiesView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var refreshService: RefreshService
    @ObservedObject var viewModel: FavouriteCitiesViewModel
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var locationManager: LocationManager = LocationManager.shared
    let proxy: GeometryProxy

    var allCities: [FavouriteCityRowViewModel] {
        var tmpAllCities: [FavouriteCityRowViewModel] = []
        if let currentCity = locationManager.currentCity {
            let favouriteCityRowViewModel = viewModel.createFavouriteCityRowViewModelFromCityAndCityValues(city: currentCity, cityValues: appState.userSettings.cityValues, selectedMeasure: appState.selectedMeasureId, measureList: dataSource.measures, isCurrentCity: true)
            tmpAllCities.append(favouriteCityRowViewModel)
        }
        tmpAllCities.append(contentsOf: viewModel.getCities())
        return tmpAllCities
    }
    
    var body: some View {
        Group {
            if viewModel.cityList.count == 0 {
                VStack {
                    Text("").onAppear {
                        self.appState.activeSheet = .cityListView
                    }
                }
            } else {
                VStack(spacing: 0) {
                    List {
                        ForEach([allCities.first!], id: \.id) {
                            cityRow(favouriteCity: $0, from: [allCities.first!])
                        }
                        Section(header: EmptyView()) {
                            ForEach(Array(allCities.dropFirst()), id: \.id) { city in
                                cityRow(favouriteCity: city, from: Array(allCities.dropFirst()))
                            }
                            .onDelete(perform: self.delete)
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    .listStyle(InsetGroupedListStyle())
                    .overlay(ShadowOnBottomOfView())
                    HStack {
                        Spacer()
                        Button(action: {
                            self.appState.activeSheet = .cityListView
                        }) {
                            VStack(alignment: .center, spacing: 0) {
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color(AppColors.darkblue))
                                Text(Trema.text(for: "add_city_button"))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(AppColors.darkblue))
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 8)
                            .padding(.bottom, max(proxy.safeAreaInsets.bottom, 8))
                        }
                        Spacer()
                    }
                    .background(AppColors.white.color)
                }
            }
        }
    }

    @ViewBuilder
    private func cityRow(favouriteCity: FavouriteCityRowViewModel,
                         from array: [FavouriteCityRowViewModel]) -> some View {
        VStack(spacing: 0) {
            Button(action: {
                self.appState.citySelectorClicked = false
                if self.appState.selectedCity != favouriteCity.city {
                    if locationManager.currentCity?.cityName == favouriteCity.city.cityName {
                        appState.currentLocationIsSelected = true
                    }
                    else {
                        self.userSettings.addFavoriteCity(favouriteCity.city)
                        appState.currentLocationIsSelected = false
                    }
                    self.appState.selectedCity = favouriteCity.city
                    self.refreshService.updateRefreshDate()
                    self.dataSource.getValuesForCity(cityName: favouriteCity.cityName)
                }
            }, label: {
                FavouriteCityRowView(viewModel: favouriteCity)
                    .contentShape(Rectangle())
            }).padding()
            if favouriteCity != array.last {
                Divider()
            }
        }
        .listRowInsets(EdgeInsets())
    }

    private func delete(at offsets: IndexSet) {
        offsets.forEach {
            let delRow = allCities[$0 + 1]
            if let city = self.userSettings.favouriteCities.first(where: { $0.cityName == delRow.cityName }) {
                self.userSettings.removeFavouriteCity(city)
            }
        }
    }
}
