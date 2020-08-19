import SwiftUI
import Charts
import Foundation

struct SDView: View {
    @State var offset = UIHeight / 3
    @EnvironmentObject var appVM: AppVM
    @EnvironmentObject var dataSource: DataSource
    @ObservedObject var viewModel: ExpandedVM
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 20) {
                CollapsedView(viewModel:
                    SensorDetailsVM(sensor: self.appVM.selectedSensor ?? SensorVM(), sensorsData: self.dataSource.sensorsData24h, selectedMeasure: self.dataSource.getCurrentMeasure(selectedMeasure: self.appVM.selectedMeasure)
                    )
                ).padding(.top, 5)
                VStack {
                    LineChartSwiftUI(viewModel:
                        ChartVM(sensor: self.appVM.selectedSensor ?? SensorVM(), sensorsData: self.dataSource.sensorsData24h, selectedMeasure: self.dataSource.getCurrentMeasure(selectedMeasure: self.appVM.selectedMeasure)
                        )
                    ).frame(width: 350,height: 200)
                    Text(self.viewModel.disclaimerMessage)
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(self.viewModel.color)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20).fixedSize(horizontal: false, vertical: true)
                    HStack {
                        Text("Details")
                            .font(.system(size: 13, weight: .medium))
                        Text("|")
                            .font(.system(size: 13, weight: .medium))
                        Text("Privacy Policy")
                            .font(.system(size: 13, weight: .medium))
                    }.foregroundColor(self.viewModel.color)
                }.scaledToFit()
                Spacer()
            }.frame(width: geo.size.width, height: geo.size.height * 0.7)
                .background(RoundedCorners(tl: 40, tr: 40, bl: 0, br: 0).fill(Color.white))
                .offset(y: self.offset + geo.size.height / 2)
                .transition(.scale)
                .animation(.linear)
                .gesture(
                    DragGesture()
                        .onChanged {
                            value in
                            if value.translation.height < 0 {
                                if (self.offset > 0 )
                                {
                                    if (self.offset + value.translation.height) > 0 {
                                        self.offset += value.translation.height
                                    }
                                    else {
                                        self.offset += value.translation.height  - (self.offset + value.translation.height)
                                    }
                                }
                            } else {
                                if (self.offset < geo.size.height/3 )
                                {
                                    if (value.translation.height + self.offset) < geo.size.height/3 {
                                        self.offset += value.translation.height
                                    }
                                }
                            }
                    }
                    .onEnded { value in
                        if value.translation.height < 0 {
                            self.offset = CGSize.zero.height - geo.size.height/7
                        } else {
                            self.offset = geo.size.height/3
                        }
                    }
            )
                .onAppear {
                    self.offset = geo.size.height/3
            }
        }
    }
}

struct LineChartSwiftUI: UIViewRepresentable {
    @State var lineChart = LineChartView()
    @ObservedObject var viewModel: ChartVM
    func makeUIView(context: UIViewRepresentableContext<LineChartSwiftUI>) -> LineChartView {
        setUpChart()
        return lineChart
    }
    
    func updateUIView(_ uiView: LineChartView, context: UIViewRepresentableContext<LineChartSwiftUI>) {
        setUpChart()
    }
    
    func setUpChart() {
        lineChart.noDataText = "No Data Available"
        var dataSets = [IChartDataSet]()
        let colors = [AppColors.purple, AppColors.blue, AppColors.darkred, AppColors.darkgreen, AppColors.red]
        var iterator = colors.makeIterator()
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in self.viewModel.sensorReadings {
            var dataEntry = ChartDataEntry()
            let date = DateFormatter.iso8601Full.date(from: i.stamp) ?? Date()
            let valuedate = date.timeIntervalSince1970
            let currdate = Date().timeIntervalSince1970
            print(currdate)
            print(valuedate)
            let x =  valuedate
            let y = Double(i.value)!
            dataEntry = ChartDataEntry(x: x, y: y)
            dataEntries.append(dataEntry)
        }
        let sensorName = self.viewModel.sensor.title ?? "Unknown"
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
            limitLine.labelPosition = .bottomRight
            limitLine.valueFont = .systemFont(ofSize: 8)
        }
        return limitLines
    }
    
}
