import Foundation
import SwiftUI

class DisclaimerViewModel {
    var title: String = Trema.text(for: "disclaimer")
    var message: String = Trema.text(for: "disclaimer_message")

    var disclaimerCloseImage: UIImage = UIImage(named: "disclaimerClose") ?? UIImage()
    var disclaimerImage: UIImage = UIImage(named: "disclaimerImage") ?? UIImage()
    var messageFontSize: CGFloat = 14
}
