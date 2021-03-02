//
//  SenDetView.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 2/24/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct SenDetView: View {
    @State var offset = UIHeight / 3
    @EnvironmentObject var appVM: AppVM
    @EnvironmentObject var dataSource: DataSource
    @ObservedObject var viewModel: ExpandedVM
    
    var body: some View {
        VStack {
            CollapsedView(viewModel:
                SensorDetailsVM(sensor: self.appVM.selectedSensor ?? SensorVM(), sensorsData: self.dataSource.sensorsData24h, selectedMeasure: self.dataSource.getCurrentMeasure(selectedMeasure: self.appVM.selectedMeasure)
                )
            ).padding(.top, 10)
            
            ExpandedView(viewModel: self.viewModel)
            
            Spacer()
        }
    }
    
}
