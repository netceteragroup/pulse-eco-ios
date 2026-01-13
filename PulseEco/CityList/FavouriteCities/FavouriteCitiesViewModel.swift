//
//  FavoriteCitiesViewModel.swift
//  PulseEco
//
//  Created by Ljuben Angelkoski on 24.12.25.
//

import Combine
import Factory
import SwiftUI

@MainActor
class FavoriteCitiesViewModel: ObservableObject {
    @Injected(\.locationService) private var locationService
    @Injected(\.refreshService) private var refreshService
    @Injected(\.appDataManager) private var appDataManager
    let appData: AppData
        
    init(appData: AppData) {
        self.appData = appData
    }
    
    var cityList: [FavoriteCityRowViewModel] {
        var cities = UserSettings.favoriteCities
            .filter { $0.cityName != locationService.lastLocation?.cityName }
            .map { mapFavoriteCity($0, isCurrentCity: false) }
        if let currentCity = locationService.lastLocation {
            let currentCityRowViewModel = mapFavoriteCity(currentCity, isCurrentCity: true)
            cities.insert(currentCityRowViewModel, at: 0)
        }
        return cities
    }
    
    private func mapFavoriteCity(_ city: City, isCurrentCity: Bool) -> FavoriteCityRowViewModel {
        let cityName = city.cityName
        let filteredValues = appData
            .cityOverallValues
            .last(where: { $0.cityName == cityName})?
            .values
            .filter { Float($0.value) != nil }
        let value = Int(filteredValues?[appData.selectedMeasureId.lowercased()] ?? "0") ?? 0
        let selectedMeasure = appData.measures
            .filter { $0.id.lowercased() == appData.selectedMeasureId.lowercased() }.first ?? Measure.empty()
        let message = getMessage(value: value, selectedMeasure: selectedMeasure)
        let color = getColor(value: value, selectedMeasure: selectedMeasure)
        
        return FavoriteCityRowViewModel(city: city,
                                        message: message,
                                        value: String(value),
                                        unit: selectedMeasure.unit,
                                        color: color,
                                        isCurrentCity: isCurrentCity)
    }
    
    func onCityRowTap(favoriteCity: FavoriteCityRowViewModel) {
        if UserSettings.selectedCity != favoriteCity.city {
            if locationService.lastLocation?.cityName != favoriteCity.city.cityName {
                UserSettings.addFavoriteCity(favoriteCity.city)
            }
            UserSettings.selectedCity = favoriteCity.city
            refreshService.updateRefreshDate()
            appDataManager.fetchData()
        }
    }
    
    private func valueInBand(from: Int, to: Int, value: Float) -> Bool {
        return Int(value) >= from && Int(value) <= to
    }
    
    private func getMessage(value: Int, selectedMeasure: Measure) -> String {
        if value < selectedMeasure.legendMin {
            selectedMeasure.bands[0].shortGrade
        } else if value > selectedMeasure.legendMax {
            selectedMeasure.bands[selectedMeasure.bands.count - 1].shortGrade
        } else {
            selectedMeasure.bands.first { valueInBand(from: $0.from, to: $0.to, value: Float(value)) }?.shortGrade ?? ""
        }
    }
    
    private func getColor(value: Int, selectedMeasure: Measure) -> Color {
        if value < selectedMeasure.legendMin {
            AppColors.colorFrom(string: selectedMeasure.bands[0].legendColor).color
        } else if value > selectedMeasure.legendMax {
            AppColors.colorFrom(string: selectedMeasure.bands[selectedMeasure.bands.count - 1].legendColor).color
        } else {
            AppColors.colorFrom(string: selectedMeasure.bands.first { valueInBand(from: $0.from, to: $0.to, value: Float(value)) }?.legendColor ?? "").color
        }
    }
}
