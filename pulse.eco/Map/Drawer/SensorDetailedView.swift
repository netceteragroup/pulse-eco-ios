import Foundation
import UIKit
import Charts

protocol SensorDetailedViewDelegate: class {
    func detailsButtonTapped(sender: SensorDetailedView)
	func resetSelectedSensor()
}

public class SensorDetailedView: UIView {

    weak var delegate: SensorDetailedViewDelegate?
    @IBOutlet weak var sensorTypeIcon: UIImageView!
    @IBOutlet weak var sensorNameLabel: UILabel!
    @IBOutlet weak var sensorValueLabel: UILabel!
    @IBOutlet weak var sensorSuffixLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var isFavoriteButton: UIButton!

    private var sharedDataProvider = SharedDataProvider.sharedInstance
    var selectedCity: City {
        get {
            sharedDataProvider.selectedCity
        }
        set {
            sharedDataProvider.selectedCity = newValue
        }
    }
    var sensorId: String?
    
    

    @IBAction func buttonTapped(_ sender: Any) {
        // increment/decrement favorites list by this sensor
        guard let sensorId = sensorId else { return }
        if FavouritesProvider.shared.favorites(forCity: selectedCity.name).contains(sensorId) {
            FavouritesProvider.shared.remove(favorite: sensorId, forCity: selectedCity.name)
            isFavoriteButton.isSelected = false
        } else {
            if FavouritesProvider.shared.favorites(forCity: selectedCity.name).count >= maxFavoriteSensors {
				showTooltip()
            } else {
                FavouritesProvider.shared.add(favorite: sensorId, forCity: selectedCity.name)
                isFavoriteButton.isSelected = true
            }
        }
    }

	var tooltipShown = false

	func showTooltip() {
		if tooltipShown { return }
		tooltipShown = true
		guard let tooltip = MaxSensorTooltip.instanceFromNib() else { return }

		tooltip.alpha = 0
		addSubview(tooltip)
		bringSubviewToFront(tooltip)

		tooltip.translatesAutoresizingMaskIntoConstraints = false
		tooltip.rightAnchor.constraint(equalTo: isFavoriteButton.leftAnchor, constant: 10).isActive = true
		tooltip.centerYAnchor.constraint(equalTo: isFavoriteButton.centerYAnchor).isActive = true

		UIView.animate(withDuration: 0.3) { tooltip.alpha = 1 }
		let deadline = DispatchTime.now() + .seconds(2)
		DispatchQueue.global(qos: .background).asyncAfter(deadline: deadline) {
			DispatchQueue.main.sync {
				UIView.animate(withDuration: 0.3,
							   animations: { tooltip.alpha = 0 },
							   completion: { _ in
								tooltip.removeFromSuperview()
								self.tooltipShown = false
				})
			}
		}
	}

    @IBAction func detailsButtonTapped(_ sender: Any) {
        delegate?.detailsButtonTapped(sender: self)
    }

	@IBAction func openPrivacyPolicy(_ sender: Any) {
		guard let url = URL(string: privacyPolicyLink) else { return }
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}

    static func instanceFromNib() -> SensorDetailedView {
        guard let nib = UINib(nibName: "SensorDetailedView", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? SensorDetailedView else {
                print("Sensor detail view could not be instantiated.")
                return SensorDetailedView()
        }
        return nib
    }

    func setChart(for sensorReadings: [SensorReading], measure: Measure) {
        var dataSets = [IChartDataSet]()
        var dataEntries: [ChartDataEntry] = []

        for i in sensorReadings {
            var dataEntry = ChartDataEntry()
            let x = i.stamp.timeIntervalSince1970
            let y = Double(i.value)!
            dataEntry = ChartDataEntry(x: x, y: y)
            dataEntries.append(dataEntry)
        }

        let sensorName = sensorReadings.last?.description
        let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: sensorName)
        lineChartDataSet.setColor(AppColors.indigo)

        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.lineWidth = 2.0
        lineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        lineChartDataSet.drawVerticalHighlightIndicatorEnabled = false

        dataSets.append(lineChartDataSet)

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

    func setupView(sensorReadings: [SensorReading],
                   measure: Measure,
                   selectedSensor: Sensor) {
        guard let sensorReadings = sensorReadings.last else { return }

        if FavouritesProvider.shared.favorites(forCity: selectedCity.name).contains(sensorReadings.sensorId) {
            isFavoriteButton.isSelected = true
        } else {
            isFavoriteButton.isSelected = false
            if FavouritesProvider.shared.favorites(forCity: selectedCity.name).count == maxFavoriteSensors {
                if let image = UIImage(named: "disabledFavorites") {
                    isFavoriteButton.setImage(image, for: .normal)
                }
            }
        }

        let filteredSensorReadings = selectedCity.sensorReadings.filter {
            $0.sensorId == selectedSensor.id
        }.filter {
            $0.type == measure.id
        }.sorted { lhs, rhs -> Bool in
            lhs.stamp < rhs.stamp
        }
        
        setChart(for: filteredSensorReadings, measure: measure)

        sensorNameLabel.text = selectedSensor.description
        sensorValueLabel.text = sensorReadings.value
        sensorSuffixLabel.text = measure.unit
        #warning("!!! Set correct image")
        
//        sensorTypeIcon.image = sensorReadings.type.imageForType
        dateLabel.text = DateFormatter.getDate.string(from: sensorReadings.stamp)
        hoursLabel.text = DateFormatter.getTime.string(from: sensorReadings.stamp)
        sensorId = sensorReadings.sensorId
    }
}
