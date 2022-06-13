//
//  WeeklyView.swift
//  PulseEco
//
//  Created by Maja Mitreska on 2/10/21.
//

import SwiftUI

struct WeeklyAverageView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    var viewModel: WeeklyAverageViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.title)
                .bold()
                .frame(height: 17, alignment: .center)
               
                .padding(.bottom, 20)
            HStack {
                ForEach(0..<viewModel.dailyAverageViewModels.count) { index in
                    DailyAverageView(viewModel: viewModel.dailyAverageViewModels[index])
                }
            }
        }
        .frame(minWidth: 310, idealWidth: 327, maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}
