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
    
    @Published var isLoading: Bool = true
    
    let onLocationSetSubject = PassthroughSubject<City, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    private var firstTimeLoad: Bool = false
    
    init() {
        checkLocation()
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
            .observe()
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
            .observe()
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
