import UIKit
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate, MainContentViewControllerProtocol, UIGestureRecognizerDelegate {

    enum DrawerState {
        case hidden
        case preview
        case full
    }
    
	@IBOutlet weak var mapView: GMSMapView!
	@IBOutlet weak var averageView: TappableView!
	@IBOutlet weak var darkerBackgroundColor: UIView!
    @IBOutlet weak var averageViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var averageViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var averageViewTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var averageValueLabel: UILabel!
	@IBOutlet weak var unitsLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var sliderLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var slider: UIView!

    @IBOutlet weak var noReadingsImage: UIImageView!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var noReadingsLabel: UILabel!
    @IBOutlet weak var disclaimerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var averageSliderViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var averageSliderViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var averageSliderView: UIView!

    private var averageViewIsCollapsed = true
	var messageLabelText = ""
    var noReadings: Bool = false
    @IBOutlet weak var disclaimerView: UIView!

    @IBOutlet weak var drawer: UIView!
    @IBOutlet weak var drawerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var drawerGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var handleIndicator: UIView!
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var detailsView: SensorDetailedView!

    var drawerViewFullHeight: CGFloat = 450
    var drawerViewPreviewHeight: CGFloat = 130
    var drawerState: DrawerState = .hidden
    
    var sensorDetailedView: SensorDetailedView? = SensorDetailedView.instanceFromNib()
    var favoriteSensorsView: FavoriteSensorsView? = FavoriteSensorsView.instanceFromNib()
    var noSensorsSelectedView: NoSensorsSelectedView? = NoSensorsSelectedView.instanceFromNib()
    
    let loadingView = try? LoadingDialog.instanceFromNib()
    
    var currentMeasure: Measure {
        get {
            return sharedDataProvider.measuresValuesCached.filter { $0.id == currentMeasureId }.first!.measure
        }
    }

    var city: City {
        get {
            sharedDataProvider.selectedCity
        }
        set {}
    }
    var sensorReadings: [SensorReading] {
        get {
            sharedDataProvider.selectedCity.sensorReadings
        }
    }
    var currentSensorReadings: [SensorReading] {
        get {
            sharedDataProvider.selectedCity.currentSensorReadings
        }
    }
    var overallValues: OverallValues?
    var sharedDataProvider = SharedDataProvider.sharedInstance
    
    var currentMeasureId: String {
        get {
            sharedDataProvider.selectedMeasureId
        }
        set {}
    }
	var selectedMarker: GMSMarker?
	private let locationManager = CLLocationManager()
	lazy var selectedSensorMarker: GMSMarker = {
		let marker = GMSMarker()
		marker.tracksViewChanges = false
		marker.iconView?.clipsToBounds = true
		marker.iconView = try? SelectedSensorView.instanceFromNib()
		marker.appearAnimation = .pop
		marker.groundAnchor = CGPoint(x: 0.5, y: 2.2)
		return marker
	}()

	override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        updateMap()
        averageView.delegate = self
        detailsView.delegate = self
        setupHandleIndicator()
        drawerGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MapViewController.panGesture))
        drawerGestureRecognizer.delegate = self
        drawer.addGestureRecognizer(drawerGestureRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSensorReadings()
        updateAverageView(measureId: currentMeasureId)
        setFavoritesView()

        updateDrawer(.hidden)
        hideSelectedSensorMarker()
        selectedMarker = nil
        
        setDarkViewAlpha()
    }

    // this is happening only once, at startup
    private func setupMap() {
        mapView.clear()

        mapView.settings.setAllGesturesEnabled(true)
        mapView.settings.rotateGestures = false

        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        locationManager.stopUpdatingLocation()

        if let styleURL = Bundle.main.url(forResource: "lightMap", withExtension: "json") {
            mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
        }
        
        mapView.delegate = self
        mapView.setMinZoom(11, maxZoom: 15)
        mapView.padding = UIEdgeInsets.zero
	}

    func updateMap() {
        updateSensorReadings()
        
        let northEastBound = CLLocationCoordinate2D(latitude: city.bounds().NEBound.latitude, longitude: city.bounds().NEBound.longitude)
        let southWestBound = CLLocationCoordinate2D(latitude: city.bounds().SWBound.latitude, longitude: city.bounds().SWBound.longitude)

        let bounds = GMSCoordinateBounds(coordinate: northEastBound, coordinate: southWestBound)

        var camera = mapView.camera(for: bounds, insets: UIEdgeInsets())!
        camera = GMSCameraPosition.camera(withLatitude: city.coordinates.latitude,
                                          longitude: city.coordinates.longitude,
                                          zoom: city.initialZoomLevel)
        mapView.camera = camera
    }

    func updateSensorReadings() {
        mapView.clear()

		setFavoritesView()

        currentSensorReadings.forEach { reading in
            if reading.type == currentMeasureId {
                createGMSMarker(from: reading, for: currentMeasureId)
            }
        }

        updateAverageView(measureId: currentMeasureId)
    }

    func createGMSMarker(from sensorReading: SensorReading, for measureId: String) {
        let markerIconView = UINib(nibName: "MarkerView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! MarkerView
        let marker = GMSMarker()

        let markerColor = currentMeasure.color(forValue: Int(sensorReading.value)!)
        markerIconView.setup(withValue: Double(sensorReading.value)!, color: markerColor)
        marker.tracksViewChanges = false
        marker.iconView?.clipsToBounds = true
        marker.iconView = markerIconView
        marker.position = CLLocationCoordinate2D(latitude: sensorReading.position.latitude,
                                                 longitude: sensorReading.position.longitude)
        marker.appearAnimation = .pop
        marker.userData = sensorReading.sensorId
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.8) // because the pin tip is not at the bottom
        marker.map = mapView
    }

	func hideSelectedSensorMarker() {
		selectedSensorMarker.position = kCLLocationCoordinate2DInvalid
		selectedSensorMarker.map = nil
	}

	// MARK: - MapView methods
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        updateDrawer((selectedMarker != nil) ? drawerState : .preview)
        selectedSensorMarker.userData = marker.userData
        updateDetailedViewAndUpdateDataIfNeeded(marker: marker)
        selectedMarker = marker
        return true
    }

	func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        selectedMarker = nil
        updateDrawer(.hidden)
        setFavoritesView()
		hideSelectedSensorMarker()
		collapseAverageView()
	}

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        var latitude  = position.target.latitude
        var longitude = position.target.longitude

        let northEastBound = city.bounds().NEBound
        let southWestBound = city.bounds().SWBound

        //northEast out of bounds Latitude (top out of bounds)
        if position.target.latitude > northEastBound.latitude {
            latitude = northEastBound.latitude
        }

        //southWest out of bounds Latitude (bottom out of bounds)
        if position.target.latitude < southWestBound.latitude {
            latitude = southWestBound.latitude
        }

        //northEast out of bounds Longitude (right out of bounds)
        if position.target.longitude > northEastBound.longitude {
            longitude = northEastBound.longitude
        }

        //southWest out of bounds Longitude (left out of bounds)
        if position.target.longitude < southWestBound.longitude {
            longitude = southWestBound.longitude
        }

        if latitude != position.target.latitude || longitude != position.target.longitude {
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            mapView.animate(toLocation: location)
        }
    }

	// MARK: - Respond to user actions
	func didSelect(measureId: String) {
        updateSensorReadings()
        updateAverageView(measureId: measureId)

        guard let sensorId = selectedSensorMarker.userData as? String else { return }
        let filteredReadings = city.getReadingsForSensor(sensorId: sensorId, forMeasureId: measureId)

        if !filteredReadings.isEmpty {
            updateDetailedViewAndUpdateDataIfNeeded(marker: selectedSensorMarker)
        } else {
            setFavoritesView()
            hideSelectedSensorMarker()
        }
	}

    @IBAction func showDisclaimer(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Disclaimer", bundle: nil)
        let disclaimerVC = storyboard.instantiateInitialViewController() as! DisclaimerVC
        self.present(disclaimerVC, animated: true)
    }
}

// MARK: - TappableViewDelegate
extension MapViewController: TappableViewDelegate {
	func didTap(sender: UIView) {
		if averageViewIsCollapsed && !noReadings {
			expandAverageView()
		} else {
			collapseAverageView()
		}
	}

    func updateAverageView(measureId: String) {
        
        guard let value = Double(overallValues?.values[measureId] ?? "") else {
            showNoReadings()
            return
        }

        if value.isNaN {
            showNoReadings()
        } else {
            showAverageValue(average: value, measureId: measureId)
        }
    }

    func showNoReadings() {
        if averageViewIsCollapsed == false {
            collapseAverageView()
        }

        noReadings = true
        slider.isHidden = true
        averageView.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        darkerBackgroundColor.backgroundColor = #colorLiteral(red: 0.4441046119, green: 0.4441156983, blue: 0.4441097379, alpha: 1)
        averageLabel.isHidden = true
        averageValueLabel.isHidden = true
        unitsLabel.isHidden = true
        messageLabel.isHidden = true
        noReadingsLabel.isHidden = false
        noReadingsImage.isHidden = false
    }

    func showAverageValue(average value: Double, measureId: String) {
        noReadings = false
        noReadingsLabel.isHidden = true
        noReadingsImage.isHidden = true
        averageLabel.isHidden = false
        averageValueLabel.isHidden = false
        unitsLabel.isHidden = false
        messageLabel.isHidden = false
        unitsLabel.text = currentMeasure.unit
        averageValueLabel.text = String(format: "%.0f", value)
        averageView.backgroundColor = currentMeasure.color(forValue: Int (value))
        darkerBackgroundColor.backgroundColor = UIColor(white: 0, alpha: 0.3)
        messageLabelText = currentMeasure.message(forValue: value)
        slider.layer.cornerRadius = 6

        if averageViewIsCollapsed == false {
            messageLabel.text = messageLabelText
            averageValueLabel.adjustsFontSizeToFitWidth = true
            unitsLabel.adjustsFontSizeToFitWidth = true
            moveSlider(average: value)
        } else {
            averageSliderView.alpha = 0
            slider.isHidden = true
            averageValueLabel.sizeToFit()
        }
    }

	func expandAverageView() {
		averageViewIsCollapsed = false
        slider.center.x = 0
        sliderLeftConstraint.constant = 0

        UIView.animate(withDuration: 0.4, animations: {
            self.averageSliderView.alpha = 1
            self.averageViewWidthConstraint.priority = .defaultLow
            self.averageViewTrailingConstraint.priority = .defaultHigh
            self.averageSliderViewTrailingConstraint.priority = .defaultHigh
            self.averageSliderViewBottomConstraint.priority = .defaultHigh
            self.averageViewHeightConstraint.constant = averageViewExpandedHeight
            self.messageLabel.text = self.messageLabelText
            self.messageLabel.isHidden = false
            self.messageLabel.numberOfLines = 4
            self.unitsLabel.adjustsFontSizeToFitWidth = true
            self.averageValueLabel.adjustsFontSizeToFitWidth = true
            self.slider.isHidden = false
            self.updateAverageView(measureId: self.currentMeasureId)
            self.view.layoutIfNeeded()
        })

        averageSliderView.shadowColor = UIColor.black
        averageSliderView.shadowOpacity = 0.5
        averageSliderView.shadowOffset = CGPoint(x: 1, y: -1)
        averageSliderView.shadowRadius = 5
	}

	func collapseAverageView() {
		averageViewIsCollapsed = true
        averageSliderView.alpha = 0

		UIView.animate(withDuration: 0.4, animations: {
            self.unitsLabel.adjustsFontSizeToFitWidth = true
            self.averageValueLabel.sizeToFit()
			self.averageViewTrailingConstraint.priority = .defaultLow
            self.averageSliderViewTrailingConstraint.priority = .defaultLow
            self.averageSliderViewBottomConstraint.priority = .defaultLow
			self.averageViewWidthConstraint.priority = .defaultHigh
			self.averageViewHeightConstraint.constant = averageViewCollapsedHeight
			self.messageLabel.text = ""
			self.messageLabel.isHidden = true
            self.slider.isHidden = true

			self.view.layoutIfNeeded()
		})
	}

    private func moveSlider(average: Double) {
        let (values, multiplier) = currentMeasure.sliderValuesAndMultiplier(average: average)
        let isHugeValue = currentMeasure.isHugeValue(average: average)

        let legendObject = SliderView(frame: CGRect(x: 0, y: 0, width: mapView.bounds.width - 20, height: 6))
        legendObject.colors = currentMeasure.sliderColors()
        legendObject.values = values

        averageSliderView.subviews.forEach { subview in
            if subview is SliderView {
                subview.removeFromSuperview()
            }
        }

        averageSliderView.addSubview(legendObject)

        if isHugeValue {
            sliderLeftConstraint.constant = view.frame.width - minRightSpacing
        } else {
            sliderLeftConstraint.constant = view.frame.width * CGFloat(multiplier)
            if sliderLeftConstraint.constant < minLeftSpacing {
                sliderLeftConstraint.constant = minLeftSpacing
            }
        }

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.slider.center.x = self.sliderLeftConstraint.constant
        })
    }
}

// MARK: - Presentation
extension MapViewController {
    func presentDisclamer() {
        let storyboard = UIStoryboard(name: "Disclamer", bundle: nil)
        let disclaimerVC = storyboard.instantiateInitialViewController() as! DisclaimerVC
        self.present(disclaimerVC, animated: true)
    }
    
    func presentFavorites() {
        let storyboard = UIStoryboard(name: "SelectFavourites", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! SelectFavouritesVC
        vc.selectedCity = city
        self.present(vc, animated: true)
    }
}

// MARK: - FavoriteSensorsViewDelegate
extension MapViewController: FavoriteSensorsViewDelegate {
    func selectFavoritesTapped(sender: FavoriteSensorsView) {
        presentFavorites()
    }

    func detailsButtonTapped(sender: FavoriteSensorsView) {
        presentDisclamer()
    }
}

// MARK: - SensorDetailedViewDelegate
extension MapViewController: SensorDetailedViewDelegate {
    func detailsButtonTapped(sender: SensorDetailedView) {
        presentDisclamer()
    }

    func resetSelectedSensor() {
        #warning("Remove marker icon")
    }
}

// MARK: - NoSensorsSelectedViewDelegate
extension MapViewController: NoSensorsSelectedViewDelegate {
    func selectSensorsTapped(sender: NoSensorsSelectedView) {
        presentFavorites()
    }
}
