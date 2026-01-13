//
//  MeasuresScrollView.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/16/20.
//

import SwiftUI

struct MeasureListView: View {
    @ObservedObject var viewModel: MeasureListViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollProxy in
                HStack {
                    ForEach(viewModel.measures, id: \.id) { item in
                        MeasureButtonView(viewModel: item)
                            .id(item.id)
                    }
                }
            }
        }
        .frame(height: 34)
    }
}
