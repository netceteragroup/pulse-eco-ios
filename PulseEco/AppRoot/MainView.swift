//
//  MainView.swift
//  PulseEco
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
    
    @State var showingCalendar = false
    @State var showingPicker = false
    let mapViewModel: MapViewModel
    let shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)
    private let backgroundColor: Color = AppColors.white.color
    private let shadow: Color = Color(red: 0.87, green: 0.89, blue: 0.92)

    private var sensorDetailsViewModel: SensorDetailsViewModel {
        let selectedMeasure = dataSource.getCurrentMeasure(selectedMeasure: appState.selectedMeasureId)
        return SensorDetailsViewModel(sensor: appState.selectedSensor ?? SensorPinModel(),
                                      selectedMeasure: selectedMeasure,
                                      sensorData24h: dataSource.sensorsData24h,
                                      dailyAverages: dataSource.sensorsDailyAverageData,
                                      historyAverage: dataSource.sensorsAverageHistoryData)
    }
    var body: some View {
        Group {
            if dataSource.loadingCityData || dataSource.loadingMeasures {
                loadingView
            } else {
                contentView
            }
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(item: $appState.activeSheet) { sheet in
            switch sheet {
            case .disclaimerView: DisclaimerView()
            case .cityListView:
                CityListView(viewModel: CityListViewModel(cities: self.dataSource.cities),
                             userSettings: self.dataSource.userSettings)
                .onDisappear(perform: {
                    if self.dataSource.userSettings.favouriteCities.count == 0 {
                        self.appState.citySelectorClicked = false
                    }
                    if self.$appState.newCitySelected.wrappedValue == true {
                        self.refreshService.updateRefreshDate()
                        self.dataSource.getValuesForCity(cityName: self.appState.selectedCity.cityName)
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
        GeometryReader { proxy in
            ZStack {
                NavigationView {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            let viewModel = MeasureListViewModel(selectedMeasure: appState.selectedMeasureId,
                                                                 cityName: appState.selectedCity.cityName,
                                                                 measuresList: dataSource.measures,
                                                                 cityValues: dataSource.cityOverall,
                                                                 citySelectorClicked: appState.citySelectorClicked)
                            MeasureListView(viewModel: viewModel)
                        }
                        DateSlider(unimplementedAlert: $showingCalendar, unimplementedPicker: $showingPicker)
                        ZStack(alignment: .top) {
                            
                            CityMapView(userSettings: self.dataSource.userSettings,
                                        mapViewModel: mapViewModel,
                                        proxy: proxy)
                            .id("CityMapView")
                            .edgesIgnoringSafeArea([.horizontal, .bottom])
                            
                            if showingCalendar {
                                CustomCalendar(showingCalendar: $showingCalendar, showPicker: $showingPicker)
                                    .cornerRadius(4)
                                    .shadow(color: Color(shadowColor), radius: 20)
                                    .padding(.all)
                            }
                        }
                    }
                    .navigationBarTitle("", displayMode: .inline)
                    .navigationBarItems(
                        leading: leadingNavigationItems,
                        trailing: trailingNavigationItems)
                }
                .if(.pad) { $0.navigationViewStyle(StackNavigationViewStyle()) }
                .navigationBarColor(AppColors.white)
                .zIndex(1)
                if self.appState.showSensorDetails {
                    SlideOverCard {
                        SensorDetailsView(viewModel: sensorDetailsViewModel)
                            .frame(maxWidth: UIScreen.main.bounds.width)
                    }
                    .transition(.move(edge: .bottom))
                    .zIndex(2) // zIndexes are needed to maintain dismiss transition
                }
            }
        }
    }
    
    var trailingNavigationItems: some View {
        HStack {
            Image(uiImage: UIImage(named: "logo-pulse") ?? UIImage())
                .imageScale(.large)
                .padding(.trailing, (UIWidth)/3.7)
                .onTapGesture {
                    if self.appState.citySelectorClicked == false {
                        self.appState.selectedSensor = nil
                        self.refreshService.refreshData()
                    }
                }
            Button(action: {
                withAnimation {
                    self.appState.activeSheet = .languageView
                }
            }) {
                Image(systemName: "globe")
                    .resizable()
                    .frame(width: 20, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color(AppColors.darkblue))
                    .padding(.leading, 15)
            }
        }
    }
    
    var leadingNavigationItems: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.appState.citySelectorClicked.toggle()
                if self.appState.showSensorDetails {
                    self.appState.showSensorDetails = false
                    self.appState.selectedSensor = nil
                }
            }
        }) {
            HStack {
                Text(self.appState.selectedCity.cityName.uppercased())
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(AppColors.darkblue))
                self.appState.cityIcon.foregroundColor(Color(AppColors.darkblue))
            }
        }
        .accentColor(AppColors.black.color)
    }
}

extension View {
    func navigationBarColor(_ backgroundColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }
}
