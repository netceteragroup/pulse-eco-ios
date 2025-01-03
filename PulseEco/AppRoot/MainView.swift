//
//  MainView.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/16/20.
//

import SwiftUI

struct MainView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var refreshService: RefreshService
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @State private var isShowingSettingsView = false
    @ObservedObject var locationManager: LocationManager = LocationManager.shared
    
    let mapViewModel: MapViewModel
    
    private let backgroundColor: Color = AppColors.white.color
    
    private var sensorDetailsViewModel: SensorDetailsViewModel {
        let selectedMeasure = dataSource.getCurrentMeasure(selectedMeasure: appState.selectedMeasureId)
        return SensorDetailsViewModel(sensor: appState.selectedSensor ?? SensorPinModel(),
                                      selectedMeasure: selectedMeasure,
                                      sensorData24h: dataSource.sensorsData24h,
                                      dailyAverages: dataSource.sensorsDailyAverageData)
    }
    
    var body: some View {
        Group {
            if appState.loadingCityData || appState.loadingMeasures || (locationManager.isAuthorizationGranted() && locationManager.isWaitingToFetchRegion()) {
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
                             userSettings: self.appState.userSettings)
                .onDisappear(perform: {
                    if self.appState.userSettings.favouriteCities.count == 0 {
                        self.appState.citySelectorClicked = false
                    }
                    if self.$appState.newCitySelected.wrappedValue == true {
                        self.refreshService.updateRefreshDate()
                        self.dataSource.getValuesForCity(cityName: self.appState.selectedCity.cityName)
                        self.appState.newCitySelected = false
                        self.appState.citySelectorClicked = false
                    }
                })
            }
        }
        .onAppear() {
            locationManager.requestLocation()
            
            locationManager.didSetCurrentCity = { newCity in
                if let newCity {
                    var favoriteCities = appState.userSettings.favouriteCities
                    favoriteCities.removeAll { $0.cityName == newCity.cityName }
                    appState.userSettings.favouriteCities = favoriteCities
                    if appState.selectedCity == locationManager.currentCity {
                        appState.currentLocationIsSelected = true
                    }
                    if appState.currentLocationIsSelected {
                        appState.selectedCity = newCity
                        dataSource.getValuesForCity(cityName: newCity.cityName)
                    }
                }
            }
        }
    }
    
    var loadingView: some View {
        LoadingDialog()
    }
    
    var contentView: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                NavigationView {
                    VStack(spacing: 0) {
                        if self.appState.citySelectorClicked {
                            FavouriteCitiesView(viewModel:
                                                    FavouriteCitiesViewModel(
                                                        selectedMeasure: self.appState.selectedMeasureId,
                                                        favouriteCities: self.appState.userSettings.favouriteCities,
                                                        cityValues: self.appState.userSettings.cityValues,
                                                        measureList: self.dataSource.measures),
                                                userSettings: self.appState.userSettings,
                                                proxy: proxy)
                            .overlay(ShadowOnTopOfView())
                            .animation(nil, value: self.appState.citySelectorClicked)
                        } else {
                            VStack(spacing: 0) {
                                let viewModel = MeasureListViewModel(selectedMeasure: appState.selectedMeasureId,
                                                                     cityName: appState.selectedCity.cityName,
                                                                     measuresList: dataSource.measures,
                                                                     cityValues: dataSource.cityOverall,
                                                                     citySelectorClicked: appState.citySelectorClicked)
                                MeasureListView(viewModel: viewModel)
                            }
                            
                            NavigationLink(destination: SettingsView(),
                                           isActive: $isShowingSettingsView) { EmptyView () }
                            
                            ZStack(alignment: .top) {
                                DatePicker()
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .zIndex(4)
                                CityMapView(userSettings: self.appState.userSettings,
                                            mapViewModel: mapViewModel,
                                            proxy: proxy)
                                .id("CityMapView")
                                .padding(.top, 60)
                                .edgesIgnoringSafeArea([.horizontal, .bottom])
                                
                            }
                        }
                    }
                    .navigationBarTitle("", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            leadingNavigationItems
                        }
                        ToolbarItemGroup(placement: .primaryAction) {
                            trailingNavigationItem
                        }
                    }
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
    
    var trailingNavigationItem: some View {
        HStack {
            Image(uiImage: UIImage(named: "logo-pulse") ?? UIImage())
                .imageScale(.large)
                .padding(.trailing, (UIWidth)/4)
                .onTapGesture {
                    if self.appState.citySelectorClicked == false {
                        self.appState.selectedSensor = nil
                        self.refreshService.refreshData()
                    }
                }
            menuItem
        }
    }
    
    var menuItem: some View {
        Menu {
            Section {
                Button(action: {
                    self.appState.selectedAppView = .dashboard
                }) {
                    Text(Trema.text(for: "dashboard_view"))
                    Spacer()
                    if self.appState.selectedAppView == .dashboard {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(AppColors.darkblue))
                    }
                }
                
                Button(action: {
                    self.appState.selectedAppView = .mapView
                }) {
                    Text(Trema.text(for: "map_view"))
                    Spacer()
                    if self.appState.selectedAppView == .mapView {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(AppColors.darkblue))
                    }
                }
                
                Button(action: {
                    isShowingSettingsView = true
                    self.appState.selectedAppView = .settings
                }) {
                    Text(Trema.text(for: "settings_view"))
                    Spacer()
                    if self.appState.selectedAppView == .settings {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(AppColors.darkblue))
                    }
                }
            }
        }
        
        label: {
            Image(systemName: "line.horizontal.3")
                .resizable()
                .frame(width: 25, height: 15, alignment: .center)
                .foregroundColor(Color(AppColors.darkblue))
                .padding(.leading, 15)
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

