//
//  MainView.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/16/20.
//

import SwiftUI
import Factory

struct MainView: View {
    private let logger = SystemLoggerAdapter(category: "MainView")
    
    @StateObject private var viewModel = MainViewModel()
    @State private var bottomSheetContentSize: CGFloat = .zero
    @State private var bottomSheetHeaderSize: CGFloat = .zero
    @State private var selectionDetent = PresentationDetent.height(.zero)
    @State private var showingCalendar: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var showSensorDetails: Bool = true
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.presentationMode) var presentationMode
    @Injected(\.appData) private var appData
    @Injected(\.appDataManager) private var appDataManager
    
    @State private var sensorSelectionAlertDialogIsActive = false
    let mapViewModel: MapViewModel
        
    private var sensorDetailsViewModel: SensorDetailsViewModel {
        let selectedMeasure = appDataManager.getCurrentMeasure(selectedMeasure: appData.selectedMeasureId)
        return SensorDetailsViewModel(
            sensor: appData.selectedSensor ?? SensorPinModel(),
            selectedMeasure: selectedMeasure,
            sensorData24h: appData.sensorsData24h
        )
    }
    
    private var isLoading: Bool {
        return viewModel.isLoading ||
               appData.loadingCityData ||
               appData.loadingMeasures ||
               appData.isWaitingToFetchFavouriteCitiesOveralls
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
        .onReceive(viewModel.onLocationSetSubject, perform: { city in changeLocation(city: city) })
        .onAppear {
            viewModel.onMainViewAppear()
            selectedDate = appData.selectedDate
        }
    }
    
    private func changeLocation(city: City) {
        guard UserSettings.selectedCity != city else { return }
        logger.logDebug("City updated: \(city.cityName)")
        UserSettings.selectedCity = city
        appDataManager.fetchData(cityName: city.cityName, sensorType: appData.selectedMeasureId, selectedDate: appData.selectedDate)
    }
    
    var loadingView: some View {
        LoadingDialog()
    }
    
    var contentView: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    if appData.citySelectorClicked {
                        FavouriteCitiesView()
                            .overlay(ShadowOnTopOfView())
                            .animation(nil, value: appData.citySelectorClicked)
                            .edgesIgnoringSafeArea(.bottom)
                    } else {
                        VStack(spacing: 0) {
                            let measureViewModel = MeasureListViewModel(
                                selectedMeasure: appData.selectedMeasureId,
                                cityName: UserSettings.selectedCity.cityName,
                                measuresList: appData.measures,
                                cityValues: appData.cityOverall,
                                citySelectorClicked: appData.citySelectorClicked
                            )
                            MeasureListView(viewModel: measureViewModel)
                        }
                        
                        ZStack(alignment: .top) {
                            DateSelector(showingCalendar: $showingCalendar, selectedDate: $selectedDate)
                                .zIndex(2)
                            
                            CityMapView(
                                bottomSheetHeaderSize: $bottomSheetHeaderSize, mapViewModel: mapViewModel
                            )
                            .id("CityMapView")
                            .edgesIgnoringSafeArea([.horizontal, .bottom])
                            .padding(.top, 60)
                            .zIndex(1)
                            .sheet(isPresented: $showSensorDetails) {
                                Spacer()
                                SensorDetailsView(
                                    viewModel: sensorDetailsViewModel,
                                    sensorSelectionAlertDialogIsActive: $sensorSelectionAlertDialogIsActive,
                                    contentSize: $bottomSheetContentSize,
                                    headerSize: $bottomSheetHeaderSize
                                )
                                .frame(maxWidth: .infinity)
                                .presentationDetents([
                                    .height(bottomSheetHeaderSize),
                                    .height(bottomSheetContentSize + bottomSheetHeaderSize)
                                ], selection: $selectionDetent)
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
                                    viewModel.onPulseLogoTap()
                                }
                            leadingNavigationItems
                        }
                    }
                    ToolbarItemGroup(placement: .primaryAction) {
                        languageChangeButton
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
                    sensors: appData.sensorPins
                ),
                sensorSelectionAlertDialogIsActive: $sensorSelectionAlertDialogIsActive
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        )
    }
    
    // MARK: - Toolbar & Navigation
    var languageChangeButton: some View {
        Menu {
            ForEach(Countries.countries(language: Trema.appLanguage), id: \.self) { country in
                Button {
                    viewModel.selectCountry(country: country)
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
                viewModel.onLeadingNavigationItemTap()
            }
        }) {
            HStack {
                Text(UserSettings.selectedCity.cityName.uppercased())
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(AppColors.darkblue))
                appData.cityIcon.foregroundColor(Color(AppColors.darkblue))
            }
        }
        .accentColor(AppColors.black.color)
    }
}

extension View {
    func navigationBarColor(_ backgroundColor: UIColor?) -> some View {
        modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }
}
