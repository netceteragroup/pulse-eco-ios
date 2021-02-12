//
//  SensorDView.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 1/25/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct SensorDView: View {
    
    @EnvironmentObject var appVM: AppVM
    @EnvironmentObject var dataSource: DataSource
    @ObservedObject var viewModel: ExpandedVM
    @State var isExpanded: Bool = false
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                CollapsedView(viewModel:
                    SensorDetailsVM(sensor: self.appVM.selectedSensor ?? SensorVM(), sensorsData: self.dataSource.sensorsData24h, selectedMeasure: self.dataSource.getCurrentMeasure(selectedMeasure: self.appVM.selectedMeasure)
                    )
                ) .padding(.top, 5)
                    //.padding(.bottom, 10)
            }
            
            //if isExpanded {
            VStack {
                LineChartSwiftUI(viewModel:
                    ChartVM(sensor: self.appVM.selectedSensor ?? SensorVM(), sensorsData: self.dataSource.sensorsData24h, selectedMeasure: self.dataSource.getCurrentMeasure(selectedMeasure: self.appVM.selectedMeasure)
                    )
                ).frame(width: 350, height: 200 )
                
                 WeeklyView(viewModel: WeeklyVM(appVM: appVM, dataSource: dataSource))
                    .padding(.bottom, 20)
                
                Text(self.viewModel.disclaimerMessage)
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(self.viewModel.color)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20).fixedSize(horizontal: false, vertical: true)
                Spacer()
                
                HStack {
                    Text("Details")
                        .font(.system(size: 13, weight: .medium))
                    Text("|")
                        .font(.system(size: 13, weight: .medium))
                    Text("Privacy Policy")
                        .font(.system(size: 13, weight: .medium))
                }.foregroundColor(self.viewModel.color)
            }.scaledToFit()
                .padding(.bottom, 30)
            //Spacer()
            //}
        }
        
    }
}



