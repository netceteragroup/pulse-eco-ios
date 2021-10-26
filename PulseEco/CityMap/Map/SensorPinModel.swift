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
    
    static func isIdentical(lhs: SensorPinModel, rhs: SensorPinModel) -> Bool {
        lhs.sensorID == rhs.sensorID &&
        lhs.value == rhs.value &&
        lhs.type == rhs.type &&
        lhs.color == rhs.color &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.title == rhs.title &&
        lhs.stamp == rhs.stamp
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
