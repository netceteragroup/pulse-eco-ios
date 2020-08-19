import Foundation
import SwiftUI

class ExpandedVM: ObservableObject{
    var disclaimerMessage = "Disclaimer: The data shown comes directly from the used sensors. We do not guarantee of their correctness."
    var color = Color(AppColors.darkblue)
    @Published var sensorData24h: [Sensor]
    
    init(sensorData24h: [Sensor]) {
        self.sensorData24h = sensorData24h
       
    }
}
