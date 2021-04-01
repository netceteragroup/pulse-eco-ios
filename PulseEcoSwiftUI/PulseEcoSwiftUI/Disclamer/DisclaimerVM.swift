
import Foundation
import SwiftUI

class DisclaimerVM {
    var title: String = Trema.text(for: "disclaimer", language: UserDefaults.standard.string(forKey: "AppLanguage") ?? "en")
    var message: String = Trema.text(for: "disclaimer_message", language: UserDefaults.standard.string(forKey: "AppLanguage") ?? "en")

    var disclaimerCloseImage: UIImage = UIImage(named: "disclaimerClose") ?? UIImage()
    var disclaimerImage: UIImage = UIImage(named: "disclaimerImage") ?? UIImage()
    var messageFontSize: CGFloat = 14
}
