import Foundation
import UIKit

protocol NoSensorsSelectedViewDelegate: class {
    func selectSensorsTapped(sender: NoSensorsSelectedView)
}

public class NoSensorsSelectedView: UIView {

    weak var delegate: NoSensorsSelectedViewDelegate?
    @IBAction func selectSensorsTapped(_ sender: Any) {
        delegate?.selectSensorsTapped(sender: self)
    }

    @IBOutlet weak var selectSensorsButton: UIButton!

    public override func awakeFromNib() {
        selectSensorsButton.layer.borderWidth = 1.0
        selectSensorsButton.layer.borderColor = AppColors.darkblue.cgColor
        selectSensorsButton.layer.cornerRadius = 5
        layer.cornerRadius = 30
    }

    static func instanceFromNib() -> NoSensorsSelectedView {
        guard let nib = UINib(nibName: "NoSensorsSelectedView", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? NoSensorsSelectedView else {
                print("No sensors selected view could not be instantiated.")
                return NoSensorsSelectedView()
        }
        return nib
    }
}
