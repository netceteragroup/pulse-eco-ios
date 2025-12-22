//
//  WeeklyView.swift
//  PulseEco
//
//  Created by Maja Mitreska on 2/10/21.
//

import SwiftUI

struct WeeklyAverageView: View {
    var viewModel: WeeklyAverageViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.title)
                .bold()
                .frame(height: 17, alignment: .center)
               
                .padding(.bottom, 20)
            HStack {
                ForEach(0..<viewModel.dailyAverageViewModels.count, id: \.self) { index in
                    DailyAverageView(viewModel: viewModel.dailyAverageViewModels[index])
                }
            }
        }
//        .frame(minWidth: 310, idealWidth: 327, maxWidth: .infinity)
//        .frame(width: UIScreen.main.bounds.width - 10)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}
