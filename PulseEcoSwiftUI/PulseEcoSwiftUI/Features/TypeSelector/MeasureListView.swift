//
//  MeasuresScrollView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/16/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct MeasureListView: View {
    @ObservedObject var viewModel: MeasureListVM
    
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.measures, id: \.id) { item in
                    VStack {
                        MeasureButtonView(viewModel: item)
                    }
                }
            }
        }//.minimumScaleFactor(0.90)
            .background(self.viewModel.backgroundColor)
            .shadow(color: self.viewModel.shadow, radius: 0.8, x: 0, y: 0)
    }
}

