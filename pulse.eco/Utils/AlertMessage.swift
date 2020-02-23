import UIKit

var overlayIsShown = false

func showOverlayMessage(withMessage message: String, dismissAfter dismissInterval: Int = 3) {
	DispatchQueue.main.async {
		if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
			showOverlayMessage(on: rootVC.view, withMessage: message, dismissAfter: dismissInterval)
		}
	}
}

func showOverlayMessage(on view: UIView, withMessage message: String, dismissAfter dismissInterval: Int = 3) {
	if overlayIsShown { return }
	DispatchQueue.main.async {
		overlayIsShown = true
		let messageView = UILabel()
		let topSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
		messageView.frame = CGRect(x: 0, y: -70, width: UIScreen.main.bounds.width, height: 30)
		messageView.backgroundColor = UIColor(red: 0.71, green: 0.71, blue: 0.71, alpha: 1)
		messageView.textColor = .white
		messageView.textAlignment = .center
		messageView.text = message
		messageView.font = UIFont.systemFont(ofSize: 13)
		messageView.layer.zPosition = 1000

		view.addSubview(messageView)
		view.bringSubviewToFront(messageView)

		UIView.transition(with: messageView,
						  duration: 0.5,
						  options: .curveEaseInOut,
						  animations: {
							messageView.frame = CGRect(x: 0,
													   y: topSafeArea,
													   width: messageView.frame.width,
													   height: messageView.frame.height)
		})

		let deadline = DispatchTime.now() + .seconds(dismissInterval)
		DispatchQueue.global(qos: .background).asyncAfter(deadline: deadline) {
			DispatchQueue.main.sync {
				UIView.transition(with: messageView,
								  duration: 0.5,
								  options: .curveEaseInOut,
								  animations: {
									messageView.frame = CGRect(x: 0,
															   y: -70,
															   width: messageView.frame.width,
															   height: messageView.frame.height)
				}, completion: { _ in
					overlayIsShown = false
					messageView.removeFromSuperview()
				})
			}
		}
	}
}
