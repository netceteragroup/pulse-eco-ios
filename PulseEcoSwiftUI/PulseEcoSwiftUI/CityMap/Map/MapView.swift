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
    var mapViewController: MapView
    init(_ control: MapView) {
        self.mapViewController = control
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        guard let annotation = annotation as? SensorVM else {
            return nil
        }
        let annotationView = LocationAnnotationView(annotation: annotation, reuseIdentifier: "customView")

        return annotationView
        
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        guard let annotationView = view as? LocationAnnotationView else {
            return
        }
        annotationView.showCallout()
        mapViewController.appVM.showSensorDetails = true
        mapViewController.appVM.selectedSensor = annotationView.pin ?? SensorVM()
        mapViewController.appVM.updateMapRegion = false
        mapViewController.appVM.updateMapAnnotations = false
        mapViewController.dataSource.getDailyAverageDataForSensor(cityName: mapViewController.appVM.cityName,
                                                                  measureType: mapViewController.appVM.selectedMeasure,
                                                                  sensorId: mapViewController.appVM.selectedSensor?.sensorID ?? "")
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView)
    {
        guard let annotationView = view as? LocationAnnotationView else {
            return
        }
        annotationView.hideCallout()
        mapViewController.appVM.showSensorDetails = false
        mapViewController.appVM.updateMapRegion = false
        mapViewController.appVM.updateMapAnnotations = false
    }
}

struct MapView: UIViewRepresentable {
    
    @ObservedObject var viewModel: MapVM
    @EnvironmentObject var appVM: AppVM
    @EnvironmentObject var dataSource: DataSource
    
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
        
//        let span = MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
//        let region = MKCoordinateRegion(center: coordinate, span: span)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        if self.appVM.updateMapAnnotations {
            uiView.removeAnnotations(uiView.annotations)
            for pin in self.viewModel.sensors {
                uiView.addAnnotation(pin)
            }
        }
               
        if self.appVM.updateMapRegion {
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
