import Foundation
import Combine

class DataSource: ObservableObject {
    
    @Published var measures: [Measure] = [Measure.empty("PM10"),
                                          Measure.empty("PM25"),
                                          Measure.empty("Noise"),
                                          Measure.empty("Temperature"),
                                          Measure.empty("Humidity"),
                                          Measure.empty("Pressure"),
                                          Measure.empty("NO2"),
                                          Measure.empty("O3")]
    @Published var citySensors: [SensorModel] = []
    @Published var cityOverall: CityOverallValues?
    @Published var userSettings: UserSettings = UserSettings()
    @Published var sensorsData: [Sensor] = []
    @Published var sensorsData24h: [Sensor] = []
    @Published var cities: [CityModel] = []
    @Published var cancellationTokens: [AnyCancellable] = []
    @Published var loadingCityData: Bool = true
    @Published var loadingMeasures: Bool = true
    private var cancellable: Set<AnyCancellable> = []
    
    init() {
       // getCities()
        getMeasures()
        getValuesForCity()
        RunLoop.main.schedule(after: RunLoop.main.now, interval: .seconds(600)) {
            self.emptyCityOverallValueList()
            self.getCities()
        }.store(in: &cancellable)
        //getOverallValuesForFavoriteCities()
    }
    
    func getMeasures() {
        NetworkManager().downloadMeasures()
            .sink(receiveCompletion: { _ in
                self.loadingMeasures = false
            }, receiveValue: { measures in
                self.measures = measures
            })
            .store(in: &cancellable)
    }
    
    func getValuesForCity(cityName: String = "Skopje") {
        getOverallValues(city: cityName)
        getSensors(city: cityName)
        getCurrentDataForSensors(city: cityName)
        get24hDataForSensors(city: cityName) 
    }
    
    func getOverallValues(city: String) {
        NetworkManager().downloadOverallValuesForCity(cityName: city)
            .sink(receiveCompletion: { _ in  },
                  receiveValue: { values in
                    self.cityOverall = values
            })
            .store(in: &cancellable)
    }
    
    func getOverallValuesForFavoriteCities(city: String = "Skopje") {
        self.cities.forEach { city in
            NetworkManager().downloadOverallValuesForCity(cityName: city.cityName)
                .sink(receiveCompletion: { _ in  },
                      receiveValue: { values in
                        self.userSettings.cityValues.append(values)
                })
                .store(in: &cancellable)
        }
    }
    
    func emptyCityOverallValueList() {
        self.userSettings.cityValues.removeAll()
    }
    
    func getSensors(city: String) {
        NetworkManager().downloadSensors(cityName: city)
            .sink(receiveCompletion: { _ in
                self.loadingCityData = false
            }, receiveValue: { sensors in
                self.citySensors = sensors
            })
            .store(in: &cancellable)
    }
    
    func getCurrentDataForSensors(city: String) {
        NetworkManager().downloadCurrentDataForSensors(cityName: city)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { sensors in
                    self.sensorsData = sensors
            })
            .store(in: &cancellable)
    }
    
    func get24hDataForSensors(city: String) {
        NetworkManager().download24hDataForSensors(cityName: city)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { sensors in
                    self.sensorsData24h = sensors
            })
            .store(in: &cancellable)
    }
    
    func getCities() {
        #warning("TODO: Use zip or some other method to chain these")
        NetworkManager().downloadCities().sink(receiveCompletion: { _ in
            self.cities.forEach { city in
                NetworkManager().downloadOverallValuesForCity(cityName: city.cityName)
                    .sink(receiveCompletion: { _ in },
                          receiveValue: { values in
                            self.userSettings.cityValues.append(values)
                    })
                    .store(in: &self.cancellable)
            }
        }, receiveValue: { cities in
            self.cities = cities
        })
            .store(in: &cancellable)
    }
    
    func getCurrentMeasure(selectedMeasure: String) -> Measure {
        return measures.filter{ $0.id.lowercased() == selectedMeasure.lowercased()}.first ?? Measure.empty()
    }
}
