import UIKit
import CoreLocation

protocol CitiesViewControllerDelegate: class {
    func didSelect(city: City, topImage: UIImage, bottomImage: UIImage, clickedCellMaxY: CGFloat, row: Int)
}

class CitiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MainContentViewControllerProtocol {

    @IBOutlet weak var tableView: UITableView!

    var cities: [City] = []
    
    // selected city is always first
    var sortedCities: [City] {
        get {
            let selectedCity = cities.first { $0.key == sharedDataProvider.selectedCity.key }
            cities.removeAll { $0.key == sharedDataProvider.selectedCity.key }
            var sorted = [City]()
            if let selectedCity = selectedCity { sorted.append(selectedCity) }
            sorted.append(contentsOf: cities)
            cities = sorted
            return sorted
        }
    }
    
    let sharedDataProvider = SharedDataProvider.sharedInstance
    
    var currentMeasureId: String {
        get {
            sharedDataProvider.selectedMeasureId
        }
        set{}
    }
    
    var currentMeasure: Measure {
        get {
            return sharedDataProvider.measuresValuesCached.filter { $0.id == currentMeasureId }.first!.measure
        }
    }
    
    weak var delegate: CitiesViewControllerDelegate?
    
    var overallValues: [OverallValues] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    func didSelect(measureId: String) {
        currentMeasureId = measureId
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedCities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as! CityCell
        let city = self.sortedCities[indexPath.row]
        
        let valuesForCity = overallValues.first { $0.cityName == city.key }
        let valueForReading = valuesForCity?.values[currentMeasureId]
        
        let currentMeasure = sharedDataProvider.measuresValuesCached.filter { $0.id == currentMeasureId }.first!
        cell.set(city: city, value: valueForReading, measure: currentMeasure.measure, row: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cellRect = tableView.rectForRow(at: indexPath)
        cellRect = cellRect.offsetBy(dx: -tableView.contentOffset.x, dy: -tableView.contentOffset.y)
        let clickedCellMaxY = cellRect.maxY

        let fullImage = view.getFullImage()
        guard let topImage = fullImage.getImage(isTopImage: true, clickedCellMaxY: clickedCellMaxY),
              let bottomImage = fullImage.getImage(isTopImage: false, clickedCellMaxY: clickedCellMaxY) else { return }

        delegate?.didSelect(city: cities[indexPath.row],
                            topImage: topImage,
                            bottomImage: bottomImage,
                            clickedCellMaxY: clickedCellMaxY,
                            row: indexPath.row)
    }
}
