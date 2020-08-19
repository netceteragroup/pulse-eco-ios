import UIKit

class SelectedSensorView: UIView {
    @IBOutlet weak var titleLabel: UILabel!

    class func instanceFromNib() -> SelectedSensorView {
        let nib = Bundle.main.loadNibNamed("SelectedSensorView", owner: nil, options: nil)![0] as? SelectedSensorView
        return nib!
    }

    func setTitle(title: String) {
        titleLabel.text = title
        let size = titleLabel.intrinsicContentSize
        let width = size.width + 40
        self.frame = CGRect(x: self.frame.origin.x,
                            y: self.frame.origin.y,
                            width: width,
                            height: self.frame.size.height)
    }
}
