import UIKit
class MaxSensorTooltip: UIView {
	class func instanceFromNib() -> MaxSensorTooltip? {
		return Bundle.main.loadNibNamed("MaxSensorTooltip", owner: nil, options: nil)![0] as? MaxSensorTooltip
	}
}
