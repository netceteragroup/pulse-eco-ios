//
//  MainView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/16/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct MainView: View {
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
                                    .padding(.trailing, (UIWidth)/4)
                                    .onTapGesture {
                                        //action
                                        if self.appVM.citySelectorClicked == false {
                                            self.appVM.showSensorDetails = false
                                            self.appVM.selectedSensor = nil
                                            self.appVM.updateMapAnnotations = true
                                            self.appVM.updateMapRegion = true
                                            self.dataSource.loadingMeasures = true
                                            self.dataSource.getMeasures()
                                            self.dataSource.loadingCityData = true
                                            self.dataSource.getValuesForCity(cityName: self.appVM.cityName)
                                        }
                                }
                                Button(action: {
                                    withAnimation(Animation.linear.delay(1)){
                                        self.showPicker = true
                                    }
                                }) {
                                    Text(Countries.selectedCountry(for: self.appVM.appLanguage).flagImageName)
                                        .font(.title)
                                }
                            })
                }
            }.navigationBarColor(UIColor.white)
                .overlay(
                    VStack{
                        if self.showPicker {
                            LanguageView(showPicker: self.$showPicker)
                                .transition(.move(edge: .bottom))
                                .animation(.spring())
                        }
                        
                        if self.appVM.showSensorDetails {
                            //SensorDetailsView().edgesIgnoringSafeArea(.bottom)
            //                SenDetView().edgesIgnoringSafeArea(.bottom)
                            SlideOverCard {
//                                    Text("Marko")
                                SDView(viewModel: ExpandedVM(sensorData24h: self.dataSource.sensorsData24h,
                                                             dailyAverages: self.dataSource.sensorsDailyAverageData))
                                
                            }
                            //SDView(viewModel: ExpandedVM(sensorData24h: self.dataSource.sensorsData24h))
                            //SensorDView(viewModel: ExpandedVM(sensorData24h: self.dataSource.sensorsData24h))
                        }
                    }.padding(.top, 40)
            )
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}


extension View {
    func navigationBarColor(_ backgroundColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }
}


