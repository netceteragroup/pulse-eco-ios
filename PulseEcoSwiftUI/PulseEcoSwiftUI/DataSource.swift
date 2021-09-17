import Foundation
import Combine

class DataSource: ObservableObject {
    @Published var measures: [Measure] = [Measure.empty("PM10"),Measure.empty("PM25"),Measure.empty("Noise"),Measure.empty("Temperature"),Measure.empty("Humidity"),Measure.empty("Pressure"), Measure.empty("NO2"), Measure.empty("O3")]
    @Published var citySensors: [Sensor] = []
    @Published var cityOverall: CityOverallValues?
    @Published var userSettings: UserSettings = UserSettings()
    @Published var sensorsData: [SensorData] = []
    @Published var sensorsDailyAverageData: [SensorData] = []
    @Published var sensorsData24h: [SensorData] = []
    @Published var cities: [CityModel] = []
    @Published var cancellationTokens: [AnyCancellable] = []
    @Published var loadingCityData: Bool = true
    @Published var loadingMeasures: Bool = true
    private var cancellableMeasures: AnyCancellable?
    private var cancellableOverallValues: AnyCancellable?
    private var cancellableOverallValuesList: AnyCancellable?
    private var cancellableSensors: AnyCancellable?
    private var cancellableSensorData: AnyCancellable?
    private var cancellableSensorData24h: AnyCancellable?
    private var cancellableCities: AnyCancellable?
    private var cancellableSensorsDailyAverageData: AnyCancellable?
    
    var subscripiton: AnyCancellable?
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
        self.cancellableMeasures = NetworkManager().downloadMeasures().sink(receiveCompletion: { _ in
            self.loadingMeasures = false
        }, receiveValue: { measures in
            self.measures = measures
        })
    }
    
    func getValuesForCity(cityName: String = "Skopje") {
        getOverallValues(city: cityName)
        getSensors(city: cityName)
        getCurrentDataForSensors(city: cityName)
        get24hDataForSensors(city: cityName) 
    }
    func getOverallValues(city: String) {
        self.cancellableOverallValues = NetworkManager().downloadOverallValuesForCity(cityName: city).sink(receiveCompletion: { _ in  }, receiveValue: { values in
            self.cityOverall = values
        })
    }
    
    func getOverallValuesForFavoriteCities(city: String = "Skopje") {
        
        self.cities.forEach { city in
            self.cancellableOverallValuesList = NetworkManager().downloadOverallValuesForCity(cityName: city.cityName).sink(receiveCompletion: { _ in  }, receiveValue: { values in
                self.userSettings.cityValues.append(values)
            })
        }
    }
    
    func emptyCityOverallValueList() {
        self.userSettings.cityValues.removeAll()
    }
    func getSensors(city: String) {
        self.cancellableSensors = NetworkManager().downloadSensors(cityName: city).sink(receiveCompletion: { _ in  self.loadingCityData = false }, receiveValue: { sensors in
            self.citySensors = sensors
        })
    }
    func getCurrentDataForSensors(city: String) {
        self.cancellableSensorData = NetworkManager().downloadCurrentDataForSensors(cityName: city).sink(receiveCompletion: { _ in }, receiveValue: { sensors in
            self.sensorsData = sensors
        })
    }
    func get24hDataForSensors(city: String) {
        self.cancellableSensorData24h = NetworkManager().download24hDataForSensors(cityName: city).sink(receiveCompletion: { _ in }, receiveValue: { sensors in
            self.sensorsData24h = sensors
        })
    }
    func getCities() {
        self.cancellableCities = NetworkManager().downloadCities().sink(receiveCompletion: { _ in
            self.cities.forEach { city in
                self.cancellationTokens.append(NetworkManager().downloadOverallValuesForCity(cityName: city.cityName).sink(receiveCompletion: { _ in }, receiveValue: { values in
                    self.userSettings.cityValues.append(values)
                }))
            }
        }, receiveValue: { cities in
            self.cities = cities
        })
    }
    
    func getCurrentMeasure(selectedMeasure: String) -> Measure {
        return measures.filter{ $0.id.lowercased() == selectedMeasure.lowercased()}.first ?? Measure.empty()
    }
    
    func getDailyAverageDataForSensor(cityName: String,
                                      measureType: String,
                                      sensorId: String) {
        self.cancellableSensorsDailyAverageData = NetworkManager()
            .downloadDailyAverageDataForSensor(cityName: cityName,
                                               measureType: measureType,
                                               sensorId: sensorId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { dailyAverage in
                    self.sensorsDailyAverageData = dailyAverage
                  })
    }
}
