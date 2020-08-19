//
//  CityMapVM.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/17/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI

class CityMapVM: ObservableObject {
    
    @Published var showSensorDetails: Bool
    @Published var citySelectorClicked: Bool
    var backgroundColor: Color = Color.clear
    var disclaimerIconColor: Color = Color(UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1.00))
    var disclaimerIconSize: CGSize = CGSize(width: 220, height: 25)
    var disclaimerIconText: String = "Crowdsourced sensor data"

    init(citySelectorClicked: Bool = false, showSensorDetails: Bool = false, blurBackground: Bool = false) {
        self.citySelectorClicked = citySelectorClicked
        self.showSensorDetails = showSensorDetails
        self.backgroundColor =  blurBackground == true ? Color(UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 0.6)) : Color.clear
    }
}
