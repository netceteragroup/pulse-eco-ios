//
//  MeasuresScrollView.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/16/20.
//

import SwiftUI
import Factory

struct MeasureListView: View {
    @ObservedObject var viewModel: MeasureListViewModel
    @Injected(\.appData) private var appData: AppDataProtocol

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollProxy in
                VStack {
                    buttonStack
                        .onReceive(appData.loadingMeasuresPublisher) { value in
                            if !value {
                                scrollProxy.scrollTo(appData.selectedMeasureId)
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
