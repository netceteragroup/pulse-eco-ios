
import SwiftUI

struct CityListView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataSource: DataSource
    @ObservedObject var viewModel: CityListVM
    @ObservedObject var userSettings: UserSettings
    var body: some View {
        VStack {
            VStack(spacing: 5) {
                Text(Trema.text(for: "search_city_or_choose_suggested", language: UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"))
                    .foregroundColor(Color.white).multilineTextAlignment(.center)
                SearchBar(text: self.$viewModel.searchText,
                          placeholder: Trema.text(for: "search_city_or_country", language: UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"))
                    .padding(.horizontal, 10)
                Text(self.viewModel.text).font(.headline).foregroundColor(Color.white)
            }.padding(.top, 10)
            ScrollView {
                if self.viewModel.searchText.isEmpty {
                    ForEach(self.viewModel.getCountries(), id: \.self) { elem in
                        Section(header: HStack {
                            Text("\(elem)")
                                .foregroundColor(.white)
                                .padding()
                            Spacer()
                        }.frame(height: 30)
                            .background(Color(AppColors.lightPurple))
                            .listRowInsets(EdgeInsets(
                                top: 0,
                                leading: 0,
                                bottom: 0,
                                trailing: 0))
                        ) {
                            ForEach(self.viewModel.getCities().filter {
                                elem == $0.countryName
                            }, id: \.id) { city in
                                CityRowView(viewModel: city).onTapGesture {
                                    if let city = self.viewModel.cityModel.first(where: { $0.cityName == city.cityName }) {
                                        self.userSettings.favouriteCities.insert(city)
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }
                    }
                } else {
                    self.listCities
                }
            }
        }.background(Color(AppColors.darkblue))
            .edgesIgnoringSafeArea(.all)
    }
    
    var listCities: some View {
        
        return ForEach(self.viewModel.getCities().filter{ $0.cityName.lowercased().contains(self.viewModel.searchText.lowercased()) || $0.countryName.lowercased().contains(self.viewModel.searchText.lowercased())
        }, id: \.id) { city in
            CityRowView(viewModel: city).onTapGesture {
                if let city = self.viewModel.cityModel.first(where: { $0.cityName == city.cityName }) {
                    self.userSettings.favouriteCities.insert(city)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
