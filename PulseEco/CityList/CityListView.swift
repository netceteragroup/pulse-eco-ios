//
//  NewCityListView.swift
//  PulseEco
//
//  Created by Darko Skerlevski on 23.9.21.
//
import SwiftUI
import Factory

struct CityListView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var appDataManager: AppDataManager
    @EnvironmentObject var refreshService: RefreshService
    @ObservedObject var viewModel: CityListViewModel
    
    @Injected(\.locationService) private var locationService
    
    var searchText: String
    
    var body: some View {
        if self.searchText.isEmpty {
            listAllCities()
        } else {
            filteredCitiesList()
        }
    }
    
    @ViewBuilder
    private func filteredCitiesList() -> some View {
        let favouriteCitiesNames = getFavouriteCitiesNames()
        let foundCities = viewModel.getCities().filter {
            $0.cityName.lowercased().contains(self.searchText.lowercased()) ||
            $0.countryName.lowercased().contains(self.searchText.lowercased())
        }
        
        ScrollView {
            VStack {
                ForEach(foundCities, id: \.id) { city in
                    Button(action: {
                        addToFavourites(city: city)
                    }, label: {
                        CityRowView(viewModel: city,
                                    addCheckMark: favouriteCitiesNames.contains(city.cityName),
                                    showCountryName: true)
                    })
                    
                    if city != foundCities.last {
                        Divider().background(AppColors.gray.color)
                    }
                }
                
                if foundCities.count > 0 {
                    Divider().background(AppColors.gray.color)
                }
                
                missingCityText()
            }
            .resignKeyboardOnDragGesture()
        }
    }
    
    @ViewBuilder
    private func listAllCities() -> some View {
        ScrollView {
            ForEach(self.viewModel.getCountries(), id: \.self) { elem in
                Section(header:
                            HStack {
                    Text("\(elem)")
                        .padding()
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                    .frame(height: 30)
                    .background(Color(red: 240 / 255, green: 240 / 255, blue: 240 / 255))
                    .listRowInsets(.zero)) {
                        let citiesFromCountry = self.viewModel.getCities().filter {
                            elem == $0.countryName
                        }
                        ForEach(citiesFromCountry, id: \.id) { city in
                            Button(action: {
                                addToFavourites(city: city)
                            }, label: {
                                CityRowView(viewModel: city,
                                            addCheckMark: getFavouriteCitiesNames().contains(city.cityName),
                                            showCountryName: false)
                            })
                            if city != citiesFromCountry.last {
                                Divider()
                                    .background(AppColors.gray.color)
                            }
                        }
                    }
            }
            Divider().background(AppColors.gray.color)
            
            missingCityText()
        }
        .resignKeyboardOnDragGesture()
    }
    
    @ViewBuilder
    private func missingCityText() -> some View {
        VStack {
            Text(Trema.text(for: "city_missing_add_new"))
                .font(.system(size: 14))
                .foregroundColor(Color(AppColors.gray))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: {
                guard let url = URL(string: "https://pulse.eco/addcity") else { return }
                UIApplication.shared.open(url)
            }) {
                Text("https://pulse.eco/addcity")
                    .font(.system(size: 14))
            }
        }
        .padding(.all)
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
    
    private func addToFavourites(city: CityRowViewModel) {
        if let city = self.viewModel.cityModel.first(where: { $0.cityName == city.cityName }) {
            if locationService.lastLocation?.cityName != city.cityName {
                UserSettings.addFavoriteCity(city)
            }
            self.appData.citySelectorClicked = false
            if UserSettings.selectedCity != city {
                UserSettings.selectedCity = city
            }
            self.presentationMode.wrappedValue.dismiss()
            appDataManager.fetchData(cityName: city.cityName, sensorType: appData.selectedMeasureId, selectedDate: appData.selectedDate)
            dismissSearch()
        }
    }
    
    private func getFavouriteCitiesNames() -> Set<String> {
        var favouriteCitiesNames = Set(UserSettings.favouriteCities.map { $0.cityName })
        if let currentCity = locationService.lastLocation {
            favouriteCitiesNames.insert(currentCity.cityName)
        }
        return favouriteCitiesNames
    }
}

extension EdgeInsets {
    static let zero = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}
