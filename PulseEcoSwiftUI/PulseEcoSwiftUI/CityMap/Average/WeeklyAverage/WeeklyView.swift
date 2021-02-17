//
//  WeeklyView.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 2/10/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct WeeklyView: View {
    @EnvironmentObject var appVM: AppVM
    @EnvironmentObject var dataSource: DataSource
    
    var viewModel: WeeklyVM
    var body: some View {
        VStack{
            Text(viewModel.title)
                .bold()
                .frame(width: 327, height: 17, alignment: .center)
                .padding(.bottom, 20)
            HStack{
                ForEach(viewModel.dailyAverageSensorValues, id: \.id) { sensor in
                    VStack {
                        DailyView(viewModel: DailyVM(sensor: sensor, appVM: self.appVM, dataSource: self.dataSource))
                    }
                }
            }
        }.padding(.horizontal, 20)
    }
}

