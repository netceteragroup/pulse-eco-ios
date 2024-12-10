//
//  CityListView.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/17/20.
//

import SwiftUI
import MapKit

struct FavouriteCitiesView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var refreshService: RefreshService
    @ObservedObject var userSettings: UserSettings
    @State var searchText = ""
    @State var isSearching = false
    let proxy: GeometryProxy
    
    var body: some View {
        VStack(spacing: 0) {
            CitySearchContentView(userSettings: userSettings,
                                  viewModel: CitySearchContentViewModel(selectedMeasure: appState.selectedMeasureId,
                                                                        favouriteCities: userSettings.favouriteCities,
                                                                        cityValues: self.appState.userSettings.cityValues,
                                                                        measureList: self.dataSource.measures),
                                  searchText: searchText)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Trema.text(for: "search_city_or_country"))
                .listStyle(InsetGroupedListStyle())
                .overlay(ShadowOnBottomOfView())
        }
    }
}
