//
//  MapView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/16/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    @ObservedObject var viewModel: MapViewModel
    let appState: AppState
    @State var boundryAndZoomEnabled = true
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self, $boundryAndZoomEnabled)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        mapView.mapType = .standard
        addAnotations(to: mapView)
        let zoomLevel = viewModel.selectedCity.intialZoomLevel
        let region = MKCoordinateRegion(center: viewModel.selectedCity.center,
                                        span: viewModel.span)
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: Double((23-zoomLevel)*8000))
        mapView.setCameraZoomRange(zoomRange, animated: true)
       
        mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region),
                                 animated: true)
        mapView.setRegion(region, animated: true)

        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if self.viewModel.shouldUpdateSensors {
            addAnotations(to: uiView)
        }

    }
    
    private func addAnotations(to mapView: MKMapView) {
        let currentAnnotations = mapView.annotations as! [SensorPinModel]
        mapView.removeAnnotations(currentAnnotations)
        for pin in self.viewModel.sensors {
            mapView.addAnnotation(pin)
        }
        if self.viewModel.sensors.count > 0 {
            self.viewModel.shouldUpdateSensors = false
        }
    }
    
    private func meters(from zoomLevel: Int) -> Double {
        Double(40000) / Double (2<<zoomLevel) * 20000
    }
}

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    var map: MapView
    @Binding var boundryAndZoomEnabled: Bool
    
    init(_ control: MapView, _ boundryAndZoomEnabled: Binding<Bool>) {
        self.map = control
        _boundryAndZoomEnabled = boundryAndZoomEnabled
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? SensorPinModel else {
            return nil
        }
        let annotationView = LocationAnnotationView(annotation: annotation, reuseIdentifier: "customView")
        let scaleTransform = CGAffineTransform(scaleX: 0.0, y: 0.0)  // Scale
        annotationView.centerOffset = CGPoint(x: 0, y: -annotationView.frame.size.height/2)
        UIView.animate(withDuration: 0.2, animations: {
            annotationView.transform = scaleTransform
            annotationView.layoutIfNeeded()
        }) { (isCompleted) in
            UIView.animate(withDuration: 0.08, animations: {
                annotationView.alpha = 1.0
                annotationView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                annotationView.layoutIfNeeded()
            })
        }
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        boundryAndZoomEnabled = false
        mapView.isZoomEnabled = false
        guard let annotationView = view as? LocationAnnotationView else {
            return
        }
        annotationView.showCallout()
        map.appState.showSensorDetails = true
        map.appState.selectedSensor = annotationView.pin ?? SensorPinModel()
        map.viewModel.getDailyAverageDataForSensor(annotationView.pin?.sensorID ?? "")
        let region = MKCoordinateRegion(center: view.annotation!.coordinate, span: mapView.region.span)
        mapView.animatedSetRegion(region, duration: 0.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.boundryAndZoomEnabled = true
            mapView.isZoomEnabled = true
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView)
    {
        guard let annotationView = view as? LocationAnnotationView else {
            return
        }
        annotationView.hideCallout()
        map.appState.showSensorDetails = false
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension MKMapView {
    func animatedSetRegion(_ region:MKCoordinateRegion, duration:TimeInterval) {
        MKMapView.animate(withDuration: duration,
                          delay: 0,
                          usingSpringWithDamping: 0.6,
                          initialSpringVelocity: 10,
                          options: UIView.AnimationOptions.curveEaseIn,
                          animations: { self.setRegion(region, animated: true) },
                          completion: nil)
    }
}
