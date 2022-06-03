import Foundation
import SwiftUI
import Combine

struct AverageUtilModel {
    var value: Float
    var cityName: String
    var clickDisabled: Bool
    var bands: [BandUtilModel] = []
    var currBand: BandUtilModel = BandUtilModel()
    var selectedMeasure: Measure
    
    // MARK: - Init
    init(measureId: String, cityName: String, measuresList: [Measure], cityValues: CityOverallValues?) {
        if let averageValue = cityValues?.values[measureId.lowercased()] {
            if let floatValue = Float(averageValue) {
                self.value = floatValue
                self.clickDisabled = false
            } else {
                self.clickDisabled = true
                self.value = 0
            }
        } else {
            self.clickDisabled = true
            self.value = 0
        }
        
        self.cityName = cityName
        
        self.selectedMeasure = measuresList.filter {
            $0.id.lowercased() == measureId.lowercased()
        }.first ?? Measure.empty()
        
        self.setBandsRange(bands: selectedMeasure.bands)
    }
    
    // MARK: - Public methods
    var sliderValue: Double {
        if isHugeValue {
            return 97
        } else if isLowValue {
            return 0
        } else {
            if self.selectedMeasure.id != "temperature" {
                return (abs(Double(self.value)) - Double(self.min)) * 100 / self.measureBandsWidth
            } else {
                return (abs(Double(self.value)) - Double(self.min - 4)) * 100 / self.measureBandsWidth
            }
        }
    }
    
    var colorForValue: Color {
        currBand.legendColor.color
    }
    
    var rounderValueString: String {
        "\(Int(value))"
    }
    
    var unit: String {
        selectedMeasure.unit
    }
    
    var message: String {
        currBand.grade
    }
    
    var shortMessage: String {
        currBand.shortGrade
    }
    
    var suggestion: String {
        currBand.suggestion
    }
    
    var measurementTitle: String {
        selectedMeasure.buttonTitle
    }
    
    // MARK: - Private methods
    private func band(forValue value: Int?) -> BandUtilModel? {
        return bands.first { $0.valueInBand(value: value) }
    }
    
    private var measureBandsWidth: Double {
        var rangeWidth = 0.0
        
        for indx in 0...selectedMeasure.bands.count-1 {
            let band = selectedMeasure.bands[indx]
            var nextValue = indx >= selectedMeasure.bands.count - 1
                ? abs(Double(abs(self.max) - band.from))
                : Double(abs(band.to) - band.from)
            if indx == 0 {
                nextValue = Double(abs(band.to) - self.min)
            }
            var bandRangeWidth = nextValue
            if isHugeValue && indx == bands.count - 1 {
                bandRangeWidth = nextValue + (Double(self.value) - Double(self.max))
            }
            if isLowValue && indx == 0 {
                bandRangeWidth = nextValue + abs(Double(self.value) + Double(self.min))
            }
            rangeWidth += bandRangeWidth
        }
        return rangeWidth
    }

    private mutating func setBandsRange(bands: [Band]) {
        
        for indx in 0...bands.count-1 {
            let band = bands[indx]
            var nextValue = indx >= bands.count - 1
                ? abs(Double(abs(self.max) - band.from))
                : Double(abs(band.to) - band.from)
            if indx == 0 {
                nextValue = Double(abs(band.to) - self.min)
            }
            var bandRangeWidth = nextValue
            if isHugeValue && indx == bands.count-1 {
                bandRangeWidth = nextValue + (Double(self.value) - Double(self.max))
            }
            if isLowValue && indx == 0 {
                bandRangeWidth = nextValue + abs(Double(self.value) + Double(self.min))
            }
            let width = (bandRangeWidth * 100 ) / self.measureBandsWidth
            let bandVM = BandUtilModel(from: band.from,
                                       to: band.to,
                                       legendPoint: band.legendPoint,
                                       legendColor: AppColors.colorFrom(string: band.legendColor),
                                       markerColor: AppColors.colorFrom(string: band.markerColor),
                                       shortGrade: band.shortGrade,
                                       grade: band.grade,
                                       suggestion: band.suggestion,
                                       width: width)
            self.bands.append(bandVM)
            
            if self.valueInBand(from: band.from, to: band.to) {
                currBand = bandVM
            }
        }
        
        if isHugeValue {
            currBand = self.bands[self.bands.count - 1]
        } else if isLowValue {
            currBand = self.bands[0]
        }
    }

    private var isHugeValue: Bool {
        Int(value) >= max
    }

    private var isLowValue: Bool {
        Int(value) <= min
    }
    
    private var max: Int {
        selectedMeasure.legendMax
    }
    
    private var min: Int {
        selectedMeasure.legendMin
    }

    private func valueInBand(from: Int, to: Int) -> Bool {
        return Int(value) >= from && Int(value) <= to
    }
    
    // MARK: - Dummy data
    static var dummy: AverageUtilModel {
        AverageUtilModel(measureId: "pm10",
                         cityName: "skopje",
                         measuresList: [Measure.dummy],
                         cityValues: CityOverallValues.dummy)
    }
}

struct BandUtilModel: Identifiable {
    let id = UUID()
    
    let from: Int
    let to: Int
    let legendPoint: Int
    let legendColor: UIColor
    let markerColor: UIColor
    let shortGrade: String
    let grade: String
    let suggestion: String
    var width: Double

    init(from: Int = 1,
         to: Int = 1,
         legendPoint: Int = 1,
         legendColor: UIColor = AppColors.gray,
         markerColor: UIColor = AppColors.gray,
         shortGrade: String = "--",
         grade: String = Trema.text(for: "no_data_available"),
         suggestion: String = "--",
         width: Double = 0.0) {
        self.from = from
        self.to = to
        self.legendPoint = legendPoint
        self.legendColor = legendColor
        self.markerColor = markerColor
        self.shortGrade = shortGrade
        self.grade = grade
        self.suggestion = suggestion
        self.width = width
    }

    func valueInBand(value: Int?) -> Bool {
        guard let value = value else {
            return false
        }
        return value >= from && value <= to
    }
}
