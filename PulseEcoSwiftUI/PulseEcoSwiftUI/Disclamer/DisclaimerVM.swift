
import Foundation
import SwiftUI

class DisclaimerVM {
    var title: String = "Disclaimer"
    var message: String = "The data collected are not manipulated in any way. We do not guarantee of their correctness. The MOEPP sensor data are stored as receiver from their service, while the pulse.eco devices depend on the correctness of the used sensors: Nova PM SDS011/SDS021, DHT22 and Grove Sounds sensor. Please refer to their data sheets for details."
    var disclaimerCloseImage: UIImage = UIImage(named: "disclaimerClose") ?? UIImage()
    var disclaimerImage: UIImage = UIImage(named: "disclaimerImage") ?? UIImage()
    var messageFontSize: CGFloat = 14
}
