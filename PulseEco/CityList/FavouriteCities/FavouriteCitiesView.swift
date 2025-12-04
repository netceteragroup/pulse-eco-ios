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
    @State var searchText = ""
    @State var isSearching = false
    
    var body: some View {
        VStack(spacing: 0) {
            CitySearchContentView(viewModel: CitySearchContentViewModel(selectedMeasure: appState.selectedMeasureId,
                                                                        favouriteCities: UserSettings.favouriteCities,
                                                                        cityValues: UserSettings.cityValues,
                                                                        measureList: self.dataSource.measures),
                                  searchText: searchText)
            .searchable(text: $searchText, placement: .toolbarPrincipal, prompt: Trema.text(for: "search_city_or_country"))
                .listStyle(InsetGroupedListStyle())
        }
    }
}
