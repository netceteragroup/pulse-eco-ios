//
//  WeeklyView.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 2/10/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct WeeklyAverageView: View {
    @EnvironmentObject var appVM: AppVM
    @EnvironmentObject var dataSource: DataSource
    var viewModel: WeeklyAverageViewModel
    
    var body: some View {
        VStack{
            Text(viewModel.title)
                .bold()
                .frame(width: 327, height: 17, alignment: .center)
                .padding(.bottom, 20)
            HStack{
                ForEach(viewModel.dailyAverageViewModels, id: \.id) { sensor in
                    DailyAverageView(viewModel: sensor)
                }
            }
        }.padding(.horizontal, 20)
    }
}


