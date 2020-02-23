import Foundation
import UIKit
import Lottie

let targetAlpha: CGFloat = 0.97

class LoadingDialog: UIView {

    @IBOutlet weak var animationView: LOTAnimationView!
    @IBOutlet weak var messageLabel: UILabel!

    var shown: Bool = false

    class func instanceFromNib() throws -> LoadingDialog {
        guard let nib = Bundle.main.loadNibNamed("LoadingDialog", owner: nil, options: nil)![0] as? LoadingDialog else {
            throw Errors.InternalError
        }
        return nib
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        animationView.setAnimation(named: "logo-pulse-loader")
        animationView.loopAnimation = true
    }

    func start() {
        if shown {
            return
        }

        self.messageLabel.text = "Loading data..."

        guard let window = UIApplication.shared.delegate?.window ?? nil else {
            return
        }

        self.frame = window.bounds
        window.addSubview(self)

        // Increase zPosition's value to 1 to bring layer to front
        self.layer.zPosition = 1

        self.animationView.play()

        UIView.animate(withDuration: 0.25, animations: {self.alpha = targetAlpha},
                       completion: { _ in
                       self.shown = true
        })
    }

    func stop(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {self.alpha = 0.0},
                       completion: { _ in
                        self.shown = false
                        self.animationView.stop()
                        self.removeFromSuperview()
                        completion?()
        })
    }
}
