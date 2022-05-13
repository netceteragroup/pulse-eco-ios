//
//  DateValueModel.swift
//  PulseEco
//
//  Created by Sara Karachanakova on 26.4.22.
//  Copyright © 2022 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI

struct DateValueModel: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
    let color: String
}
