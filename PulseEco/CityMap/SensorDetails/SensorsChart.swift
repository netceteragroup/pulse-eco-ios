//
//  SensorsChart.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 4.2.25.
//

import SwiftUI
import Charts


struct SensorsChart: View {
    @ObservedObject var viewModel: ChartViewModel
    
    var body: some View {
        Chart {
            ForEach(viewModel.selectedMeasure.bands, id: \.self) { band in
                RuleMark(y: .value(band.grade, max(0, band.from - 1)))
                    .foregroundStyle(Color(band.legendColor))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                
                BarMark(x: .value("Time", viewModel.sensorReadings.first?.stamp ?? Date()),
                        y: .value(band.grade, band.to - band.from))
                    .foregroundStyle(Color(band.legendColor))
                
            }
            
            ForEach(viewModel.sensorReadings) { reading in
                LineMark(x: .value("Time",
                                   reading.stamp),
                         y: .value("Value",
                                   reading.value))
            }
        }
        .chartYScale(domain: viewModel.minValue()...viewModel.maxValue())
        .padding(20)
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisValueLabel()
                    .offset(CGSize(width: -10, height: 0))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 4)) { value in
                if let date = value.as(Date.self) {
                    let hour = Calendar.current.component(.hour, from: date)
                    AxisValueLabel {
                        VStack(alignment: .leading) {
                            switch hour {
                            case 0:
                                Text(date, format: .dateTime.month().day())
                            default:
                                Text(viewModel.formatTime(for: hour))
                            }
                        }
                    }
                    
                    if hour == 0 {
                        AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                    } else {
                        AxisTick()
                    }
                }
            }
        }
    }
}
