import UIKit
import CoreLocation
import PromiseKit

protocol MainContentViewControllerProtocol {
    func didSelect(measureId: String)
}

typealias MainContentViewController = UIViewController & MainContentViewControllerProtocol

class MasterViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var typeSelectorContainer: UIView!
    @IBOutlet weak var mainContentContainer: UIView!

    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cityNameLabel: UILabel!
	@IBOutlet weak var locationIndicator: UIImageView!
	@IBOutlet var tappableVeiw: [TappableView]!
    var topImageView: UIImageView!
    var bottomImageView: UIImageView!
    var clickedCellMaxY: CGFloat!

    let sharedDataProvider = SharedDataProvider.sharedInstance
    
    var mainContentViewController: MainContentViewController?

    lazy var typeSelectorViewController: TypeSelectorViewController = {
		let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
		let viewController = storyboard.instantiateViewController(withIdentifier: "TypeSelectorViewController") as! TypeSelectorViewController
        viewController.delegate = self
		return viewController
	}()

    lazy var mapViewController: MapViewController = {
        let storyboard = UIStoryboard(name: "Map", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        return viewController
    }()

    lazy var citiesViewController: CitiesViewController = {
        let storyboard = UIStoryboard(name: "Cities", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CitiesViewController") as! CitiesViewController
        viewController.delegate = self
        return viewController
    }()

    let loadingView = try? LoadingDialog.instanceFromNib()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateMeasures()
        
        loadData()
        
        add(asChildViewController: typeSelectorViewController, to: typeSelectorContainer)
        add(mainContentViewController: mapViewController)
		tappableVeiw.forEach { $0.delegate = self }
    }
    
    func updateMeasures() {
        typeSelectorViewController.measureValues = sharedDataProvider.measuresValuesCached
    }
    
    let utilDataProvider = UtilDataProvider()
    
    func loadData() {
        #warning("Should be refactored")
        loadingView?.start()
        locationIndicator.isHidden = true
        firstly {
            DataSource.shared.downloadCities()
        }.then { cities -> Promise<OverallValues> in
            self.typeSelectorViewController.measureValues = self.sharedDataProvider.measuresValuesCached
            self.citiesViewController.cities = cities
            return DataSource.shared.downloadOverall(for: self.sharedDataProvider.selectedCity)
        }.then { overallForCity -> Promise<[SensorReading]> in
            self.mapViewController.overallValues = overallForCity
            return DataSource.shared.downloadValuesForCurrentCity()
        }.then { valuesForCity -> Promise<[OverallValues]> in
            self.sharedDataProvider.selectedCity.currentSensorReadings = valuesForCity
            return DataSource.shared.downloadOverallValues()
        }.then { overallValues -> Promise<[Sensor]> in
            self.citiesViewController.overallValues = overallValues
            return DataSource.shared.downloadSensors(for: self.sharedDataProvider.selectedCity)
        }.done { sensors in
            self.sharedDataProvider.selectedCity.sensors = sensors
            self.setupCityNameLabel()
        }.catch { error in
            print(error)
        }.finally {
            self.mapViewController.updateMap()
            self.updateMeasures()
            self.loadingView?.stop()
        }
    }
    
    private func setupCityNameLabel() {
        cityNameLabel.text = sharedDataProvider.selectedCity.name.uppercased()
    }

    // MARK: - Subviews Util
    private func add(asChildViewController viewController: UIViewController, to containerView: UIView) {
        addChild(viewController)
        containerView.addSubview(viewController.view)

        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        viewController.didMove(toParent: self)
	}

    private func add(mainContentViewController viewController: MainContentViewController) {
        add(asChildViewController: viewController, to: mainContentContainer)
        mainContentViewController = viewController
    }

    private func removeMainContenViewController() {
        mainContentViewController?.willMove(toParent: nil)
        mainContentViewController?.view.removeFromSuperview()
        mainContentViewController?.removeFromParent()
    }

    override func viewSafeAreaInsetsDidChange() {
        headerViewHeightConstraint.constant = 94
        headerViewTopConstraint.constant = 44
    }
}

// MARK: - TypeSelectorViewControllerDelegate
extension MasterViewController: TypeSelectorViewControllerDelegate {
    func didSelect(measureId: String) {
        sharedDataProvider.selectedMeasureId = measureId
        mainContentViewController?.didSelect(measureId: measureId)
    }
}

// MARK: - CitiesViewControllerDelegate
extension MasterViewController: CitiesViewControllerDelegate {
    func didSelect(city: City, topImage: UIImage, bottomImage: UIImage, clickedCellMaxY: CGFloat, row: Int) {
        locationIndicator.isHidden = !city.basedOnLocation
        UserDefaults.standard.set(city.key, forKey: "selectedCityKey")
        sharedDataProvider.selectedCity = city
        loadData()
        mapViewController.city = city
        removeMainContenViewController()
        add(mainContentViewController: mapViewController)
        self.clickedCellMaxY = clickedCellMaxY
        openingAnimation(city: city,
                         topImage: topImage,
                         bottomImage: bottomImage,
                         clickedCellMaxY: clickedCellMaxY,
                         row: row)
    }
}

// MARK: - TappableViewDelegate
extension MasterViewController: TappableViewDelegate {
	func didTap(sender: UIView) {
        if sender.restorationIdentifier == "selectCity" {
            let mapViewImage = mapViewController.view.getFullImage()
            let mapView = UIImageView(image: mapViewImage)
            mapView.frame = CGRect(x: 0, y: 0, width: mainContentContainer.frame.width, height: mainContentContainer.bounds.height)

			removeMainContenViewController()
            citiesViewController.cities = DataSource.shared.cities
            add(mainContentViewController: citiesViewController)

            closingAnimation(mapView: mapView)
		} else if sender.restorationIdentifier == "manualRefresh" {
            DataSource.shared.invalidateData()
            sharedDataProvider.selectedCity.sensorReadings.removeAll()
            sharedDataProvider.selectedCity.currentSensorReadings.removeAll()
            mapViewController.updateDrawer(.hidden)
            mapViewController.selectedMarker = nil
            mapViewController.hideSelectedSensorMarker()
            mapViewController.collapseAverageView()
            loadData()
		}
	}
}
