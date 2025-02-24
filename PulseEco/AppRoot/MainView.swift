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
    @State var sensorSelectionAlertDialogIsActive: Bool = false
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
    
    private func isLoading() -> Bool {
        return (appState.loadingCityData || appState.loadingMeasures || (locationManager.isAuthorizationGranted() && locationManager.isWaitingToFetchRegion) || appState.isWaitingToFetchFavouriteCitiesOveralls)
    }
    
    var body: some View {
        Group {
            if isLoading() {
                loadingView
            } else {
                contentView
            }
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(item: $appState.activeSheet) { sheet in
            switch sheet {
            case .disclaimerView: DisclaimerView()
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
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    if self.appState.citySelectorClicked {
                        FavouriteCitiesView(userSettings: self.appState.userSettings)
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
                        
                        ZStack(alignment: .top) {
                            DateSelector()
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .zIndex(2)
                            
                            CityMapView(userSettings: self.appState.userSettings,
                                        mapViewModel: mapViewModel)
                            .id("CityMapView")
                            .edgesIgnoringSafeArea([.horizontal, .bottom])
                            .padding(.top, 60)
                            .zIndex(1)
                            .sheet(isPresented: $appState.showSensorDetails) {
                                Spacer()
                                
                                SensorDetailsView(viewModel: sensorDetailsViewModel,
                                                  sensorSelectionAlertDialogIsActive: $sensorSelectionAlertDialogIsActive,
                                                  contentSize: $appState.bottomSheetContentSize,
                                                  headerSize: $appState.bottomSheetHeaderSize)
                                .frame(maxWidth: .infinity)
                                .presentationDetents([.height(appState.bottomSheetHeaderSize), .height(appState.bottomSheetContentSize + appState.bottomSheetHeaderSize)], selection: $appState.seletionDetent)
                                .presentationBackgroundInteraction(.enabled)
                                .interactiveDismissDisabled()
                            }
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
        }
        .overlay(
            SensorSelectionView(viewModel: SensorSelectionViewModel(appState: self.appState,
                                                                    sensors: combine(sensors: dataSource.citySensors,
                                                                                     sensorsData: dataSource.sensorsData,
                                                                                     selectedMeasure: dataSource.getCurrentMeasure(selectedMeasure: appState.selectedMeasureId))),
                                sensorSelectionAlertDialogIsActive: $sensorSelectionAlertDialogIsActive)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        )
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
                .navigationDestination(for: AppView.self) { view in
                    switch view {
                    case .settings:
                        SettingsView()
                    case .dashboard:
                        Text("dashboard view")
                    case .mapView:
                        Text("Map View")
                    }
                }
        }
    }
    
    var menuItem: some View {
        Menu {
            Section {
                NavigationLink(value: AppView.dashboard) {
                    Text(Trema.text(for: "dashboard_view"))
                    Spacer()
                    if self.appState.selectedAppView == .dashboard {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(AppColors.darkblue))
                    }
                }
                NavigationLink(value: AppView.mapView) {
                    Text(Trema.text(for: "map_view"))
                    Spacer()
                    if self.appState.selectedAppView == .mapView {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(AppColors.darkblue))
                    }
                }
                NavigationLink(value: AppView.settings) {
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
                self.appState.selectedSensor = nil
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

