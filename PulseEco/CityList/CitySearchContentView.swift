//
//  CitySearchContentView.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 5.12.24.
//

import SwiftUI
import Factory

struct CitySearchContentView: View {
    @Environment(\.isSearching) private var isSearching
    @EnvironmentObject var appDataManager: AppDataManager
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var refreshService: RefreshService
    @ObservedObject var viewModel: CitySearchContentViewModel
    
    @Injected(\.locationService) private var locationService
    
    var searchText: String
    
    var body: some View {
        if isSearching || (viewModel.cities.isEmpty && locationService.currentAuthorizationStatus() != .authorized) {
            CityListView(
                viewModel: CityListViewModel(cities: appData.cities),
                searchText: searchText
            )
            .padding(.vertical, 1)
        } else {
            favoriteCitiesList()
        }
    }
    
    var allFavoritesAndLocation: [FavouriteCityRowViewModel] {
        var tmpAllCities: [FavouriteCityRowViewModel] = []
        if let currentCity = locationService.lastLocation {
            let favouriteCityRowViewModel = viewModel.createFavouriteCityRowViewModelFromCityAndCityValues(
                city: currentCity,
                cityValues: UserSettings.cityValues,
                selectedMeasure: appData.selectedMeasureId,
                measureList: appData.measures,
                isCurrentCity: true
            )
            tmpAllCities.append(favouriteCityRowViewModel)
        }
        tmpAllCities.append(contentsOf: viewModel.getCities())
        return tmpAllCities
    }
    
    @ViewBuilder
    private func favoriteCitiesList() -> some View {
        List {
            if let first = allFavoritesAndLocation.first {
                ForEach([first], id: \.id) {
                    cityRow(favouriteCity: $0, from: [first])
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
        .padding(.vertical, 1)
    }
    
    @ViewBuilder
    private func cityRow(favouriteCity: FavouriteCityRowViewModel,
                         from array: [FavouriteCityRowViewModel]) -> some View {
        VStack(spacing: 0) {
            Button(action: {
                self.appData.citySelectorClicked = false
                if UserSettings.selectedCity != favouriteCity.city {
                    if locationService.lastLocation?.cityName != favouriteCity.city.cityName {
                        UserSettings.addFavoriteCity(favouriteCity.city)
                    }
                    UserSettings.selectedCity = favouriteCity.city
                    self.refreshService.updateRefreshDate()
                    self.appDataManager.fetchData(cityName: favouriteCity.cityName, sensorType: appData.selectedMeasureId, selectedDate: appData.selectedDate)
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
            if let city = UserSettings.favouriteCities.first(where: { $0.cityName == delRow.cityName }) {
                UserSettings.removeFavouriteCity(city)
            }
        }
    }
}

#Preview {
    CitySearchContentView(
        viewModel: CitySearchContentViewModel(
            selectedMeasure: "",
            favouriteCities: [],
            cityValues: [],
            measureList: []
        ),
        searchText: ""
    )
}
