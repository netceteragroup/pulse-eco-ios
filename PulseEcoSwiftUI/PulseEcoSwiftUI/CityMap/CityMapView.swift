//
//  CityMapView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/17/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct CityMapView: View {
    
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var viewModel: CityMapViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @ObservedObject var userSettings: UserSettings    
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
                    BottomShadow()
                )
            
            VStack(alignment: .trailing) {
                Spacer()
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                        .fill(self.viewModel.disclaimerIconColor)
                        .frame(width: self.viewModel.disclaimerIconSize.width, height: self.viewModel.disclaimerIconSize.height)
                        .overlay(Text(self.viewModel.disclaimerIconText)
                                    .foregroundColor(Color.black)
                        )
                        .padding(.bottom, 35)
                        .onTapGesture {
                            self.appState.showSheet = true
                            self.appState.activeSheet = .disclaimerView
                        }
                    
                }.padding(.trailing, 15.0)
            }
            AverageView(viewModel: AverageViewModel(measure: self.appState.selectedMeasure, cityName: self.appState.cityName, measuresList: self.dataSource.measures, cityValues: self.dataSource.cityOverall))
            if self.appState.citySelectorClicked {
                FavouriteCitiesView(viewModel: FavouriteCitiesViewModel(selectedMeasure: self.appState.selectedMeasure, favouriteCities: self.userSettings.favouriteCities, cityValues: self.userSettings.cityValues, measureList: self.dataSource.measures), userSettings: self.userSettings)
                    .overlay(BottomShadow())
            }
        }
        .sheet(isPresented: self.$appState.showSheet) {
            
            if self.appState.activeSheet == .disclaimerView {
                DisclaimerView()
                    .environment(\.managedObjectContext, self.moc)
            } else {
                CityListView(viewModel: CityListViewModel(cities: self.dataSource.cities), userSettings: self.userSettings)
                    .environment(\.managedObjectContext, self.moc)
                    .onDisappear(perform:{
                        if self.userSettings.favouriteCities.count == 0{
                            //self.appState.showSheet = false
                            self.appState.citySelectorClicked = false
                        }
                    })
            }
        }
        
    }
}

enum ActiveSheet {
    case disclaimerView
    case cityListView
}
