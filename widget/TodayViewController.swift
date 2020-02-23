import UIKit
import NotificationCenter
import CoreLocation
import PromiseKit

class TodayViewController: UIViewController {
    
    @IBOutlet weak var mainContentHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var averageView: UIView!
    
    @IBOutlet weak var measureLabel: UILabel!
    @IBOutlet weak var valueLabel: ValueLabel!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var shortGradeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var separator: UIVisualEffectView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let reuseIdentifer = "MeasureCell"
    let sectionInsets = UIEdgeInsets(top: 20.0,
                                     left: 20.0,
                                     bottom: 20.0,
                                     right: 20.0)
    let itemsPerRow: Int = 4
    let itemHeight: CGFloat = 50.0
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        _locationManager.activityType = .other
        _locationManager.distanceFilter = 10000.0  // Movement threshold for new events
        _locationManager.allowsBackgroundLocationUpdates = false // disallow in background
        return _locationManager
    }()
    
    let widgetDataProvider = WidgetDataProvider()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        updateWithCachedData()
    }
    
    func setup() {
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        mainContentHeightConstraint.constant = extensionContext?.widgetMaximumSize(for: .compact).height ?? 120
        
        measureLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        valueLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateOverallForCurrentCity()
        updateLocation()
    }
    
    @IBAction func openApp(_ sender: Any) {
        var string = "pulse.eco://widget"
        //TODO: add current city as well. maybe as url parameter
        if widgetDataProvider.measuresValuesUpdateDate != nil {
            string = string + "/\(widgetDataProvider.selectedMeasureID)"
        }
        extensionContext?.open(URL(string: string)! , completionHandler: nil)
    }
}

// MARK: - Data update Flow
extension TodayViewController {
    func updateWithCachedData() {
        updateMainSection(withMeasureValue: widgetDataProvider.selectedMeasureValue())
        collectionView.reloadData()
    }
    
    func updateOverallForCurrentCity() {
        guard let closestCity = widgetDataProvider.closestCity else {
            return
        }
        widgetDataProvider.downloadMeasureValues(for: closestCity).done { resultMeasureValues in
            self.updateMainSection(withMeasureValue: self.widgetDataProvider.selectedMeasureValue())
            self.collectionView.reloadData()
        }.catch { error in
            print(error)
        }
    }
    
    func updateLocation() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            updateData(forCurrentLocation: nil)
        }
    }
    
    func updateData(forCurrentLocation currentLocation: CLLocation?) {
        widgetDataProvider.downloadMeasureValues(forCurrentLocation: currentLocation).done { resultMeasureValues in
            self.updateMainSection(withMeasureValue: self.widgetDataProvider.selectedMeasureValue())
            self.collectionView.reloadData()
        }.catch { error in
            print(error)
        }
    }
    
    func updateMainSection(withMeasureValue measureValue: MeasureValue) {
        let value = measureValue.value
        let measure = measureValue.measure
        
        measureLabel.text = measure.buttonTitle
        valueLabel.set(value: value, unit: measure.unit)
        averageView.backgroundColor = measure.color(forValue: value)
        shortGradeLabel.text = measure.shortGrade(forValue: value)
        
        if let currentCity = widgetDataProvider.closestCity {
            cityLabel.text = currentCity.name
            countryLabel.text = currentCity.countryName
        } else {
            cityLabel.text = "--"
            countryLabel.text = "--"
        }
        
        if let updateDate = widgetDataProvider.measuresValuesUpdateDate {
            timeLabel.text = DateFormatter.getTime.string(from: updateDate)
            dateLabel.text = DateFormatter.getDate.string(from: updateDate)
        } else {
            timeLabel.text = "--:--"
            dateLabel.text = "--.--.--"
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension TodayViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if manager.location != nil {
            manager.stopUpdatingLocation()
        }
        updateData(forCurrentLocation: manager.location)
    }
}

// MARK: - NCWidgetProviding
extension TodayViewController: NCWidgetProviding {
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode,
                                          withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
    
        if expanded {
            let measureValues = widgetDataProvider.measureValues()
            
            let compactHeight = extensionContext?.widgetMaximumSize(for: .compact).height ?? 120
            
            let rowsCount = CGFloat(ceil(Float(measureValues.count) / Float(itemsPerRow)))
            let collectionViewHeight =
                (sectionInsets.top * rowsCount)
                + (rowsCount * itemHeight)
                + sectionInsets.bottom
            preferredContentSize = CGSize(width: maxSize.width, height: collectionViewHeight + compactHeight)
        } else {
            preferredContentSize = maxSize
        }
        
        UIView.animate(withDuration: 0.2) {
            self.separator.alpha = expanded ? 0.5 : 0
            self.collectionView.alpha = expanded ? 1.0 : 0
        }
    }
}

// MARK: - UICollectionView Delegate and DataSource
extension TodayViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return widgetDataProvider.measureValues().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifer,
                                                      for: indexPath as IndexPath) as! MeasureCell
        cell.setup(withMeasureValue: widgetDataProvider.measureValues()[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMeasureValue = widgetDataProvider.measureValues()[indexPath.item]
        widgetDataProvider.selectedMeasureID = selectedMeasureValue.id
        updateMainSection(withMeasureValue: selectedMeasureValue)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        
        return CGSize(width: widthPerItem, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
