//
//  SensorVM.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/19/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation
import MapKit
import Combine

class SensorPinModel: NSObject, MKAnnotation {
    var title: String?
    var sensorID: String
    var value: String
    var coordinate: CLLocationCoordinate2D
    var type: SensorType
    var color: UIColor
    var stamp: String
    
    static func isIdentical(_ l: SensorPinModel, r: SensorPinModel) -> Bool {
        l.sensorID == r.sensorID &&
        l.value == r.value &&
        l.type == r.type &&
        l.color == r.color &&
        l.coordinate.latitude == r.coordinate.latitude &&
        l.coordinate.longitude == r.coordinate.longitude &&
        l.title == r.title &&
        l.stamp == r.stamp
    }

    init(title: String = "",
         sensorID: String = "",
         value: String = "",
         position: String = "",
         type: String = "",
         color: UIColor = UIColor.clear,
         stamp: String = "--") {
        let coord = position.split(separator: ",")
        if coord.count != 2 {
            self.coordinate = CLLocationCoordinate2D()
        } else {
            self.coordinate = CLLocationCoordinate2D(latitude: Double(coord.first ?? "0") ?? 0,
                                                     longitude: Double(coord.last ?? "0") ?? 0)
        }
        self.title = title
        self.sensorID = sensorID
        self.value = value
        self.type = SensorType(rawValue: type) ?? SensorType.undefined
        self.color = color
        self.stamp = stamp
    }
}

