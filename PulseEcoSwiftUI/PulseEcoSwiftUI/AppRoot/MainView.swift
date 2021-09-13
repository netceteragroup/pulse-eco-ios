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
    @EnvironmentObject var appVM: AppVM
    @EnvironmentObject var dataSource: DataSource
    @ObservedObject var userSettings = UserSettings()
    @State var showPicker: Bool = false
    
    var body: some View {
        LoadingView(isShowing: .constant(self.dataSource.loadingCityData), loadingMeasures: .constant(self.dataSource.loadingMeasures)) {
            NavigationView {
                ZStack{
                    VStack(alignment: .center, spacing: 0) {
                        MeasureListView(viewModel: MeasureListVM(selectedMeasure: self.appVM.selectedMeasure,
                                                                 cityName: self.appVM.cityName,
                                                                 measuresList: self.dataSource.measures,
                                                                 cityValues: self.dataSource.cityOverall,
                                                                 citySelectorClicked: self.appVM.citySelectorClicked))
                        CityMapView(viewModel: CityMapVM(blurBackground: self.appVM.blurBackground),
                                    userSettings: self.dataSource.userSettings)
                            .edgesIgnoringSafeArea([.horizontal,.bottom
                            ])
                    }.navigationBarTitle("", displayMode: .inline)
                        .navigationBarItems(
                            leading: Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)){
                                    self.appVM.citySelectorClicked.toggle()
                                    if self.showPicker == true {
                                        self.showPicker = false
                                    }
                                    if self.appVM.showSensorDetails == true{
                                        self.appVM.showSensorDetails = false
                                        self.appVM.selectedSensor = nil
                                        self.appVM.updateMapAnnotations = true
                                    }
                                }
                            }) {
                                HStack {
                                    Text(self.appVM.cityName.uppercased())
                                        .font(Font.custom("TitilliumWeb-SemiBold", size: 14))
                                        .foregroundColor(Color(AppColors.darkblue))
                                    
                                    self.appVM.cityIcon
                                }
                            }.accentColor(Color.black),
                            trailing: HStack {
                                Image(uiImage: UIImage(named: "logo-pulse") ?? UIImage())
                                    .imageScale(.large)
                                    .padding(.trailing, (UIWidth)/3.7)
                                    .onTapGesture {
                                        //action
                                        if self.appVM.citySelectorClicked == false {
                                            self.refreshService.refreshData()
                                            self.showPicker = false
                                        }
                                }
                                Button(action: {
                                    withAnimation(){
                                        self.appVM.showSensorDetails = false
                                        self.appVM.updateMapRegion = true
                                        self.appVM.updateMapAnnotations = true
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
                        else if self.appVM.showSensorDetails {
                            SlideOverCard {
                                SensorDetailsView(viewModel: SensorDetailsViewModel(
                                    sensor: self.appVM.selectedSensor ?? SensorVM(),
                                    sensorsData: self.dataSource.sensorsData24h,
                                    selectedMeasure: self.dataSource.getCurrentMeasure(selectedMeasure:self.appVM.selectedMeasure),
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


