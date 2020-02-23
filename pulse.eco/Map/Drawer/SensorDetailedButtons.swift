import Foundation
import UIKit

class SensorDetailedButtons: UIButton {

    override func awakeFromNib() {
        layer.cornerRadius = self.bounds.size.width / 2
        layer.masksToBounds = true
    }

    override var isSelected: Bool {
        didSet {
            backgroundColor = UIColor.white

            let selected = UIImage(named: "selectedFavorites")
            let unselected = UIImage(named: "unselectedFavorites")
            setImage(selected, for: .selected)
            setImage(unselected, for: .normal)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            let selected = UIImage(named: "selectedFavorites")
            let unselected = UIImage(named: "unselectedFavorites")
            backgroundColor = isHighlighted ? UIColor.lightGray : UIColor.white
            if isSelected {
                setImage(selected, for: .highlighted)
            } else {
                setImage(unselected, for: .highlighted)
            }
        }
    }

}
