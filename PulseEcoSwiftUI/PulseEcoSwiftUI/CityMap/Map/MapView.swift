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
    
    init(_ control: MapView) {
        self.map = control
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
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let coordinate = self.viewModel.coordinates
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        var newAnnotationListSensorIds: [String] = []
        let currentAnnotations = uiView.annotations as! [SensorPinModel]
        let currentAnnotationsSensorIds = currentAnnotations.map{$0.sensorID}
        let selectedAnnotations = uiView.selectedAnnotations
        if self.appState.updateMapAnnotations { 
            for pin in self.viewModel.sensors {
                //newAnnotationList.append(pin) // add all the needed sensors to a list
                newAnnotationListSensorIds.append(pin.sensorID) // add the ids of the sensors to a list
                if !currentAnnotationsSensorIds.contains(pin.sensorID){ // check if theres a new sensor
                    uiView.addAnnotation(pin) // add the sensor if theres a new one
                }
                else /*if currentAnnotationsSensorIds.contains(pin.sensorID)*/{
                    let foundSensor = currentAnnotations.filter{$0.sensorID == pin.sensorID }.first
                    if foundSensor?.stamp != pin.stamp{
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
        
        if self.appState.getNewSensors{
            for pin in self.viewModel.sensors {
                uiView.addAnnotation(pin)
            }
            uiView.removeAnnotations(currentAnnotations)
            self.appState.getNewSensors = false
        }
               
        if self.appState.updateMapRegion {
            uiView.setRegion(region, animated: true)
        }
       
        uiView.mapType = MKMapType.standard
        uiView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: Double(self.viewModel.intialZoomLevel*8000)) //100000))
        uiView.setCameraZoomRange(zoomRange, animated: true)
//        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action:#selector(Coordinator.triggerTouchAction(tapGestureRecognizer:)))
        //uiView.addGestureRecognizer(tapGestureRecognizer)
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
