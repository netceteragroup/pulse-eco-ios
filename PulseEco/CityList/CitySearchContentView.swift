//
//  CitySearchContentView.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 5.12.24.
//

import Foundation
import SwiftUI

struct CitySearchContentView: View {
    @Environment(\.isSearching) private var isSearching
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var refreshService: RefreshService
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var viewModel: CitySearchContentViewModel
    @ObservedObject var locationManager: LocationManager = LocationManager.shared
    
    var searchText: String
    
    var allFavoritesAndLocation: [FavouriteCityRowViewModel] {
        var tmpAllCities: [FavouriteCityRowViewModel] = []
        if let currentCity = locationManager.currentCity {
            tmpAllCities.append(FavouriteCityRowViewModel(city: currentCity, isCurrentCity: true))
        }
        tmpAllCities.append(contentsOf: viewModel.getCities())
        return tmpAllCities
    }
    
    var body: some View {
        if isSearching || (viewModel.cities.isEmpty && !locationManager.isAuthorizationGranted()) {
            CityListView(viewModel: CityListViewModel(cities: self.dataSource.cities), userSettings: userSettings, searchText: searchText)
                .padding(.vertical, 1)
        }
        else {
            favoriteCities
                .padding(.vertical, 1)
        }
    }
    
    var favoriteCities: some View {
        return List {
            ForEach([allFavoritesAndLocation.first!], id: \.id) {
                cityRow(favouriteCity: $0, from: [allFavoritesAndLocation.first!])
            }
            Section(header: EmptyView()) {
                ForEach(Array(allFavoritesAndLocation.dropFirst()), id: \.id) { city in
                    cityRow(favouriteCity: city, from: Array(allFavoritesAndLocation.dropFirst()))
                }
                .onDelete(perform: self.delete)
            }
            .listRowInsets(EdgeInsets())
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
            let delRow = allFavoritesAndLocation[$0 + 1]
            if let city = self.userSettings.favouriteCities.first(where: { $0.cityName == delRow.cityName }) {
                self.userSettings.removeFavouriteCity(city)
            }
        }
    }
}
