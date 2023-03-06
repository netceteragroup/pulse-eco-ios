//
//  PastDays.swift
//  PulseEco
//
//  Created by Veselinka Lokvenec on 6.3.23.
//

import SwiftUI

struct PastDaysView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    var viewModel: PastDaysViewModel
    
    var body: some View {
        VStack {
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
