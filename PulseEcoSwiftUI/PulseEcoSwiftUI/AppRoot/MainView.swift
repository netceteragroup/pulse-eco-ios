//
//  MainView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/16/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var refreshService: RefreshService 
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @ObservedObject var userSettings = UserSettings()
    @State var showPicker: Bool = false
    
    private let backgroundColor: Color = Color.white
    private let shadow: Color = Color(red: 0.87, green: 0.89, blue: 0.92)
    
    var body: some View {
        LoadingView(isShowing: .constant(self.dataSource.loadingCityData), loadingMeasures: .constant(self.dataSource.loadingMeasures)) {
            NavigationView {
                ZStack{
                    ZStack {
                     
                        CityMapView(viewModel: CityMapViewModel(blurBackground: self.appState.blurBackground),
                                    userSettings: self.dataSource.userSettings)
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
                    }.navigationBarTitle("", displayMode: .inline)
                        .navigationBarItems(
                            leading: Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)){
                                    self.appState.citySelectorClicked.toggle()
                                    if self.showPicker == true {
                                        self.showPicker = false
                                    }
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
                                    
                                    self.appState.cityIcon
                                }
                            }.accentColor(Color.black),
                            trailing: HStack {
                                Image(uiImage: UIImage(named: "logo-pulse") ?? UIImage())
                                    .imageScale(.large)
                                    .padding(.trailing, (UIWidth)/3.7)
                                    .onTapGesture {
                                        //action
                                        if self.appState.citySelectorClicked == false {
                                            self.refreshService.refreshData()
                                            self.showPicker = false
                                        }
                                }
                                Button(action: {
                                    withAnimation(){
                                        self.appState.showSensorDetails = false
                                        self.appState.updateMapRegion = true
                                        self.appState.updateMapAnnotations = true
                                        self.showPicker = true
                                        
                                    }
                                }) {
                                    Text(Countries.selectedCountry(for: Trema.appLanguage).flagImageName)
                                        .font(.title)
                                }
                        })
                }
            }.navigationBarColor(UIColor.white)
                .overlay(
                    ZStack{
                        
                        if self.showPicker {
                            
                            LanguageView(showPicker: self.$showPicker)
                                .transition(.move(edge: .bottom))
                                .animation(.spring())
                                .zIndex(1)
                        }
                        else if self.appState.showSensorDetails {
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
}


extension View {
    func navigationBarColor(_ backgroundColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }
}


