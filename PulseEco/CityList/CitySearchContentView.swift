//
//  CitySearchContentView.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 5.12.24.
//

import SwiftUI
import Factory

struct CitySearchContentView: View {
    @EnvironmentObject var appData: AppData
    
    @Binding var citySelectorClicked: Bool
    @Binding var addNewCityClicked: Bool
    @State private var searchText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            searchTextField
            contentView
        }
    }
    
    private var contentView: some View {
        CityListView(viewModel: CityListViewModel(cities: appData.cities),
                     searchText: searchText,
                     citySelectorClicked: $citySelectorClicked)
    }
    
    private var searchTextField: some View {
        HStack {
            ZStack {
                Capsule()
                    .fill(AppColors.gray2.color)
                    .frame(height: 48)
                if searchText.isEmpty {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text(Trema.text(for: "search_city_or_country"))
                        Spacer()
                    }
                    .foregroundStyle(AppColors.black.color)
                    .padding(.leading, 16)
                }
                TextField("", text: $searchText)
                    .frame(maxWidth: .infinity)
                    .padding(.leading, 16)
            }
            if !searchText.isEmpty {
                Image(systemName: "xmark")
                    .onTapGesture {
                        addNewCityClicked = false
                    }
            }
        }
        .padding(16)
    }
}

#Preview {
    CitySearchContentView(citySelectorClicked: .constant(false),
                          addNewCityClicked: .constant(false))
}
