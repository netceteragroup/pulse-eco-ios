import Foundation
import UIKit

typealias AnimationController = MasterViewController
extension AnimationController {
    func openingAnimation(city: City, topImage: UIImage, bottomImage: UIImage, clickedCellMaxY: CGFloat, row: Int) {
        let topImageHeight = clickedCellMaxY
        let bottomImageHeight = mainContentContainer.frame.height - topImageHeight
        let imageWidth = mainContentContainer.frame.width

        topImageView = UIImageView(image: topImage)
        guard let mapView = mapViewController.view else { return }

        if clickedCellMaxY >= mainContentContainer.frame.height {
            topImageView.frame = CGRect(x: 0, y: 0, width: imageWidth, height: mainContentContainer.frame.height)
            mapView.frame = CGRect(x: 0, y: mainContentContainer.frame.height, width: imageWidth, height: self.mainContentContainer.bounds.height)
        } else {
            topImageView.frame = CGRect(x: 0, y: 0, width: imageWidth, height: topImageHeight)
            mapView.frame = CGRect(x: 0, y: topImageHeight, width: imageWidth, height: self.mainContentContainer.bounds.height)
        }

        bottomImageView = UIImageView(image: bottomImage)
        bottomImageView.frame = CGRect(x: 0, y: topImageHeight, width: imageWidth, height: bottomImageHeight)

        mainContentContainer.addSubview(topImageView)
        mainContentContainer.addSubview(mapView)
        mainContentContainer.addSubview(bottomImageView)

        self.view.bringSubviewToFront(typeSelectorContainer)
        self.view.bringSubviewToFront(headerView)

        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.cityNameLabel.alpha = 1
            self.cityNameLabel.text = city.name.uppercased()
            if city.basedOnLocation && row == 0 {
                self.locationIndicator.alpha = 1
            }
        })

        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            self.topImageView.frame = self.topImageView.frame.offsetBy(dx: 0, dy: -self.topImageView.frame.height)
            mapView.frame = mapView.frame.offsetBy(dx: 0, dy: -self.topImageView.frame.height)
            self.bottomImageView.frame = self.bottomImageView.frame.offsetBy(dx: 0, dy: self.bottomImageView.frame.height)
        }) { _ in
            self.topImageView.removeFromSuperview()
            self.bottomImageView.removeFromSuperview()
        }
    }

    func closingAnimation(mapView: UIView) {
        UIView.animate(withDuration: animationDuration, delay: 0.01, options: .curveEaseInOut, animations: {
            self.cityNameLabel.alpha = 0
            self.locationIndicator.alpha = 0
        })

        if let topImageView = topImageView, let bottomImageView = bottomImageView {
            mainContentContainer.addSubview(mapView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                let fullImage = self.citiesViewController.view.getFullImage()
                let topImage = fullImage.getImage(isTopImage: true, clickedCellMaxY: self.clickedCellMaxY)
                let bottomImage = fullImage.getImage(isTopImage: false, clickedCellMaxY: self.clickedCellMaxY)

                let topView = UIImageView(image: topImage)
                let bottomView = UIImageView(image: bottomImage)

                topView.frame = CGRect(x: 0, y: -topImageView.bounds.height, width: topImageView.bounds.width, height: topImageView.bounds.height)
                bottomView.frame = CGRect(x: 0, y: self.mainContentContainer.frame.height, width: bottomImageView.bounds.width, height: bottomImageView.bounds.height)

                self.mainContentContainer.addSubview(topView)
                self.mainContentContainer.addSubview(bottomView)

                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
                    topView.frame = topView.frame.offsetBy(dx: 0, dy: topView.frame.height)
                    mapView.frame = mapView.frame.offsetBy(dx: 0, dy: topView.frame.height)
                    bottomView.frame = bottomView.frame.offsetBy(dx: 0, dy: -bottomView.frame.height)
                }) { _ in
                    mapView.removeFromSuperview()
                    topView.removeFromSuperview()
                    bottomView.removeFromSuperview()
                }
            }
        } else {
            guard let cityView = citiesViewController.view else { return }
            cityView.frame = CGRect(x: 0, y: mainContentContainer.bounds.height, width: mainContentContainer.frame.width, height: mainContentContainer.bounds.height)

            mainContentContainer.addSubview(mapView)
            mainContentContainer.addSubview(cityView)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
                    cityView.frame = cityView.frame.offsetBy(dx: 0, dy: -cityView.frame.height)
                }, completion: { _ in
                    mapView.removeFromSuperview()
                })
            }
        }
    }
}
