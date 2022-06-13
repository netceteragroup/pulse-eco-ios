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
    let proxy: GeometryProxy

    var cities: [FavouriteCityRowViewModel] { viewModel.getCities() }
    
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
                        ForEach([cities.first!], id: \.id) {
                            cityRow(city: $0, from: [cities.first!])
                        }
                        Section(header: EmptyView()) {
                            ForEach(Array(cities.dropFirst()), id: \.id) { city in
                                cityRow(city: city, from: Array(cities.dropFirst()))
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
