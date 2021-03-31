import Foundation
import SwiftUI

class ExpandedVM: ObservableObject{

    var disclaimerMessage = Trema.text(for: "disclaimer_short_message", lang: UserDefaults.standard.string(forKey: "AppleLanguage") ?? "en")
    var color = Color(AppColors.darkblue)
    let url  =  "https://www.netcetera.com/home/privacy-policy.html"
    
    
    @Published var sensorData24h: [Sensor]
    @Published var dailyAverages: [Sensor]

    init(sensorData24h: [Sensor], dailyAverages: [Sensor]) {
        self.sensorData24h = sensorData24h
        self.dailyAverages = dailyAverages
    }
    
   
        
}
