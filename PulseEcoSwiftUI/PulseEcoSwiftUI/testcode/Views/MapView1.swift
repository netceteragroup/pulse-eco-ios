//
//  MapView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/1/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

//import SwiftUI
//import MapKit
//
//
//
//class Pin: NSObject, MKAnnotation {
//    var title: String?
//    var sensorID: String?
//    var value: Int?
//
//    var coordinate: CLLocationCoordinate2D
//
//    init(title: String?, sensorID: String?, value: Int, coordinate: CLLocationCoordinate2D) {
//        self.title = title
//        self.sensorID = sensorID
//        self.value = value
//        self.coordinate = coordinate
//
//    }
//
//}
//
//class MapViewCoordinator: NSObject, MKMapViewDelegate {
//    var mapViewController: MapView
//
//    init(_ control: MapView) {
//        self.mapViewController = control
//    }
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        //        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
//        //        button.backgroundColor = .black
//        //        button.setTitle("Show/Hide", for: .normal)
//        //        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//        //
//        guard let annotation = annotation as? Pin else {
//                           return nil
//                       }
//        //mapViewController.sensorID = annotation.sensorID!
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
//
//        let annotatonView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customView")
//        annotatonView.addGestureRecognizer(tapGestureRecognizer)
//
//        annotatonView.canShowCallout = true
//        let uiImage = self.textToImage(drawText: String(annotation.value!), inImage: UIImage(named: "marker")!.withTintColor(UIColor.init(red: 0.00, green: 0.58, blue: 0.20, alpha: 1)), atPoint: CGPoint(x: 17, y: 20))
//        annotatonView.image = uiImage
//        annotatonView.calloutOffset = CGPoint(x: -5, y: 5)
//        //        annotatonView.rightCalloutAccessoryView = button
//        return annotatonView
//
//        //        guard let annotation = annotation as? Pin else {
//        //            return nil
//        //        }
//        //        let identifier = "\(annotation.coordinate)"
//        //        var view: MKMarkerAnnotationView
//        //        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
//        //            dequeuedView.annotation = annotation
//        //            view = dequeuedView
//        //        } else {
//        //            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//        //            view.canShowCallout = true
//        //            view.calloutOffset = CGPoint(x: -5, y: 5)
//        //            view.rightCalloutAccessoryView = UILabel()
//        //            view.markerTintColor = annotation.color
//        //            view.glyphText = "\(annotation.value!)"
//        //
//        //       }
//        //         return view
//
//    }
//    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
//        let textColor = UIColor.white
//        let textFont = UIFont(name: "Helvetica Bold", size: 12)!
//
//        let scale = UIScreen.main.scale
//        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
//
//        let textFontAttributes = [
//            NSAttributedString.Key.font: textFont,
//            NSAttributedString.Key.foregroundColor: textColor,
//            ] as [NSAttributedString.Key : Any]
//        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
//
//        let rect = CGRect(origin: point, size: image.size)
//        text.draw(in: rect, withAttributes: textFontAttributes)
//
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return newImage!
//    }
//
//
//    @objc func buttonAction(sender: UIButton!) {
//        mapViewController.showDetails.toggle()
//    }
//
//    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
//    {
//        mapViewController.showDetails.toggle()
//        mapViewController.networkManager.fetchSensorValues(sensorID: mapViewController.sensorID)
//        print(UIHeight)
//        // Your action
//    }
//
//}
//
//struct MapView: UIViewRepresentable {
//
//    //var coordinate: CLLocationCoordinate2D
//    var coordinate: CityCoordinates
//    var cityModel: CityModel
//    @Binding var showDetails: Bool
//    @State var sensors: [SensorModel]
//    var networkManager: NetworkManager
//    @State var sensorID: String = ""
//    @Binding var sensorValues: [String]
//
//    //    var pins = [Pin(title: "Bitola1", value: 5, coordinate: CLLocationCoordinate2D(latitude: 34.011286, longitude: -116.166868)), Pin(title: "Bitola2", value: 13, coordinate: CLLocationCoordinate2D(latitude: 35.013333, longitude: -116.17358)), Pin(title: "Skopje", value: 6, coordinate: CLLocationCoordinate2D(latitude: 41.998, longitude: 21.4254)), Pin(title: "Bitola", value: 13, coordinate: CLLocationCoordinate2D(latitude: 34.011286, longitude: -116.166868))]
//    //
//    //
//    // @ObservedObject var networkManager = NetworkManager()
//
//    func makeCoordinator() -> MapViewCoordinator {
//        MapViewCoordinator(self)
//    }
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView(frame: .zero)
//        networkManager.delegate = self
//        networkManager.fetchSensors(cityName: cityModel.cityName)
//        mapView.delegate = context.coordinator
//        return mapView
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        //      let coordinate = CLLocationCoordinate2D(latitude: 34.011286, longitude: -116.166868)
//
//        networkManager.fetchSensors(cityName: cityModel.cityName)
//        let span = MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
//        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: Double(coordinate.latitude)!, longitude: Double(coordinate.longitute)!), span: span)
//        // let annotation = MKPointAnnotation()
//        //  annotation.coordinate = coordinate
//
//        uiView.setRegion(region, animated: true)
//
//        let pins:[Pin] = sensors.map{
//            sensor in
//            let coordinates = sensor.position.split(separator: ",")
//            return Pin(title: sensor.description, sensorID: sensor.sensorID, value: 2, coordinate: CLLocationCoordinate2D(latitude: Double(coordinates[0])!, longitude: Double(coordinates[1])!))
//        }
//        for pin in pins {
//            uiView.addAnnotation(pin)
//        }
//        //        for pin in pins {
//        //           uiView.addAnnotation(pin)
//        //        }
//
//        uiView.mapType = MKMapType.standard
//        uiView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
//
//        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: Double(cityModel.intialZoomLevel*1000))//100000)
//        uiView.setCameraZoomRange(zoomRange, animated: true)
//
//
//
//    }
//
//
//
//
//}
//
////struct MapView_Previews: PreviewProvider {
////    static var previews: some View {
////        MapView(coordinate: CLLocationCoordinate2D(), showDetails: .constant(false), sensors: [SensorModel]())
////    }
////}
//
//
//extension MapView: NetworkManagerDelegate {
//
//    func didRecievedData(data: Any) {
//        DispatchQueue.main.async {
////            self.sensors = results
//            self.sensors = data as! [SensorModel]
//
////            print(self.sensors)
//        }
//
//    }
//}
//
