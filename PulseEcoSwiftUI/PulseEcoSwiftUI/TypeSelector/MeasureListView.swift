//
//  MeasuresScrollView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/16/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct MeasureListView: View {
    @ObservedObject var viewModel: MeasureListViewModel
    
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            VStack {
                buttonStack
                .frame(height: 40)
                Spacer()
            }
            .frame(height: 56)
        }
    }
    
    var buttonStack: some View {
        HStack {
            ForEach(viewModel.measures, id: \.id) { item in
                VStack {
                    MeasureButtonView(viewModel: item)
                }
            }
        }

    }
}

