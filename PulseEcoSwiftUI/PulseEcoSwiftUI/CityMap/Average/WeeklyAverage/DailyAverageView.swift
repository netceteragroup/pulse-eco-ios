//
//  DailyView.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 2/10/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct DailyAverageView: View {
    
    var viewModel: DailyAverageViewModel 
    
    var body: some View {
        VStack{
            Text(viewModel.dayOfWeek)
            Rectangle()
                .frame(height: 4)
                .foregroundColor(viewModel.foregroundColor)
                .opacity(0.5)
            Text(viewModel.sensorValue)
                .bold()
                .foregroundColor(viewModel.foregroundColor)
        }
    }
}

