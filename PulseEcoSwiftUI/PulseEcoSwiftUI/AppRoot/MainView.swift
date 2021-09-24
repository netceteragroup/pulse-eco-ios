//
//  MainView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/16/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var refreshService: RefreshService 
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    
    private let backgroundColor: Color = Color.white
    private let shadow: Color = Color(red: 0.87, green: 0.89, blue: 0.92)
    
    var body: some View {
        Group {
            if dataSource.loadingCityData || dataSource.loadingMeasures {
                loadingView
            } else {
                contentView
            }
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: self.$appState.showSheet) {
            switch self.appState.activeSheet {
            case .disclaimerView: DisclaimerView()
            case .cityListView:
                CityListView(viewModel: CityListViewModel(cities: self.dataSource.cities),
                             userSettings: self.dataSource.userSettings)
                    .onDisappear(perform:{
                        if self.dataSource.userSettings.favouriteCities.count == 0 {
                            self.appState.citySelectorClicked = false
                        }
                        if self.$appState.newCitySelected.wrappedValue == true{
                            self.dataSource.loadingCityData = true
                            self.refreshService.updateRefreshDate()
                            self.dataSource.getValuesForCity(cityName: self.appState.cityName)
                            self.appState.updateMapRegion = true
                            self.appState.updateMapAnnotations = true
                            self.appState.newCitySelected = false
                            self.appState.citySelectorClicked = false
                        }
                    })
            
            case .languageView: LanguageView()
            }
        }
    }
    
    var loadingView: some View {
        LoadingDialog()
    }
    
    var contentView: some View {
        NavigationView {
            ZStack{
                ZStack {
                    CityMapView(userSettings: self.dataSource.userSettings)
                        .edgesIgnoringSafeArea([.horizontal,.bottom
                        ])
                        .padding(.top, 36)
                    
                    VStack {
                        Rectangle()
                            .frame(height: 36)
                                .foregroundColor(backgroundColor)
                                .shadow(color: shadow, radius: 0.8, x: 0, y: 0)
                        Spacer()
                    }
                    
                    VStack {
                    MeasureListView(viewModel: MeasureListViewModel(selectedMeasure: self.appState.selectedMeasure,
                                                             cityName: self.appState.cityName,
                                                             measuresList: self.dataSource.measures,
                                                             cityValues: self.dataSource.cityOverall,
                                                             citySelectorClicked: self.appState.citySelectorClicked))
                     Spacer()
                    }
                }
                .navigationBarTitle("", displayMode: .inline)
                    .navigationBarItems(
                        leading: Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)){
                                self.appState.citySelectorClicked.toggle()
                                if self.appState.showSensorDetails == true {
                                    self.appState.showSensorDetails = false
                                    self.appState.selectedSensor = nil
                                    self.appState.updateMapAnnotations = true
                                }
                            }
                        }) {
                            HStack {
                                Text(self.appState.cityName.uppercased())
                                    .font(Font.custom("TitilliumWeb-SemiBold", size: 14))
                                    .foregroundColor(Color(AppColors.darkblue))
                                
                                self.appState.cityIcon.foregroundColor(Color(AppColors.darkblue))
                            }
                        }.accentColor(Color.black),
                        trailing:
                            HStack {
                            Image(uiImage: UIImage(named: "logo-pulse") ?? UIImage())
                                .imageScale(.large)
                                .padding(.trailing, (UIWidth)/3.7)
                                .onTapGesture {
                                    //action
                                    if self.appState.citySelectorClicked == false {
                                        self.refreshService.refreshData()
                                    }
                            }
                                
                            Button(action: {
                                withAnimation(){
                                    self.appState.activeSheet = .languageView
                                    self.appState.showSheet = true
                                }
                            }) {
                                Image(systemName: "globe")
                                    .resizable()
                                    .frame(width: 20, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                    .foregroundColor(Color(AppColors.darkblue))
                                    .padding(.leading, 15)
                            }
                    })
            }
        }
        .if(.pad, transform: {
            $0.navigationViewStyle(StackNavigationViewStyle())
        })
        .navigationBarColor(UIColor.white)
            .overlay(
                ZStack{
                    if self.appState.showSensorDetails {
                        SlideOverCard {
                            SensorDetailsView(viewModel: SensorDetailsViewModel(
                                sensor: self.appState.selectedSensor ?? SensorPinModel(),
                                sensorsData: self.dataSource.sensorsData24h,
                                selectedMeasure: self.dataSource.getCurrentMeasure(selectedMeasure:self.appState.selectedMeasure),
                                sensorData24h: self.dataSource.sensorsData24h,
                                dailyAverages: self.dataSource.sensorsDailyAverageData))
                        }
                    }
            })
    }
}


extension View {
    func navigationBarColor(_ backgroundColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }
}


