import Foundation
import UIKit
import MapKit

class MarkerView: UIView {

    @IBOutlet weak var contentView: NSObject!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var markerImage: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func setup(withValue value: Double, color: UIColor) {
        self.markerImage.tintColor = color
        self.valueLabel.text = String(format: "%.0f", value)
    }

}
