import UIKit
import GoogleMaps
import PromiseKit

private typealias DrawerPanGestureHandling = MapViewController
extension DrawerPanGestureHandling {

    func setupHandleIndicator() {
        let tapOnDrawerRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnDrawer))
        tapOnDrawerRecognizer.delegate = self
        drawer.addGestureRecognizer(tapOnDrawerRecognizer)

        let tapOnHandleRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnHandleIndicator))
        tapOnHandleRecognizer.delegate = self
        handleIndicator.addGestureRecognizer(tapOnHandleRecognizer)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = view.hitTest(firstTouch.location(in: nil), with: event)

            if hitView?.isKind(of: NoSensorsSelectedView.self) == false &&
                hitView?.isKind(of: SensorDetailedView.self) == false &&
                hitView?.isKind(of: FavoriteSensorsView.self) == false {
                updateDrawer(.preview)
            }
        }
    }

    @objc func tapOnHandleIndicator() {
        if (drawerState == .full) {
            updateDrawer(.preview)
        }
    }

    @objc func tapOnDrawer() {
        if (drawerState == .preview) {
            updateDrawer(.full)
        }
    }

    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {

        let translation = recognizer.translation(in: drawer)

        if ((drawerHeightConstraint.constant - translation.y) <= drawerViewFullHeight &&
            (drawerHeightConstraint.constant - translation.y) >= drawerViewPreviewHeight) {
            self.drawerHeightConstraint.constant -= translation.y
            recognizer.setTranslation(CGPoint.zero, in: drawer)
        }

        if recognizer.state == .ended {
            if (drawerViewFullHeight - drawerHeightConstraint.constant <
                drawerHeightConstraint.constant - drawerViewPreviewHeight) {
                updateDrawer(.full)
            } else {
                updateDrawer(.preview)
            }
        }
    }

    func setDarkViewAlpha() {
        if (drawerState != .full) {
            darkView.alpha = 0
        } else {
            let momentaryHeight = drawerViewPreviewHeight - drawer.frame.minY
            let maxPotentialHeight = drawerViewPreviewHeight - drawerViewFullHeight
            darkView.alpha = (momentaryHeight/maxPotentialHeight) * 0.5
        }
    }

    func updateDrawer(_ state: DrawerState, _ animationDuration: Double = animationDuration) {
        drawerState = state
        var drawerHeight: CGFloat = 0.0
        var darkViewAlpha: CGFloat = 0.0
        switch drawerState {
        case .hidden:
            drawerHeight = 0
            darkViewAlpha = 0.0
        case .preview:
            drawerHeight = drawerViewPreviewHeight
            darkViewAlpha = 0.0
        case .full:
            drawerHeight = drawerViewFullHeight
            darkViewAlpha = 0.5
        }
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.allowUserInteraction], animations: {
            self.drawerHeightConstraint.constant = drawerHeight
            self.darkView.alpha = darkViewAlpha
            self.view.layoutIfNeeded()
        })
    }
    
    func updateDetailedViewAndUpdateDataIfNeeded(marker: GMSMarker) {
        
        if !city.sensorReadings.isEmpty {
            updateDetailedView(for: marker)
        } else {
            loadingView?.start()
            firstly {
                DataSource.shared.sensorReadings(forCity: sharedDataProvider.selectedCity)
            }.done { readings in
                self.sharedDataProvider.selectedCity.sensorReadings = readings
            }.catch { error in
                print(error)
            }.finally {
                self.updateDetailedView(for: marker)
                self.loadingView?.stop()
            }
        }
    }
    
    func updateDetailedView(for marker: GMSMarker) {
        if marker.userData != nil {
            
            //reset the previous marker title
            hideSelectedSensorMarker()
            
            let sensorId = marker.userData as! String
            
            let readingsForSensor = sensorReadings.filter { $0.sensorId == sensorId }
            
            let sensorReadings = readingsForSensor.filter { sensorReading in
                sensorReading.sensorId == sensorId && sensorReading.type == currentMeasure.id
            }
            
            guard let view = sensorDetailedView else { return }
            view.delegate = self
            view.frame = self.view.bounds
            view.selectedCity = city
            let citySensor = city.sensors.filter { $0.id == sensorId }.first!
            view.setupView(sensorReadings: sensorReadings,
                           measure: currentMeasure,
                           selectedSensor: citySensor)
            
            clearSubviewsInDetailedView()
            detailsView.addSubview(view)
            
            guard let selectedSensor = sensorReadings.last else { return }
            
            if let selectedSensorView = selectedSensorMarker.iconView as? SelectedSensorView {
                selectedSensorView.setTitle(title: citySensor.description)
            }
            selectedSensorMarker.position = CLLocationCoordinate2D(latitude: selectedSensor.position.latitude, longitude: selectedSensor.position.longitude)
            selectedSensorMarker.map = mapView
        }
    }

    func setFavoritesView() {
        // NE RABOTI
//        selectedMarker = nil
//        if let selectedCity = city?.name {
//            let favorites = FavouritesProvider.shared.favorites(forCity: selectedCity)
//
//            if !favorites.isEmpty {
//                let selectedSensors = city!.getAllSensorReadings().filter {
//                    favorites.contains($0.sensorId)
//                }
//                guard let view = favoriteSensorsView else { return }
//
//                view.frame = self.view.bounds
//                view.delegate = self
//                view.setChart(for: selectedSensors, measure: currentMeasure, favoriteSensors: favorites)
//
//                clearSubviewsInDetailedView()
//                detailsView.addSubview(view)
//
//                return
//            } else {
//                guard let view = noSensorsSelectedView else { return }
//
//                view.frame = self.view.bounds
//                view.delegate = self
//
//                clearSubviewsInDetailedView()
//                detailsView.addSubview(view)
//            }
//        }
    }

    private func clearSubviewsInDetailedView() {
        for subview in detailsView.subviews {
            subview.removeFromSuperview()
        }
    }
}
