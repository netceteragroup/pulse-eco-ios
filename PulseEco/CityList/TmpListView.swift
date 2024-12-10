//
//  TmpListView.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 5.12.24.
//

import Foundation
import SwiftUI

struct TmpListView: View {
    @Environment(\.isSearching) private var isSearching
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var refreshService: RefreshService
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var viewModel: FavouriteCitiesViewModel
    
    var searchText: String
    
    var body: some View {
        if isSearching || viewModel.cities.isEmpty{
            CityListView(viewModel: CityListViewModel(cities: self.dataSource.cities), userSettings: userSettings, searchText: searchText)
                .padding(.vertical, 1)
        }
        else {
            favoriteCities
                .padding(.vertical, 1)
        }
    }
    
    var favoriteCities: some View {
        List {
            ForEach([viewModel.cities.first!], id: \.id) {
                cityRow(city: $0, from: [viewModel.cities.first!])
            }
            Section(header: EmptyView()) {
                ForEach(Array(viewModel.cities.dropFirst()), id: \.id) { city in
                    cityRow(city: city, from: Array(viewModel.cities.dropFirst()))
                }
                .onDelete(perform: self.delete)
            }
            .listRowInsets(EdgeInsets())
        }
    }

    @ViewBuilder
    private func cityRow(city: FavouriteCityRowViewModel,
                         from array: [FavouriteCityRowViewModel]) -> some View {
        VStack(spacing: 0) {
            Button(action: {
                self.appState.citySelectorClicked = false
                if self.appState.selectedCity != city.city {
                    self.userSettings.addFavoriteCity(city.city)
                    self.appState.selectedCity = city.city
                    self.refreshService.updateRefreshDate()
                    self.dataSource.getValuesForCity(cityName: city.cityName)
                }
            }, label: {
                FavouriteCityRowView(viewModel: city)
                    .contentShape(Rectangle())
            }).padding()
            if city != array.last {
                Divider()
            }
        }
        .listRowInsets(EdgeInsets())
    }

    private func delete(at offsets: IndexSet) {
        offsets.forEach {
            let delRow = self.viewModel.getCities()[$0 + 1]
            if let city = self.userSettings.favouriteCities.first(where: { $0.cityName == delRow.cityName }) {
                self.userSettings.removeFavouriteCity(city)
            }
        }
    }
}
