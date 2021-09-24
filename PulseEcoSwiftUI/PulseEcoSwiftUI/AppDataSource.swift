import Foundation
import Combine

class AppDataSource: ObservableObject {
    @Published var measures: [Measure] = [Measure.empty("PM10"),
                                          Measure.empty("PM25"),
                                          Measure.empty("Noise"),
                                          Measure.empty("Temperature"),
                                          Measure.empty("Humidity"),
                                          Measure.empty("Pressure"),
                                          Measure.empty("NO2"),
                                          Measure.empty("O3")]
    @Published var citySensors: [Sensor] = []
    @Published var cityOverall: CityOverallValues?
    @Published var userSettings: UserSettings = UserSettings()
    @Published var sensorsData: [SensorData] = []
    @Published var sensorsDailyAverageData: [SensorData] = []
    @Published var sensorsData24h: [SensorData] = []
    @Published var cities: [City] = []
    @Published var cancellationTokens: [AnyCancellable] = []
    @Published var loadingCityData: Bool = true
    @Published var loadingMeasures: Bool = true
    
    var cancelables = Set<AnyCancellable>()
    var subscripiton: AnyCancellable?
    private let networkService = NetworkService()
    
    init() {
        // getCities()
        getMeasures()
        getValuesForCity()
        subscripiton = RunLoop.main.schedule(after: RunLoop.main.now, interval: .seconds(600)) {
            self.emptyCityOverallValueList()
            self.getCities()
        } as? AnyCancellable
        //getOverallValuesForFavoriteCities()
    }
    
    func getMeasures() {
        networkService.downloadMeasures().sink(receiveCompletion: { _ in
            self.loadingMeasures = false
        }, receiveValue: { measures in
            self.measures = measures
        })
            .store(in: &cancelables)
    }
    
    func getValuesForCity(cityName: String = "Skopje") {
        getOverallValues(city: cityName)
        getSensors(city: cityName)
        getCurrentDataForSensors(city: cityName)
        get24hDataForSensors(city: cityName)
    }
    
    func getOverallValues(city: String) {
        networkService.downloadOverallValuesForCity(cityName: city).sink(receiveCompletion: { _ in  }, receiveValue: { values in
            self.cityOverall = values
        })
            .store(in: &cancelables)
    }
    
    func getOverallValuesForFavoriteCities(city: String = "Skopje") {
        
        self.cities.forEach { city in
            networkService.downloadOverallValuesForCity(cityName: city.cityName).sink(receiveCompletion: { _ in  }, receiveValue: { values in
                self.userSettings.cityValues.append(values)
            })
                .store(in: &cancelables)
        }
    }
    
    func emptyCityOverallValueList() {
        self.userSettings.cityValues.removeAll()
    }
    
    func getSensors(city: String) {
        networkService.downloadSensors(cityName: city)
            .sink(receiveCompletion: { _ in  self.loadingCityData = false },
                  receiveValue: { sensors in
                self.citySensors = sensors
            })
            .store(in: &cancelables)
    }
    
    func getCurrentDataForSensors(city: String) {
        networkService.downloadCurrentDataForSensors(cityName: city).sink(receiveCompletion: { _ in }, receiveValue: { sensors in
            self.sensorsData = sensors
        })
            .store(in: &cancelables)
    }
    
    func get24hDataForSensors(city: String) {
        networkService.download24hDataForSensors(cityName: city).sink(receiveCompletion: { _ in }, receiveValue: { sensors in
            self.sensorsData24h = sensors
        })
            .store(in: &cancelables)
    }
    
    func getCities() {
        networkService.downloadCities().sink(receiveCompletion: { _ in
            self.cities.forEach { city in
                self.cancellationTokens.append(NetworkService().downloadOverallValuesForCity(cityName: city.cityName)
                                                .sink(receiveCompletion: { _ in },
                                                      receiveValue: { values in
                    self.userSettings.cityValues.append(values)
                }))
            }
        }, receiveValue: { cities in
            self.cities = cities
        })
        .store(in: &cancelables)
    }
    
    func getCurrentMeasure(selectedMeasure: String) -> Measure {
        return measures.filter{ $0.id.lowercased() == selectedMeasure.lowercased()}.first ?? Measure.empty()
    }
    
    func getDailyAverageDataForSensor(cityName: String,
                                      measureType: String,
                                      sensorId: String) {
        networkService
            .downloadDailyAverageDataForSensor(cityName: cityName,
                                               measureType: measureType,
                                               sensorId: sensorId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { dailyAverage in
                self.sensorsDailyAverageData = dailyAverage
            })
            .store(in: &cancelables)
    }
}
