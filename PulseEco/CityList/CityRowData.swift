//
//  CityRowData.swift
//  PulseEco
//
//  Created by Jovana Trajcheska on 27.2.23.
//

import Foundation
import SwiftUI

class CityRowData {
    func updateCityRowValues(for city: City,
                             cityValues: [CityOverallValues],
                             selectedMeasure: String,
                             measureList: [Measure]) -> FavouriteCityRowViewModel {
        var value: String?
        if let cityValue = cityValues.last(where: { $0.cityName == city.cityName
        }) {
            if let averageValue = cityValue.values[selectedMeasure.lowercased()] {
                if let floatValue = Float(averageValue) {
                    value = String(floatValue)
                }
            }
        }
        let selMeasure = measureList
            .filter { $0.id.lowercased() == selectedMeasure.lowercased() }.first ?? Measure.empty()
        var message = Trema.text(for: "no_data_available")
        var color = AppColors.gray.color
        if let val = Float(value ?? "") {
            if Int(val) < selMeasure.legendMin {
                message = selMeasure.bands[0].shortGrade
                color = Color(AppColors.colorFrom(string: selMeasure.bands[0].legendColor))
            } else if Int(val) > selMeasure.legendMax {
                message = selMeasure.bands[selMeasure.bands.count - 1].shortGrade
                color = Color(AppColors.colorFrom(string: selMeasure.bands[selMeasure.bands.count - 1].legendColor))
            } else {
                selMeasure.bands.forEach { band in
                    if valueInBand(from: band.from, to: band.to, value: val) {
                        message = band.shortGrade
                        color = Color(AppColors.colorFrom(string: band.legendColor))
                        return
                    }
                }
            }
        }
        return FavouriteCityRowViewModel(city: city,
                                         message: message,
                                         value: value,
                                         unit: selMeasure.unit,
                                         color: color)
    }
    
    func valueInBand(from: Int, to: Int, value: Float) -> Bool {
        return Int(value) >= from && Int(value) <= to
    }
}