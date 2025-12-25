//
//  FavoriteCitiesView.swift
//  PulseEco
//
//  Created by Ljuben Angelkoski on 24.12.25.
//

import SwiftUI

struct FavoriteCitiesView: View {
    @ObservedObject var viewModel: FavoriteCitiesViewModel
    @Binding var citySelectorClicked: Bool
    @State private var addNewCityClicked: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            favoriteCitiesList
            Divider()
            addNewCityButton
        }
        .sheet(isPresented: $addNewCityClicked) {
            NavigationStack {
                CitySearchContentView(citySelectorClicked: $citySelectorClicked,
                                      addNewCityClicked: $addNewCityClicked)
            }
        }
    }
    
    private var addNewCityButton: some View {
        Button(action: {
            addNewCityClicked = true
        }) {
            VStack {
                Image(systemName: "plus.circle")
                Text(Trema.text(for: "add_city_button"))
            }
            .padding()
            .foregroundStyle(AppColors.black.color)
        }
    }
    
    private var favoriteCitiesList: some View {
        List {
            if let first = viewModel.cityList.first {
                ForEach([first], id: \.id) {
                    cityRow(favoriteCity: $0)
                }
                Section(header: EmptyView()) {
                    ForEach(Array(viewModel.cityList.dropFirst()), id: \.id) { city in
                        cityRow(favoriteCity: city)
                    }
                    .onDelete(perform: self.delete)
                }
            }
        }
        .padding(.vertical, 1)
    }
    
    private func cityRow(favoriteCity: FavoriteCityRowViewModel) -> some View {
        VStack(spacing: 0) {
            Button(action: {
                citySelectorClicked = false
                viewModel.onCityRowTap(favoriteCity: favoriteCity)
            }, label: {
                FavoriteCityRowView(viewModel: favoriteCity)
                    .contentShape(Rectangle())
            }).padding()
        }
    }
    
    private func delete(at offsets: IndexSet) {
        offsets.forEach {
            let delRow = viewModel.cityList[$0 + 1]
            if let city = UserSettings.favoriteCities.first(where: { $0.cityName == delRow.cityName }) {
                UserSettings.removeFavoriteCity(city)
            }
        }
    }
}
