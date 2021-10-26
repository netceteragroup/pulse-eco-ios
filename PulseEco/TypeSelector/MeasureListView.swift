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
        ScrollView (.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollProxy in
                VStack {
                    buttonStack
                        .frame(height: 40)
                        .onReceive(appDataSource.$loadingMeasures) { value in
                            if !value {
                                scrollProxy.scrollTo(appState.selectedMeasure)
                            }
                        }
                    Spacer()
                }
                .frame(height: 56)
            }
        }
    }
    
    var buttonStack: some View {
        HStack {
            ForEach(viewModel.measures, id: \.id) { item in
                VStack {
                    MeasureButtonView(viewModel: item)
                }
                .id(item.id)
            }
        }
        
    }
}

