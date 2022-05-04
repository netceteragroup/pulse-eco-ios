//
//  MeasuresScrollView.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/16/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct MeasureListView: View {
    @ObservedObject var viewModel: MeasureListViewModel
    @EnvironmentObject var appDataSource: AppDataSource
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollProxy in
                VStack {
                    buttonStack
                        .onReceive(appDataSource.$loadingMeasures) { value in
                            if !value {
                                scrollProxy.scrollTo(appState.selectedMeasureId)
                            }
                        }
                }
                .frame(height: 40)
            }
        }
        .frame(height: 34)
    }
    var buttonStack: some View {
        HStack {
            ForEach(viewModel.measures, id: \.id) { item in
                MeasureButtonView(viewModel: item)
                    .id(item.id)
            }
        }
    }
}
