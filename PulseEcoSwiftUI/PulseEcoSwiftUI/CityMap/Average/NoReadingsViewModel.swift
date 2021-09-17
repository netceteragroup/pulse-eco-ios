
import Foundation
import SwiftUI

class NoReadingsViewModel {
    var image: UIImage = UIImage(named: "exclamation") ?? UIImage()
    var text: String = Trema.text(for: "no_readings")
    var textColor: Color = Color.white
    var backgroundColor: Color = Color(#colorLiteral(red: 0.4441046119, green: 0.4441156983, blue: 0.4441097379, alpha: 1))
}
