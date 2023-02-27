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
    @State var showingPicker = false
    var cityRowData = CityRowData()
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
            if appState.loadingCityData || appState.loadingMeasures {
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
    }
    
    var loadingView: some View {
        LoadingDialog()
    }
    
    @ViewBuilder
    var mainView: some View {
        switch appState.selectedAppView {
        case .mapView:
            mapView
        case .dashboard:
            dashboardView
        case .settings:
            //TODO: check which view should be shown when the user gets back from settings
           mapView
        }
    }

    var mapView: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                DateSlider(unimplementedAlert: $appState.showingCalendar,
                           unimplementedPicker: $showingPicker,
                           selectedDate: $appState.selectedDate)
                
                ZStack(alignment: .top) {
                    CityMapView(userSettings: self.appState.userSettings,
                                mapViewModel: mapViewModel,
                                proxy: proxy)
                    .id("CityMapView")
                    .edgesIgnoringSafeArea([.horizontal, .bottom])
                }
                if appState.showSensorDetails {
                    SlideOverCard {
                        SensorDetailsView(viewModel: sensorDetailsViewModel)
                            .frame(maxWidth: UIScreen.main.bounds.width)
                    }
                    .transition(.move(edge: .bottom))
                    .zIndex(2) // zIndexes are needed to maintain dismiss transition
                }
                if appState.showingCalendar {
                    VStack {
                        CalendarView(showingCalendar: $appState.showingCalendar,
                                     selectedDate: $appState.selectedDate,
                                     calendarSelection: $appState.calendarSelection,
                                     viewModelClosure: CalendarViewModel(appState: self.appState,
                                                                         appDataSource: self.dataSource))
                        .cornerRadius(4)
                        .shadow(color: Color(AppColors.shadowColor), radius: 20)
                        .padding(.top, 180)
                        .padding(.all)
                        Spacer()
                    }
                    .background(Color.gray.opacity(0.8).onTapGesture {
                        appState.showingCalendar = false
                    })
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(3)
                }
            }
        }
    }
    
    var contentView: some View {
            ZStack(alignment: .top) {
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
                       
                        NavigationLink(destination: SettingsView(),
                                       isActive: $isShowingSettingsView) { EmptyView () }
                       mainView
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
        }
    
    //TODO: Style the dashboard view properly (according to Figma)
    var dashboardView: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {
                    FavouriteCityRowView(viewModel: cityRowData.updateCityRowValues(for: appState.selectedCity,
                                                                                    cityValues: appState.userSettings.cityValues,
                                                                                    selectedMeasure: appState.selectedMeasureId,
                                                                                    measureList: dataSource.measures))
                    .contentShape(RoundedRectangle(cornerRadius: 2.0))
                    Text("Add the next view that it is a part of the dashboard view HERE")
                }
                .padding(.all, 16)
                Spacer()
                if self.appState.citySelectorClicked {
                    FavouriteCitiesView(viewModel:
                                            FavouriteCitiesViewModel(
                                                selectedMeasure: appState.selectedMeasureId,
                                                favouriteCities: appState.userSettings.favouriteCities,
                                                cityValues: appState.userSettings.cityValues,
                                                measureList: dataSource.measures),
                                        userSettings: appState.userSettings,
                                        proxy: proxy)
                    .overlay(ShadowOnTopOfView())
                    .animation(nil, value: self.appState.citySelectorClicked)
                }
            }
        }
        .overlay(ShadowOnTopOfView())
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

