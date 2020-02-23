import Foundation
import UIKit

protocol TappableViewDelegate: class {
    func didTap(sender: UIView)
}

class TappableView: UIView {
    weak var delegate: TappableViewDelegate?

    @IBInspectable var shouldAnimateLongPress: Bool = true

    override func awakeFromNib() {
        super.awakeFromNib()

        let longPressRecogniser = UILongPressGestureRecognizer.init(target: self, action: #selector(self.handleLongPress(sender:)))
        longPressRecogniser.minimumPressDuration = 0.001
        self.addGestureRecognizer(longPressRecogniser)
    }

    @objc func handleLongPress(sender: UITapGestureRecognizer? = nil) {
		let state = sender?.state

		if shouldAnimateLongPress && (state == .began || state == .changed) {
			self.alpha = 0.5
		} else {
			self.alpha = 1.0
		}

        if state == .ended {
            delegate?.didTap(sender: self)
        }
    }
}
