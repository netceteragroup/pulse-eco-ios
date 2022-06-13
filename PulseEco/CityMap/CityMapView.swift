//
//  CityMapView.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/17/20.
//

import SwiftUI

struct CityMapView: View {
    
    struct Theme {
        static let disclaimerIconColor: Color = AppColors.white.color
        static let disclaimerIconSize: CGSize = CGSize(width: 220, height: 25)
    }
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var refreshService: RefreshService
    @ObservedObject var userSettings: UserSettings
    
    let mapViewModel: MapViewModel
    
    let proxy: GeometryProxy
    
    var body: some View {
        
        ZStack {
            MapView(viewModel: mapViewModel, appState: appState)
                .id("MapView")
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
                                    .foregroundColor(AppColors.black.color)
                        )
                        .padding(.bottom, 35)
                        .onTapGesture {
                            self.appState.activeSheet = .disclaimerView
                        }
                    
                }.padding(.trailing, 15.0)
            }
            
            AverageView(viewModel: AverageUtilModel(measureId: self.appState.selectedMeasureId,
                                                    cityName: self.appState.selectedCity.cityName,
                                                    measuresList: self.dataSource.measures,
                                                    cityValues: self.dataSource.cityOverall,
                                                    currentValue: self.appState.selectedDateAverageValue))
            
            if self.appState.citySelectorClicked {
                FavouriteCitiesView(viewModel:
                                        FavouriteCitiesViewModel(
                                            selectedMeasure: self.appState.selectedMeasureId,
                                            favouriteCities: self.userSettings.favouriteCities,
                                            cityValues: self.userSettings.cityValues,
                                            measureList: self.dataSource.measures),
                                    userSettings: self.userSettings,
                                    proxy: proxy)
                    .overlay(ShadowOnTopOfView())
                    .animation(nil, value: self.appState.citySelectorClicked)
            }
        }
    }
}

enum ActiveSheet: Int, Identifiable {
    var id: Int { self.rawValue }
    
    case disclaimerView
    case cityListView
    case languageView
}
