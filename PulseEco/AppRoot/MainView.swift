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
    
    @EnvironmentObject var appData: AppData
    @Injected(\.refreshService) private var refreshService
    @Injected(\.appDataManager) private var appDataManager

    @State private var sensorSelectionAlertDialogIsActive: Bool = false
    @State private var showSensorDetails: Bool = true
    @State private var citySelectorClicked: Bool = false
    let cityMapViewModel: CityMapViewModel
        
    private var sensorDetailsViewModel: SensorDetailsViewModel {
        let selectedMeasure = appDataManager.getCurrentMeasure(selectedMeasure: appData.selectedMeasureId)
        return SensorDetailsViewModel(
            appData: appData,
            sensor: appData.selectedSensor ?? SensorPinModel(),
            selectedMeasure: selectedMeasure,
            sensorData24h: appData.sensorsData24h
        )
    }
    
    private var isLoading: Bool {
        return viewModel.isLoading ||
               appData.loadingCityData ||
               appData.loadingMeasures ||
               appData.isWaitingToFetchFavoriteCitiesOveralls
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
            appDataManager.startInitialFetch()
            viewModel.start()
        }
    }
    
    private func changeLocation(city: City) {
        logger.logDebug("City updated: \(city.cityName)")
        UserSettings.selectedCity = city
        refreshService.updateRefreshDate()
        appDataManager.fetchData()
    }
    
    var loadingView: some View {
        LoadingDialog()
    }
    
    var contentView: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    if citySelectorClicked {
                        FavoriteCitiesView(viewModel: FavoriteCitiesViewModel(appData: appData),
                                            citySelectorClicked: $citySelectorClicked)
                            .overlay(ShadowOnTopOfView())
                            .animation(nil, value: citySelectorClicked)
                            .edgesIgnoringSafeArea(.bottom)
                    } else {
                        VStack(spacing: 0) {
                            let measureViewModel = MeasureListViewModel(
                                selectedMeasure: appData.selectedMeasureId,
                                cityName: UserSettings.selectedCity.cityName,
                                measuresList: appData.measures,
                                cityValues: appData.cityOverall
                            )
                            MeasureListView(viewModel: measureViewModel)
                        }
                        
                        ZStack(alignment: .top) {
                            DateSelector(selectedDate: appData.selectedDate)
                                .zIndex(2)
                            
                            CityMapView(bottomSheetHeaderSize: $bottomSheetHeaderSize, viewModel: cityMapViewModel)
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
                                    if !citySelectorClicked {
                                        appData.selectedSensor = nil
                                        refreshService.refreshData()
                                    }
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
                    appData: appData,
                    sensors: appData.sensorPins
                ),
                sensorSelectionAlertDialogIsActive: $sensorSelectionAlertDialogIsActive,
                showSensorDetails: $showSensorDetails
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        )
    }
    
    // MARK: - Toolbar & Navigation
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
                citySelectorClicked.toggle()
                appData.selectedSensor = nil
            }
        }) {
            HStack {
                Text(UserSettings.selectedCity.cityName.uppercased())
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(AppColors.darkblue))
                cityIcon.foregroundColor(Color(AppColors.darkblue))
            }
        }
        .accentColor(AppColors.black.color)
    }
    
    private var cityIcon: some View {
        citySelectorClicked ? Image(systemName: "chevron.up") : Image(systemName: "chevron.down")
    }
}

extension MainView {
    private func selectCountry(country: Country) {
        Trema.appLanguage = country.shortName
        appDataManager.getMeasures()
        appData.loadingMeasures = true
        refreshService.updateRefreshDate()
        appDataManager.fetchData()
    }
}

extension View {
    func navigationBarColor(_ backgroundColor: UIColor?) -> some View {
        modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }
}
