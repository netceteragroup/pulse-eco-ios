//
//  SensorAnnotationView.swift
//  PulseEco
//
//  Created by Marko Nikolov on 7/7/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import MapKit
import Foundation
import SwiftUI

class LocationAnnotationView: MKAnnotationView {

    var pin: SensorPinModel?
    var markerView: MarkerView?
    var selectedSensor: SelectedSensorView?
    @EnvironmentObject var appState: AppState


    // MARK: Initialization

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        guard let pin = annotation as? SensorPinModel else {
            return
        }
        self.pin = pin
        frame = CGRect(x: 0, y: 0, width: 35, height: 48)
        self.markerView = setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    private func setupUI() -> MarkerView? {
        guard let markerIconView = UINib(nibName: "MarkerView", bundle: nil)
                .instantiate(withOwner: nil, options: nil).first as? MarkerView else { return nil }
        markerIconView.setup(withValue: Double(pin!.value)!, color: pin!.color)
        addSubview(markerIconView)
        markerIconView.frame = bounds
        return markerIconView
    }
    
    func showCallout() {
        guard let markerView = self.markerView else {
            return
        }
        let selectedSensorView = SelectedSensorView.instanceFromNib()
        selectedSensorView.setTitle(title: self.pin?.title ?? "Sensor")

        let calloutViewFrame = markerView.frame

        selectedSensorView.frame = CGRect(x: -(selectedSensorView.frame.width - calloutViewFrame.size.width)/2,
                                          y: -calloutViewFrame.size.height + 5,
                                          width: selectedSensorView.frame.width,
                                          height: selectedSensorView.frame.height)
        let scaleTransform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: 0.1, animations: {
            selectedSensorView.transform = scaleTransform
            selectedSensorView.layoutIfNeeded()
        }) { isCompleted in
            UIView.animate(withDuration: 0.08, animations: {
                selectedSensorView.alpha = 1.0
                selectedSensorView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                selectedSensorView.layoutIfNeeded()
            })
        }
        
        markerView.addSubview(selectedSensorView)
        self.selectedSensor = selectedSensorView
    }
    func hideCallout() {
        guard let selectedSensorView = self.selectedSensor else {
            return
        }
        selectedSensorView.removeFromSuperview()
       // self.appState.isExpanded = false
    }
    
}
