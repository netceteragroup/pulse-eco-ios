//
//  CityMapViewModel.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/17/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI

class CityMapViewModel: ObservableObject {
    
    var backgroundColor: Color = Color.clear
    var disclaimerIconColor: Color = Color(UIColor(red: 0.96, green: 0.93, blue: 0.86, alpha: 1.00))
    var disclaimerIconSize: CGSize = CGSize(width: 220, height: 25)
    var disclaimerIconText: String = Trema.text(for: "crowdsourced_sensor_data")

    init(blurBackground: Bool = false) {
        self.backgroundColor =  blurBackground == true ?
            Color(UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 0.6)) :
            Color.clear
    }
}
