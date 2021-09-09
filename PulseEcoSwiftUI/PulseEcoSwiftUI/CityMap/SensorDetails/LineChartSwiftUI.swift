//
//  LineChartSwiftUI.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 6.4.21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI
import Charts

struct LineChartSwiftUI: UIViewRepresentable {
    @State var lineChart = LineChartView()
    @ObservedObject var viewModel: ChartViewModel
    func makeUIView(context: UIViewRepresentableContext<LineChartSwiftUI>) -> LineChartView {
        setUpChart()
        return lineChart
    }
    
    func updateUIView(_ uiView: LineChartView, context: UIViewRepresentableContext<LineChartSwiftUI>) {
        setUpChart()
    }
    
    func setUpChart() {
        lineChart.noDataText = Trema.text(for: "no_data_availabe")
        var dataSets = [ChartDataSet]()
        let colors = [AppColors.purple, AppColors.blue, AppColors.darkred, AppColors.darkgreen, AppColors.red]
        var iterator = colors.makeIterator()
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in self.viewModel.sensorReadings {
            var dataEntry = ChartDataEntry()
            let date = DateFormatter.iso8601Full.date(from: i.stamp) ?? Date()
            let valuedate = date.timeIntervalSince1970
            let x =  valuedate
            let y = Double(i.value)!
            dataEntry = ChartDataEntry(x: x, y: y)
            dataEntries.append(dataEntry)
        }
        let sensorName = self.viewModel.sensor.title ?? Trema.text(for: "unknown")
        let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: sensorName)
        
        lineChartDataSet.setColor(iterator.next()!)
        
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.lineWidth = 2.0
        lineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        lineChartDataSet.drawVerticalHighlightIndicatorEnabled = false
        
        dataSets.append(lineChartDataSet)
        
        let data = LineChartData(dataSets: dataSets)
        data.setValueFont(.systemFont(ofSize: 7, weight: .light))
        lineChart.data = data
        
        let lineChartData = LineChartData(dataSets: dataSets)
        lineChart.data = lineChartData
        lineChart.xAxis.labelPosition = .bottom
        lineChart.legend.textColor = .black
        lineChart.xAxis.labelTextColor = .black
        lineChart.leftAxis.labelTextColor = .black
        lineChart.rightAxis.drawAxisLineEnabled = false
        lineChart.rightAxis.labelTextColor = .black
        lineChart.leftAxis.axisMinimum = 0
        lineChart.rightAxis.axisMinimum = 0
        lineChart.xAxis.granularityEnabled = true
        lineChart.xAxis.drawLabelsEnabled = true
        lineChart.xAxis.valueFormatter = ChartsDateValueFormatter()
        lineChart.xAxis.granularity = 1.0
        lineChart.doubleTapToZoomEnabled = false
        lineChart.pinchZoomEnabled = false
        lineChart.scaleXEnabled = false
        lineChart.scaleYEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.rightAxis.drawGridLinesEnabled = false
        lineChart.xAxis.drawGridLinesEnabled = false
        
        lineChart.leftAxis.removeAllLimitLines()
        let limitLines = LimitLines.getLimitLines(for: self.viewModel.selectedMeasure)
        for limitLine in limitLines {
            lineChart.leftAxis.addLimitLine(limitLine)
        }
        lineChart.leftAxis.drawLimitLinesBehindDataEnabled = true
        
        lineChart.zoomOut()
    }
}

class LimitLines {
    
    static func getLimitLines(for measure: Measure) -> [ChartLimitLine] {
        var limitLines: [ChartLimitLine] = []
        
        for band in measure.bands {
            let limitLine = ChartLimitLine(limit: Double(band.legendPoint), label: band.shortGrade)
            limitLine.lineColor = AppColors.colorFrom(string: band.legendColor)
            limitLines.append(limitLine)
        }
        
        for limitLine in limitLines {
            limitLine.lineWidth = 1
            limitLine.lineDashLengths = [5, 5]
            limitLine.labelPosition = .rightBottom
            limitLine.valueFont = .systemFont(ofSize: 8)
        }
        return limitLines
    }
    
}
