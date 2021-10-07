//
//  CityMapView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/17/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct CityMapView: View {
    
    struct Theme {
        static let disclaimerIconColor: Color = Color.white
        static let disclaimerIconSize: CGSize = CGSize(width: 220, height: 25)
    }
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var refreshService: RefreshService
    @ObservedObject var userSettings: UserSettings
    let proxy:  GeometryProxy
    
    var body: some View {
        
        ZStack {
            MapView(viewModel: MapViewModel(measure: self.appState.selectedMeasure,
                                            cityName: self.appState.cityName,
                                            sensors: self.dataSource.citySensors,
                                            sensorsData: self.dataSource.sensorsData,
                                            measures: self.dataSource.measures,
                                            city: self.dataSource.cities.first{ $0.cityName == self.appState.cityName} ?? City.defaultCity()))
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    ShadowOnTopOfView()
                )
            
            VStack(alignment: .trailing) {
                Spacer()
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                        .fill(Theme.disclaimerIconColor)
                        .frame(width: Theme.disclaimerIconSize.width, height: Theme.disclaimerIconSize.height)
                        .overlay(Text(Trema.text(for: "crowdsourced_sensor_data"))
                                    .foregroundColor(Color.black)
                        )
                        .padding(.bottom, 35)
                        .onTapGesture {
                            self.appState.showSheet = true
                            self.appState.activeSheet = .disclaimerView
                        }
                    
                }.padding(.trailing, 15.0)
            }
            
            AverageView(viewModel: AverageViewModel(measure: self.appState.selectedMeasure,
                                                    cityName: self.appState.cityName,
                                                    measuresList: self.dataSource.measures,
                                                    cityValues: self.dataSource.cityOverall))
            
            if self.appState.citySelectorClicked {
                FavouriteCitiesView(viewModel:
                                        FavouriteCitiesViewModel(
                                            selectedMeasure: self.appState.selectedMeasure,
                                            favouriteCities: self.userSettings.favouriteCities,
                                            cityValues: self.userSettings.cityValues,
                                            measureList: self.dataSource.measures),
                                    userSettings: self.userSettings,
                                    proxy: proxy)
                    .overlay(ShadowOnTopOfView())
                    .animation(nil)
                
            }
        }
    }
}

enum ActiveSheet {
    case disclaimerView
    case cityListView
    case languageView
}
