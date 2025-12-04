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
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if viewModel.selectedSensorReadings.isEmpty && viewModel.chartSensorReadings.isEmpty {
            Text(Trema.text(for: "no_sensors_selected"))
                .multilineTextAlignment(.center)
        }
        else {
            Chart {
                ForEach(viewModel.selectedMeasure.bands, id: \.self) { band in
                    BarMark(x: .value("Time", viewModel.getMinDate(selectedDate: appState.selectedDate)),
                            yStart: .value("Value", band.from),
                            yEnd: .value("Value", band.to),
                            width: 8)
                        .foregroundStyle(Color(band.legendColor))
                    
                    RuleMark(y: .value(band.grade, max(0, band.from - 1)))
                        .foregroundStyle(Color(band.legendColor))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                }
                
                if !viewModel.selectedSensorReadings.isEmpty {
                    ForEach(viewModel.selectedSensorReadings, id: \.self) { reading in
                        LineMark(x: .value("Time",
                                           reading.stamp),
                                 y: .value("Value",
                                           reading.value))
                    }
                }
                else {
                    ForEach(Array(viewModel.chartSensorReadings.enumerated()), id:\.offset) { index, sensor in
                        ForEach(sensor) { reading in
                            LineMark(x: .value("Time",
                                               reading.stamp),
                                     y: .value("Value",
                                               reading.value))
                            .foregroundStyle(by: .value("Sensor", reading.title))
                        }
                    }
                }
                
            }
            .chartYScale(domain: viewModel.selectedMeasure.showMin...viewModel.selectedMeasure.showMax)
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisValueLabel()
                        .offset(CGSize(width: -5, height: 0))
                }
            }
            .chartXAxis {
                AxisMarks(values: viewModel.getLast24HForGraph(selectedDate: appState.selectedDate)) { value in
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
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .chartLegend(alignment: .center)
        }
    }
}
