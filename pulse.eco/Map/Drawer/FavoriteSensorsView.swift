import Foundation
import UIKit
import Charts

protocol FavoriteSensorsViewDelegate: class {
    func selectFavoritesTapped(sender: FavoriteSensorsView)
    func detailsButtonTapped(sender: FavoriteSensorsView)
}

public class FavoriteSensorsView: UIView {

    weak var delegate: FavoriteSensorsViewDelegate?
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!

    static func instanceFromNib() -> FavoriteSensorsView {

        guard let nib = UINib(nibName: "FavoriteSensorsView", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? FavoriteSensorsView else {
                print("Favorite sensors detail view could not be instantiated.")
                return FavoriteSensorsView()
        }

        return nib
    }

    @IBAction func gearButtonTapped(_ sender: Any) {
        delegate?.selectFavoritesTapped(sender: self)
    }

    @IBAction func detailsButtonTapped(_ sender: Any) {
        delegate?.detailsButtonTapped(sender: self)
    }

	@IBAction func openPrivacyPolicy(_ sender: Any) {
		guard let url = URL(string: privacyPolicyLink) else { return }
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}

    func setChart(for sensorReadings: [SensorReading], measure: Measure, favoriteSensors: [String]) {
        var dataSets = [IChartDataSet]()
        let colors = [AppColors.purple, AppColors.blue, AppColors.darkred, AppColors.darkgreen, AppColors.red]
        var iterator = colors.makeIterator()

        for favoriteSensor in favoriteSensors {

            var dataEntries: [ChartDataEntry] = []
            let readingsForType = sensorReadings.filter { sensorReading in
                sensorReading.type == measure.id && favoriteSensor == sensorReading.sensorId
            }

            for i in readingsForType {
                var dataEntry = ChartDataEntry()
                let x = i.stamp.timeIntervalSince1970
                let y = Double(i.value)!
                dataEntry = ChartDataEntry(x: x, y: y)
                dataEntries.append(dataEntry)
            }

            let sensorName = readingsForType.last?.description
            let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: sensorName)

            lineChartDataSet.setColor(iterator.next()!)

            lineChartDataSet.mode = .cubicBezier
            lineChartDataSet.drawCirclesEnabled = false
            lineChartDataSet.drawValuesEnabled = false
            lineChartDataSet.lineWidth = 2.0
            lineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
            lineChartDataSet.drawVerticalHighlightIndicatorEnabled = false

            dataSets.append(lineChartDataSet)
        }
        let lineChartData = LineChartData(dataSets: dataSets)
        lineChartView.data = lineChartData
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.legend.textColor = .black
        lineChartView.xAxis.labelTextColor = .black
        lineChartView.leftAxis.labelTextColor = .black
        lineChartView.rightAxis.drawAxisLineEnabled = false
        lineChartView.rightAxis.labelTextColor = .black
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.rightAxis.axisMinimum = 0
        lineChartView.xAxis.granularityEnabled = true
        lineChartView.xAxis.drawLabelsEnabled = true
        lineChartView.xAxis.valueFormatter = ChartsDateValueFormatter()
        lineChartView.xAxis.granularity = 1.0
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.pinchZoomEnabled = false
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false

        lineChartView.leftAxis.removeAllLimitLines()
        let limitLines = LimitLines.getLimitLines(for: measure)
        for limitLine in limitLines {
            lineChartView.leftAxis.addLimitLine(limitLine)
        }
        lineChartView.leftAxis.drawLimitLinesBehindDataEnabled = true

        lineChartView.zoomOut()
    }

    public override func awakeFromNib() {
        layer.cornerRadius = 30
    }
}

class FavoriteSensorsButton: UIButton {

    override func awakeFromNib() {
        layer.cornerRadius = self.bounds.size.width / 2
        layer.masksToBounds = true
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.lightGray : UIColor.white
        }
    }

}
