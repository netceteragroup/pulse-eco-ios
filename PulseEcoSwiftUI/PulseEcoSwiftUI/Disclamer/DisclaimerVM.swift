
import Foundation
import SwiftUI

class DisclaimerVM {
    var title: String = Trema.text(for: "disclaimer", lang: UserDefaults.standard.string(forKey: "AppleLanguage") ?? "en")
    var message: String = Trema.text(for: "disclaimer_message", lang: UserDefaults.standard.string(forKey: "AppleLanguage") ?? "en")

    var disclaimerCloseImage: UIImage = UIImage(named: "disclaimerClose") ?? UIImage()
    var disclaimerImage: UIImage = UIImage(named: "disclaimerImage") ?? UIImage()
    var messageFontSize: CGFloat = 14
}
