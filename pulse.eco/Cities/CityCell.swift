import UIKit
import GoogleMaps
import CoreLocation

class CityCell: UITableViewCell {

    @IBOutlet weak var mapView: GMSMapView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var averageView: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!

    @IBOutlet weak var noValueImage: UIImageView!
    @IBOutlet weak var locationIndicator: UIImageView!

    func set(city: City, value valueSting: String?, measure: Measure, row: Int) {
        nameLabel.text = city.name
        countryLabel.text = city.countryName
        unitLabel.text = measure.unit
        setupMap(withCity: city)
        noValueImage.isHidden = true

        if city.basedOnLocation && row == 0 {
            locationIndicator.isHidden = false
        } else {
            locationIndicator.isHidden = true
        }

        
        if let value = Double(valueSting ?? ""), !value.isNaN {
            valueLabel.isHidden = false
            unitLabel.isHidden = false
            noValueImage.isHidden = true
            valueLabel.adjustsFontSizeToFitWidth = true

            valueLabel.text = String(format: "%.0f", value)
            averageView.backgroundColor = measure.color(forValue: Int(value))
            messageLabel.text = measure.message(forValue: value).components(separatedBy: ".").first!
        } else {
            valueLabel.isHidden = true
            unitLabel.isHidden = true
            noValueImage.isHidden = false

            averageView.backgroundColor = UIColor.lightGray
            messageLabel.text = "There are no readings for \(measure.midSentenceValue()) at this moment. Refresh by tapping the logo, or try again later."
            messageLabel.numberOfLines = 0
        }
    }

    func setupMap(withCity city: City) {
        let camera = GMSCameraPosition.camera(withLatitude: city.coordinates.latitude ,
                                              longitude: city.coordinates.longitude ,
                                              zoom: city.initialZoomLevel)
        mapView.camera = camera
        mapView.isMyLocationEnabled = false
        mapView.isUserInteractionEnabled = false
        if let styleURL = Bundle.main.url(forResource: "lightMap", withExtension: "json") {
            mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
