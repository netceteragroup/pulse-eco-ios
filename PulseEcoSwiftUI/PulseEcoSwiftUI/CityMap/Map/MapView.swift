//
//  MapView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/16/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI
import MapKit

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
        map.appState.updateMapRegion = false
        map.appState.updateMapAnnotations = false
        map.appState.getNewSensors = false
        map.dataSource.getDailyAverageDataForSensor(cityName: map.appState.cityName,
                                                    measureType: map.appState.selectedMeasure,
                                                    sensorId: map.appState.selectedSensor?.sensorID ?? "")
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
        map.appState.updateMapRegion = false
        map.appState.updateMapAnnotations = false
        map.appState.getNewSensors = false
    }
}

struct MapView: UIViewRepresentable {
    
    @ObservedObject var viewModel: MapViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @State var boundryAndZoomEnabled = true
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self, $boundryAndZoomEnabled)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let region = MKCoordinateRegion(center: viewModel.selectedCity.center,
                                        span: viewModel.span)
        var newAnnotationListSensorIds: [String] = []
        let currentAnnotations = uiView.annotations as! [SensorPinModel]
        let currentAnnotationsSensorIds = currentAnnotations.map{$0.sensorID}
        let selectedAnnotations = uiView.selectedAnnotations
        
        if self.appState.updateMapAnnotations {
            for pin in self.viewModel.sensors {
                newAnnotationListSensorIds.append(pin.sensorID) // add the ids of the sensors to a list
                if !currentAnnotationsSensorIds.contains(pin.sensorID){ // check if theres a new sensor
                    uiView.addAnnotation(pin) // add the sensor if theres a new one
                }
                else {
                    let foundSensor = currentAnnotations.filter { $0.sensorID == pin.sensorID }.first
                    if foundSensor?.stamp != pin.stamp {
                        uiView.addAnnotation(pin)
                        uiView.removeAnnotation(foundSensor!)
                    }
                }
            }
            for pin in currentAnnotations{ // check the list of current sensors (before adding the new ones)
                if !newAnnotationListSensorIds.contains(pin.sensorID){ // check if theres a removed sensor
                    uiView.removeAnnotation(pin) // delete that sensor from the view
                }
            }
            if let item = selectedAnnotations[safe: 0] { // check if theres a sensor selected
                uiView.deselectAnnotation(item, animated: true) // deselect the sensor
            }
        }
        
        if self.appState.getNewSensors {
            uiView.removeAnnotations(currentAnnotations)
            for pin in self.viewModel.sensors {
                uiView.addAnnotation(pin)
            }
            self.appState.getNewSensors = false
        }
        
        if self.appState.updateMapRegion {
            uiView.setRegion(region, animated: true)
        }
        
        if boundryAndZoomEnabled {
            uiView.mapType = MKMapType.standard
            uiView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region),
                                     animated: true)
            
            let zoomRange = MKMapView.CameraZoomRange(
                maxCenterCoordinateDistance: Double(meters(from: viewModel.selectedCity.intialZoomLevel) * 8)
            )
            uiView.setCameraZoomRange(zoomRange, animated: true)
        }
    }
    
    private func meters(from zoomLevel: Int) -> Double {
        Double(40000) / Double (2<<zoomLevel) * 2000
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
