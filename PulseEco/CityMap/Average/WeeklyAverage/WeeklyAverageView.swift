//
//  WeeklyView.swift
//  PulseEco
//
//  Created by Maja Mitreska on 2/10/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct WeeklyAverageView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    var viewModel: WeeklyAverageViewModel
    
    var body: some View {
        VStack{
            Text(viewModel.title)
                .bold()
                .frame(height: 17, alignment: .center)
               
                .padding(.bottom, 20)
            HStack{
                ForEach(0..<viewModel.dailyAverageViewModels.count) { i in
                    DailyAverageView(viewModel: viewModel.dailyAverageViewModels[i])
                }
            }
        }
        .frame(minWidth: 310, idealWidth: 327, maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}


