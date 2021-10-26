//
//  LineChartSwiftUI.swift
//  PulseEco
//
//  Created by Maja Mitreska on 6.4.21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI
import Charts

struct LineChartSwiftUI: UIViewRepresentable {
    @State var lineChart = CombinedChartView()
    @ObservedObject var viewModel: ChartViewModel
    
    func makeUIView(context: UIViewRepresentableContext<LineChartSwiftUI>) -> CombinedChartView {
        setUpChart()
        return lineChart
    }
    
    func updateUIView(_ uiView: CombinedChartView, context: UIViewRepresentableContext<LineChartSwiftUI>) {
        setUpChart()
    }
    
    func setUpChart() {
        lineChart.noDataText = Trema.text(for: "no_data_availabe")
        let sensorName = self.viewModel.sensor.title ?? Trema.text(for: "unknown")
        
        let colors = [AppColors.purple, AppColors.blue, AppColors.darkred, AppColors.darkgreen, AppColors.red]
        var iterator = colors.makeIterator()
        
        let lineDataEntries = lineChartDataEntries(from: viewModel.sensorReadings)
        let lineChartDataSet = LineChartDataSet(entries: lineDataEntries, label: sensorName)
        lineChartDataSet.setColor(iterator.next()!)
        lineChartDataSet.mode = .linear
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.lineWidth = 2
        lineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        lineChartDataSet.drawVerticalHighlightIndicatorEnabled = false
        
        guard lineDataEntries.count > 0 else { return }
        
        let startDate = lineDataEntries.map { $0.x }.min()!
        let minY = lineDataEntries.map { $0.y }.min()!
        let maxY = lineDataEntries.map { $0.y }.max()!
        
        let barDataSets = barDataSets(for: viewModel.selectedMeasure,
                                         maxY: maxY,
                                         minY: minY, startDate: startDate)
        
        let combinedData = CombinedChartData(dataSets: [lineChartDataSet] + barDataSets )
        combinedData.lineData = LineChartData(dataSet: lineChartDataSet)
        combinedData.barData = BarChartData(dataSets: barDataSets)
        
        lineChart.data = combinedData
        
        lineChart.legend.enabled = false
        lineChart.rightAxis.enabled = false
        
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.labelTextColor = .black
        lineChart.xAxis.granularityEnabled = true
        lineChart.xAxis.drawLabelsEnabled = true
        lineChart.xAxis.drawAxisLineEnabled = false
        lineChart.xAxis.valueFormatter = ChartsDateValueFormatter()
        lineChart.xAxis.granularity = 1.0
        lineChart.xAxis.drawGridLinesEnabled = false
        
        lineChart.leftAxis.labelTextColor = .black
        lineChart.leftAxis.axisMinimum = min(minY, Double(viewModel.selectedMeasure.showMin))
        lineChart.leftAxis.axisMaximum = max(maxY, Double(viewModel.selectedMeasure.showMax))
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.removeAllLimitLines()
        
        lineChart.doubleTapToZoomEnabled = false
        lineChart.pinchZoomEnabled = false
        lineChart.scaleXEnabled = false
        lineChart.scaleYEnabled = false
        
        let limitLines = getLimitLines(for: self.viewModel.selectedMeasure)
        for limitLine in limitLines {
            lineChart.leftAxis.addLimitLine(limitLine)
        }
        lineChart.leftAxis.drawLimitLinesBehindDataEnabled = true
    }
    
    private func lineChartDataEntries(from sensorReadings: [SensorData]) -> [ChartDataEntry] {
        sensorReadings.map {
            let date = DateFormatter.iso8601Full.date(from: $0.stamp) ?? Date()
            let pointX =  date.timeIntervalSince1970
            let pointY = Double($0.value)!
            return ChartDataEntry(x: pointX, y: pointY)
        }
    }
    
    private func barDataSets(for measure: Measure,
                             maxY: Double,
                             minY: Double,
                             startDate: Double) -> [BarChartDataSet] {
        var sets = [BarChartDataSet]()
        let negativeBands = measure.bands
            .filter { $0.from < 0 }
            .sorted { $0.from < $1.from }
        let positiveBands = measure.bands
            .filter { $0.to > 0 }
            .sorted { $0.to > $1.to }
        
        sets.append(contentsOf: positiveBands.map {
            let barDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: startDate, y: Double($0.to))])
            barDataSet.barBorderColor = AppColors.colorFrom(string: $0.legendColor)
            return barDataSet
        })
        sets.append(contentsOf: negativeBands.map {
            let barDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: startDate, y: Double($0.from))])
            barDataSet.barBorderColor = AppColors.colorFrom(string: $0.legendColor)
            return barDataSet
        })

        return sets.map {
            $0.barBorderWidth = 5
            $0.label = nil
            $0.drawValuesEnabled = false
            return $0
        }
    }

   private func getLimitLines(for measure: Measure) -> [ChartLimitLine] {
        measure.bands.compactMap {
            var limitLine: ChartLimitLine?
            if $0.from < 0 && $0.to > 0 {
                limitLine = ChartLimitLine(limit: Double(0))
            } else if $0.legendPoint < 0 {
                limitLine = ChartLimitLine(limit: Double($0.to))
            } else {
                limitLine = ChartLimitLine(limit: Double($0.from))
            }
            limitLine?.lineDashLengths = [2, 4]
            limitLine?.lineColor = AppColors.colorFrom(string: $0.legendColor)
            limitLine?.lineWidth = 1
            return limitLine
        }
    }
}
