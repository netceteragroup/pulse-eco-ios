//
//  MainView.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/16/20.
//

import SwiftUI

struct BlueButtonStyle: MenuStyle {
    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
            .foregroundColor(.blue)
    }
}

struct MainView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var refreshService: RefreshService
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    
    @State var showingPicker = false
    @State var didTap:Bool = false

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
                /*TODO: Remove this view from here and add it as an clickable list item in the settings view */
            case .languageView: LanguageView()
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
                        VStack(spacing: 0) {
                            let viewModel = MeasureListViewModel(selectedMeasure: appState.selectedMeasureId,
                                                                 cityName: appState.selectedCity.cityName,
                                                                 measuresList: dataSource.measures,
                                                                 cityValues: dataSource.cityOverall,
                                                                 citySelectorClicked: appState.citySelectorClicked)
                            MeasureListView(viewModel: viewModel)
                        }
                        
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
                    }
                    .navigationBarTitle("", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            leadingNavigationItems
                        }
                        ToolbarItemGroup(placement: .primaryAction) {
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
                                /* TODO: Style the menu view to match figma design.
                                 Hint: https://swiftwithmajid.com/2020/08/05/menus-in-swiftui/
                                 Change background color on click and add checkmark on the available options.
                                 Add a property which will have the value of the last selected user option
                                 Hint: check AppState and used properties there
                                 */

                                Menu {

                                    Section {
                                        Button(action: {}) {
                                            Text("Dashboard View")
                                                                                    }
                                        
                                        Button(action: {}) {
                                            Text("Map View")
                                               // .menuStyle(BlueButtonStyle())
                                            
                                        }
                                        Button(action: {self.didTap = true}) {
                                            Text("Settings")
                                        }

                                    
                                    }
                                    //.menuStyle(BlueButtonStyle())
                                }

                            label: {
                                Image(systemName: "line.horizontal.3")
                                    .resizable()
                                    .frame(width: 25, height: 15, alignment: .center)
                                    .foregroundColor(Color(AppColors.darkblue))
                                    .padding(.leading, 15)
                                }
                            }
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

