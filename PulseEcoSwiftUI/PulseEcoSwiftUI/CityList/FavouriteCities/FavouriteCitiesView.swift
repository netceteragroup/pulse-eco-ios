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
    
    @ObservedObject var viewModel: FavouriteCitiesViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var refreshService: RefreshService
    @ObservedObject var userSettings: UserSettings

    var body: some View {
        VStack() {
            if self.viewModel.cityList.count == 0 {
                VStack {
                    Text("").onAppear {
                        self.appState.showSheet = true
                        self.appState.activeSheet = .cityListView
                    }
                }
            } else {
                ZStack {
                    VStack{
                        List {
                            ForEach(self.viewModel.getCities(), id: \.id) { city in
                                Button(action: {
                                    self.appState.citySelectorClicked = false
                                    self.appState.cityName = city.cityName
                                    self.dataSource.loadingCityData = true
                                    self.refreshService.updateRefreshDate()
                                    self.dataSource.getValuesForCity(cityName: city.cityName)
                                    self.appState.updateMapRegion = true
                                    self.appState.updateMapAnnotations = true
                                }, label: {
                                    FavouriteCityRowView(viewModel: city)
                                        .contentShape(Rectangle())
                                })
                                
                            }.onDelete(perform: self.delete)
                        }
                    }
                    VStack{
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                self.appState.showSheet = true
                                self.appState.activeSheet = .cityListView
                            }) {
                                Text(Trema.text(for: "add_city_button"))
                                    .font(Font.custom("TitilliumWeb-SemiBold", size: 18))
                                    .foregroundColor(Color(AppColors.purple))
                                    .padding([.vertical, .leading], 16)
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color(AppColors.purple))
                                    .padding(.trailing, 16)
                            }
                        }
                        .padding([.trailing, .bottom], 8)
                        .edgesIgnoringSafeArea(.bottom)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }.background(Color.clear)
            }
        }
        .background(Color.white)
    }
    
    func delete(at offsets: IndexSet) {
        offsets.forEach {
            let delRow = self.viewModel.getCities()[$0]
            if let city = self.userSettings.favouriteCities.first(where: { $0.cityName == delRow.cityName }) {
                self.userSettings.favouriteCities.remove(city)
            }
        }
    }
}
