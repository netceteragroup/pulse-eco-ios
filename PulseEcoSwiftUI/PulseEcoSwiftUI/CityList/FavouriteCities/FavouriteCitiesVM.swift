//
//  CityListVM.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/17/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI

class FavouriteCitiesVM: ObservableObject {
    @Published var cityList: [FavouriteCityRowVM] = []
    var selectedMeasure: String

    init(selectedMeasure: String, favouriteCities: Set<CityModel>, cityValues: [CityOverallValues], measureList: [Measure]) {
        self.selectedMeasure = selectedMeasure
        var value: String? = nil
        for city in favouriteCities {
            value = nil
            if let cityValue = cityValues.last(where: { $0.cityName == city.cityName
            }) {
                if let averageValue = cityValue.values[selectedMeasure.lowercased()] {
                    if let floatValue = Float(averageValue) {
                        value = String(floatValue)
                    }
                }
            }
            let selMeasure = measureList.filter{ $0.id.lowercased() == selectedMeasure.lowercased()}.first ?? Measure.empty()
            var message = Trema.text(for: "no_data_available", language: UserDefaults.standard.string(forKey: "AppLanguage") ?? "en")
            var color = Color.gray
            
            if let val = Float(value ?? "") {
                if Int(val) < selMeasure.legendMin {
                    message = selMeasure.bands[0].shortGrade
                    color = Color(AppColors.colorFrom(string: selMeasure.bands[0].legendColor))
                } else if Int(val) > selMeasure.legendMax {
                    message = selMeasure.bands[selMeasure.bands.count - 1].shortGrade
                    color = Color(AppColors.colorFrom(string: selMeasure.bands[selMeasure.bands.count - 1].legendColor))
                } else {
                    selMeasure.bands.forEach{ band in
                        if valueInBand(from: band.from, to: band.to, value: val) {
                            message = band.shortGrade
                            color = Color(AppColors.colorFrom(string: band.legendColor))
                            return
                        }
                    }
                }
            }
            
            self.cityList.append(FavouriteCityRowVM(city: city, message: message, value: value, unit: selMeasure.unit, color: color))
        }
    }
    
    func valueInBand(from: Int, to: Int, value: Float) -> Bool {
        return Int(value) >= from && Int(value) <= to
    }
    
    func getCities() -> [FavouriteCityRowVM] {
        return self.cityList.sorted { $0.siteName < $1.siteName}
    }
}

