//
//  CityListView.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/17/20.
//

import SwiftUI
import MapKit
import Factory

struct FavouriteCitiesView: View {
    @Injected(\.appData) var appData: AppDataProtocol
    @EnvironmentObject var refreshService: RefreshService
    @State var searchText = ""
    @State var isSearching = false
    
    var body: some View {
        VStack(spacing: 0) {
            CitySearchContentView(viewModel: CitySearchContentViewModel(selectedMeasure: appData.selectedMeasureId,
                                                                        favouriteCities: UserSettings.favouriteCities,
                                                                        cityValues: UserSettings.cityValues,
                                                                        measureList: appData.measures),
                                  searchText: searchText)
            .searchable(text: $searchText, placement: .toolbarPrincipal, prompt: Trema.text(for: "search_city_or_country"))
                .listStyle(InsetGroupedListStyle())
        }
    }
}
