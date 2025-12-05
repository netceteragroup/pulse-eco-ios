//
//  MainView.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/16/20.
//

import SwiftUI

struct MainView: View {
    private let logger = SystemLoggerAdapter(category: "MainView")
    
    @StateObject private var viewModel = MainViewModel()
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var refreshService: RefreshService
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    
    @State private var sensorSelectionAlertDialogIsActive = false
    let mapViewModel: MapViewModel
        
    private var sensorDetailsViewModel: SensorDetailsViewModel {
        let selectedMeasure = dataSource.getCurrentMeasure(selectedMeasure: appState.selectedMeasureId)
        return SensorDetailsViewModel(
            sensor: appState.selectedSensor ?? SensorPinModel(),
            selectedMeasure: selectedMeasure,
            sensorData24h: dataSource.sensorsData24h,
            dailyAverages: dataSource.sensorsDailyAverageData
        )
    }
    
    private var isLoading: Bool {
        return viewModel.isLoading ||
               appState.loadingCityData ||
               appState.loadingMeasures ||
               appState.isWaitingToFetchFavouriteCitiesOveralls
    }
    
    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else {
                contentView
            }
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(item: $appState.activeSheet) { sheet in
            switch sheet {
            case .disclaimerView:
                DisclaimerView()
            }
        }
        .onReceive(viewModel.onLocationSetSubject, perform: { city in changeLocation(city: city) })
    }
    
    private func changeLocation(city: City) {
        appState.currentLocationIsSelected = true
        guard appState.selectedCity != city else { return }
        logger.logDebug("City updated: \(city.cityName)")
        appState.selectedCity = city
        dataSource.getValuesForCity(cityName: city.cityName)
    }
    
    var loadingView: some View {
        LoadingDialog()
    }
    
    var contentView: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    if appState.citySelectorClicked {
                        FavouriteCitiesView()
                            .overlay(ShadowOnTopOfView())
                            .animation(nil, value: appState.citySelectorClicked)
                            .edgesIgnoringSafeArea(.bottom)
                    } else {
                        VStack(spacing: 0) {
                            let measureViewModel = MeasureListViewModel(
                                selectedMeasure: appState.selectedMeasureId,
                                cityName: appState.selectedCity.cityName,
                                measuresList: dataSource.measures,
                                cityValues: dataSource.cityOverall,
                                citySelectorClicked: appState.citySelectorClicked
                            )
                            MeasureListView(viewModel: measureViewModel)
                        }
                        
                        ZStack(alignment: .top) {
                            DateSelector()
                                .zIndex(2)
                            
                            CityMapView(
                                mapViewModel: mapViewModel
                            )
                            .id("CityMapView")
                            .edgesIgnoringSafeArea([.horizontal, .bottom])
                            .padding(.top, 60)
                            .zIndex(1)
                            .sheet(isPresented: $appState.showSensorDetails) {
                                Spacer()
                                SensorDetailsView(
                                    viewModel: sensorDetailsViewModel,
                                    sensorSelectionAlertDialogIsActive: $sensorSelectionAlertDialogIsActive,
                                    contentSize: $appState.bottomSheetContentSize,
                                    headerSize: $appState.bottomSheetHeaderSize
                                )
                                .frame(maxWidth: .infinity)
                                .presentationDetents([
                                    .height(appState.bottomSheetHeaderSize),
                                    .height(appState.bottomSheetContentSize + appState.bottomSheetHeaderSize)
                                ], selection: $appState.seletionDetent)
                                .presentationBackgroundInteraction(.enabled)
                                .interactiveDismissDisabled()
                            }
                        }
                    }
                }
                .navigationBarTitle("", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        HStack {
                            Image(uiImage: UIImage(named: "logo-pulse") ?? UIImage())
                                .imageScale(.large)
                                .onTapGesture {
                                    if !appState.citySelectorClicked {
                                        appState.selectedSensor = nil
                                        refreshService.refreshData()
                                    }
                                }
                            leadingNavigationItems
                        }
                    }
                    ToolbarItemGroup(placement: .primaryAction) {
                        if appState.showMenu {
                            menuTrailingNavigationItem
                        } else {
                            languageChangeButton
                        }
                    }
                }
            }
            .if(.pad) { $0.navigationViewStyle(StackNavigationViewStyle()) }
            .navigationBarColor(AppColors.white)
            .zIndex(1)
        }
        .overlay(
            SensorSelectionView(
                viewModel: SensorSelectionViewModel(
                    appState: appState,
                    sensors: combine(
                        sensors: dataSource.citySensors,
                        sensorsData: dataSource.sensorsData,
                        selectedMeasure: dataSource.getCurrentMeasure(selectedMeasure: appState.selectedMeasureId)
                    )
                ),
                sensorSelectionAlertDialogIsActive: $sensorSelectionAlertDialogIsActive
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        )
    }
    
    // MARK: - Toolbar & Navigation
    var menuTrailingNavigationItem: some View {
        menuItem
            .navigationDestination(for: AppView.self) { view in
                switch view {
                case .settings: SettingsView()
                case .dashboard: Text("dashboard view")
                case .mapView: Text("Map View")
                }
            }
    }
    
    var menuItem: some View {
        Menu {
            Section {
                NavigationLink(value: AppView.dashboard) {
                    Text(Trema.text(for: "dashboard_view"))
                    Spacer()
                    if appState.selectedAppView == .dashboard {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(AppColors.darkblue))
                    }
                }
                NavigationLink(value: AppView.mapView) {
                    Text(Trema.text(for: "map_view"))
                    Spacer()
                    if appState.selectedAppView == .mapView {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(AppColors.darkblue))
                    }
                }
                NavigationLink(value: AppView.settings) {
                    Text(Trema.text(for: "settings_view"))
                    Spacer()
                    if appState.selectedAppView == .settings {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(AppColors.darkblue))
                    }
                }
            }
        } label: {
            Image(systemName: "line.horizontal.3")
                .resizable()
                .frame(width: 25, height: 15)
                .foregroundColor(Color(AppColors.darkblue))
                .padding(.leading, 15)
        }
    }
    
    var languageChangeButton: some View {
        Menu {
            ForEach(Countries.countries(language: Trema.appLanguage), id: \.self) { country in
                Button {
                    selectCountry(country: country)
                } label: {
                    HStack {
                        Text(country.languageName)
                        if country.shortName == Trema.appLanguage {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(AppColors.darkblue))
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "globe")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(Color(AppColors.darkblue))
        }
    }
    
    var leadingNavigationItems: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                appState.citySelectorClicked.toggle()
                appState.selectedSensor = nil
            }
        }) {
            HStack {
                Text(appState.selectedCity.cityName.uppercased())
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(AppColors.darkblue))
                appState.cityIcon.foregroundColor(Color(AppColors.darkblue))
            }
        }
        .accentColor(AppColors.black.color)
    }
}

extension MainView {
    private func selectCountry(country: Country) {
        Trema.appLanguage = country.shortName
        appState.selectedLanguage = Trema.appLanguage
        dataSource.getMeasures()
        appState.loadingMeasures = true
        refreshService.updateRefreshDate()
        dataSource.getValuesForCity(cityName: appState.selectedCity.cityName)
    }
}

extension View {
    func navigationBarColor(_ backgroundColor: UIColor?) -> some View {
        modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }
}
