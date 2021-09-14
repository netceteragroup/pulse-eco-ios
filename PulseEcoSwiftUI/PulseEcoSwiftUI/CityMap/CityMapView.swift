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
    @ObservedObject var viewModel: CityMapVM
    @EnvironmentObject var appVM: AppVM
    @EnvironmentObject var dataSource: DataSource
    @ObservedObject var userSettings: UserSettings    
    var body: some View {
        
        ZStack {
            MapView(viewModel: MapVM(measure: self.appVM.selectedMeasure,
                                     cityName: self.appVM.cityName,
                                     sensors: self.dataSource.citySensors,
                                     sensorsData: self.dataSource.sensorsData,
                                     measures: self.dataSource.measures,
                                     city: self.dataSource.cities.first{ $0.cityName == self.appVM.cityName} ?? CityModel.defaultCity()))
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
                            self.appVM.showSheet = true
                            self.appVM.activeSheet = .disclaimerView
                    }
                    
                }.padding(.trailing, 15.0)
            }
            AverageView(viewModel: AverageVM(measure: self.appVM.selectedMeasure, cityName: self.appVM.cityName, measuresList: self.dataSource.measures, cityValues: self.dataSource.cityOverall))
            if self.appVM.citySelectorClicked {
                FavouriteCitiesView(viewModel: FavouriteCitiesVM(selectedMeasure: self.appVM.selectedMeasure, favouriteCities: self.userSettings.favouriteCities, cityValues: self.userSettings.cityValues, measureList: self.dataSource.measures), userSettings: self.userSettings)
                    .overlay(BottomShadow())
            }
        }
            .sheet(isPresented: self.$appVM.showSheet) {
                if self.appVM.activeSheet == .disclaimerView {
                    DisclaimerView()
                        .environment(\.managedObjectContext, self.moc)
                } else {
                    CityListView(viewModel: CityListVM(cities: self.dataSource.cities), userSettings: self.userSettings).environment(\.managedObjectContext, self.moc)
                }
        }
        
    }
}

enum ActiveSheet {
    case disclaimerView
    case cityListView
}
