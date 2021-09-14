//
//  SensorDView.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 1/25/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct SensorDetailsView: View {
    
    @EnvironmentObject var appVM: AppVM
    @EnvironmentObject var dataSource: DataSource
    @ObservedObject var viewModel: SensorDetailsViewModel
    @State var isExpanded: Bool = false
    var body: some View {
        VStack {
            // Handler
            RoundedRectangle(cornerRadius: CGFloat(5.0) / 2.0)
                .frame(width: 40, height: 3.0)
                .foregroundColor(Color(UIColor.systemGray2))
                .padding([.top, .bottom], 10)
            // Collapsed View
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 1) {
                        HStack {
                            Image(uiImage: self.viewModel.image)//.animation(.none)
                            Text("\(self.viewModel.title)").foregroundColor(Color.gray)
                                .font(.system(size: 13))//.animation(.none)
                        }
                        HStack {
                            Text(self.viewModel.value).font(.system(size: 40))
                            Text(self.viewModel.unit).padding(.top, 10)
                            Spacer()
                            VStack (alignment: .trailing) {
                                Text("\(self.viewModel.time)")
                                Text("\(self.viewModel.date)").foregroundColor(Color.gray)
                            }
                        }
                    }
                }.padding([.horizontal], 20)
            }
            // Expanded View
            VStack {
                LineChartSwiftUI(viewModel:
                    ChartViewModel(sensor: self.appVM.selectedSensor ?? SensorVM(), sensorsData: self.dataSource.sensorsData24h, selectedMeasure: self.dataSource.getCurrentMeasure(selectedMeasure: self.appVM.selectedMeasure)
                    )
                ).frame(width: 350, height: 200 )
                
                WeeklyAverageView(viewModel: WeeklyAverageViewModel(appVM: appVM,
                                                                    dataSource: dataSource,
                                                                    averages: self.viewModel.dailyAverages))
                    .padding(.bottom, 20)
                
                Text(self.viewModel.disclaimerMessage)
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(self.viewModel.color)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .padding([.horizontal, .bottom], 15).fixedSize(horizontal: false, vertical: true)
                
//                HStack {
//                    Text(Trema.text(for: "details"))
//                        .font(.system(size: 13, weight: .medium))
//                    Text("|")
//                        .font(.system(size: 13, weight: .medium))
//                    Text(Trema.text(for: "privacy_policy"))
//                        .font(.system(size: 13, weight: .medium))
//                }.foregroundColor(self.viewModel.color)
//                    .padding(.bottom, 15)
            }.scaledToFit()
            Spacer()
        }
    }
}



