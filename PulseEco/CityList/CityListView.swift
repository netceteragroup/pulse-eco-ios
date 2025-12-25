//
//  NewCityListView.swift
//  PulseEco
//
//  Created by Darko Skerlevski on 23.9.21.
//
import SwiftUI
import Factory

struct CityListView: View {
    @EnvironmentObject var appData: AppData
    @ObservedObject var viewModel: CityListViewModel
    
    var searchText: String
    @Binding var citySelectorClicked: Bool
    
    var body: some View {
        if self.searchText.isEmpty {
            listAllCities
        } else {
            filteredCitiesList
        }
    }
    
    private var filteredCitiesList: some View {
        let foundCities = viewModel.getFilteredCities(searchText: searchText)
        return ScrollView {
            VStack {
                ForEach(viewModel.getFilteredCities(searchText: searchText), id: \.id) { city in
                    CityRowView(viewModel: city,
                                addCheckMark: viewModel.shouldAddCheckmark(city: city),
                                showCountryName: true)
                    .onTapGesture {
                        viewModel.addToFavorites(city: city)
                        citySelectorClicked = false
                    }
                    if city != foundCities.last {
                        Divider().background(AppColors.gray.color)
                    }
                }
                
                if foundCities.count > 0 {
                    Divider().background(AppColors.gray.color)
                }
                
                missingCityText()
            }
        }
    }
    
    private var listAllCities: some View {
        ScrollView {
            ForEach(self.viewModel.countries, id: \.self) { country in
                HStack {
                    Text("\(country)")
                        .padding()
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                .frame(height: 30)
                .background(Color(red: 240 / 255, green: 240 / 255, blue: 240 / 255))
                ForEach(viewModel.citiesFromCountry(country), id: \.id) { city in
                    CityRowView(viewModel: city,
                                addCheckMark: viewModel.shouldAddCheckmark(city: city),
                                showCountryName: false)
                    .onTapGesture {
                        viewModel.addToFavorites(city: city)
                        citySelectorClicked = false
                    }
                    if city != viewModel.citiesFromCountry(country).last {
                            Divider()
                                .background(AppColors.gray.color)
                        }
                    }
            }
            Divider().background(AppColors.gray.color)
            missingCityText()
        }
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
}

extension EdgeInsets {
    static let zero = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}
