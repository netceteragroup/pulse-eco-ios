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
    
    //@State private var faveCities: [CityModel]
    @ObservedObject var viewModel: FavouriteCitiesVM
    @EnvironmentObject var appVM: AppVM
    @EnvironmentObject var dataSource: DataSource
    @EnvironmentObject var refreshService: RefreshService
    @ObservedObject var userSettings: UserSettings
    var body: some View {
        VStack() {
            if self.viewModel.cityList.count == 0 {
                VStack {
                    Text("").onAppear {
                        self.appVM.showSheet = true
                        self.appVM.activeSheet = .cityListView
                    }
                }
            } else {
                VStack {
                    List {
                        ForEach(self.viewModel.getCities(), id: \.id) { city in
                            FavouriteCityRowView(viewModel: city)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.appVM.citySelectorClicked = false
                                    self.appVM.cityName = city.cityName
                                    self.dataSource.loadingCityData = true
                                    self.refreshService.updateRefreshDate()
                                    self.dataSource.getValuesForCity(cityName: city.cityName)
                                    self.appVM.updateMapRegion = true
                                    self.appVM.updateMapAnnotations = true
                                }
                        }.onDelete(perform: self.delete)
                        //.onMove(perform: self.move)
                    }
                    HStack {
                        Spacer()
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(AppColors.purple))
                            .onTapGesture {
                                self.appVM.showSheet = true
                                self.appVM.activeSheet = .cityListView
                            }
                            .padding([.bottom, .trailing], 20)
                    }
                }.background(Color.white)
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
