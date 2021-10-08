//
//  CityListView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/17/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI
import MapKit

struct FavouriteCitiesView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var refreshService: RefreshService
    
    @ObservedObject var viewModel: FavouriteCitiesViewModel
    @ObservedObject var userSettings: UserSettings
    let proxy:  GeometryProxy
    
    var cities: [FavouriteCityRowViewModel] { viewModel.getCities() }
    
    
    var body: some View {
        Group {
            
            if (self.viewModel.cityList.count == 0) {
                VStack {
                    Text("").onAppear {
                        self.appState.showSheet = true
                        self.appState.activeSheet = .cityListView
                    }
                }
            } else {
                VStack (spacing: 0) {
                    List {
                        ForEach([cities.first!], id: \.id) {
                            cityRow(city: $0, from: [cities.first!])
                        }
                        Section(header:EmptyView()) {
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
                            self.appState.showSheet = true
                            self.appState.activeSheet = .cityListView
                        }) {
                            VStack(alignment: .center, spacing: 0) {
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color(AppColors.darkblue))
                                Text(Trema.text(for: "add_city_button"))
                                    .font(.system(size: 14, weight: .semibold))
//                                    .font(Font.custom("TitilliumWeb-SemiBold", size: 14))
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
                
            }// else
        } // group
    }
    
    @ViewBuilder
    private func cityRow(city: FavouriteCityRowViewModel,
                         from array: [FavouriteCityRowViewModel]) -> some View {
        VStack(spacing: 0) {
            
            Button(action: {
                self.appState.citySelectorClicked = false
                self.userSettings.addFavoriteCity(city.city)
                self.appState.cityName = city.cityName
                self.dataSource.loadingCityData = true
                self.refreshService.updateRefreshDate()
                self.dataSource.getValuesForCity(cityName: city.cityName)
                self.appState.updateMapRegion = true
                self.appState.updateMapAnnotations = true
            }, label: {
                FavouriteCityRowView(viewModel: city)
                    .contentShape(Rectangle())
                
            }).padding()
//                .background(Color.white)
            
            if (city != array.last){
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
