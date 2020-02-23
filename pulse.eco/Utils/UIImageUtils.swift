import UIKit

extension UIImage {

	func overlayImage(color: UIColor) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
		let context = UIGraphicsGetCurrentContext()

		color.setFill()

		context!.translateBy(x: 0, y: self.size.height)
		context!.scaleBy(x: 1.0, y: -1.0)

		context!.setBlendMode(CGBlendMode.colorBurn)
		let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
		context!.draw(self.cgImage!, in: rect)

		context!.setBlendMode(CGBlendMode.sourceIn)
		context!.addRect(rect)
		context!.drawPath(using: CGPathDrawingMode.fill)

		let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return coloredImage
	}

    func getImage(isTopImage: Bool, clickedCellMaxY: CGFloat) -> UIImage? {
        let imageCrop: CGRect
        let fullImageHeight = size.height * scale
        let fullImageWidth = size.width * scale
        let minYScaled = clickedCellMaxY * scale

        if isTopImage {
            if clickedCellMaxY <= 0 {
                return UIImage()
            }
            imageCrop = CGRect(x: 0, y: 0, width: fullImageWidth, height: minYScaled)
        } else {
            if clickedCellMaxY >= size.height {
                return UIImage()
            }
            imageCrop = CGRect(x: 0, y: minYScaled, width: fullImageWidth, height: fullImageHeight - minYScaled)
        }

        guard let image = cgImage!.cropping(to: imageCrop) else { return nil }
        return UIImage(cgImage: image)
    }
}
