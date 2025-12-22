//
//  MainViewModel.swift
//  PulseEco
//
//  Created by Stanislava Mladenovska on 4.11.25.
//

import Foundation
import Combine
import Factory

@MainActor
class MainViewModel: ObservableObject {
    @Injected(\.locationService) private var locationService
    @Injected(\.appData) private var appData
    @Injected(\.refreshService) private var refreshService
    @Injected(\.appDataManager) private var appDataManager
    
    @Published var isLoading: Bool = true
    
    let onLocationSetSubject = PassthroughSubject<City, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    private var firstTimeLoad: Bool = false
    
    init() {
        checkLocation()
    }
    
    func onMainViewAppear() {
        appDataManager.startInitialFetch()
        refreshService.refreshDataIfNeeded()
    }
    
    func onPulseLogoTap() {
        if !appData.citySelectorClicked {
            appData.selectedSensor = nil
            refreshService.refreshData()
        }
    }
    
    func onLeadingNavigationItemTap() {
        appData.citySelectorClicked.toggle()
        appData.selectedSensor = nil
    }
    
    func selectCountry(country: Country) {
        Trema.appLanguage = country.shortName
        appDataManager.getMeasures()
        appData.loadingMeasures = true
        refreshService.updateRefreshDate()
        appDataManager.fetchData(cityName: UserSettings.selectedCity.cityName, sensorType: appData.selectedMeasureId, selectedDate: appData.selectedDate)
    }
    
    private func checkLocation() {
        let status = locationService.currentAuthorizationStatus()
        
        switch status {
        case .authorized:
            fetchLocation()
        case .notDetermined:
            // Ask permission; observe authorization changes
            observeAuthorization()
        case .denied:
            // Fallback immediately
            fallbackToDefaultCity()
        }
    }
    
    private func observeAuthorization() {
        locationService
            .authorizationStatusObserver()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .authorized:
                    self.fetchLocation()
                case .denied:
                    self.fallbackToDefaultCity()
                case .notDetermined:
                    break // still waiting
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchLocation() {
        locationService
            .locationObserver()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newCity in
                guard let self = self else { return }
                
                if !newCity.cityName.isEmpty {
                    self.onLocationSetSubject.send(newCity)
                } else {
                    self.fallbackToDefaultCity()
                }
                self.isLoading = false

            }
            .store(in: &cancellables)
    }
    
    private func fallbackToDefaultCity() {
        onLocationSetSubject.send(.defaultCity())
        isLoading = false
    }
}
