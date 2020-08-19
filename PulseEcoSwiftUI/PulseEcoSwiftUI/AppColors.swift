import Foundation
import UIKit

struct AppColors {
    static let darkred = UIColor(red: 177, green: 43, blue: 56)
    static let red = UIColor(red: 214, green: 56, blue: 71)
    static let orange = UIColor(red: 255, green: 152, blue: 0)
    static let green = UIColor(red: 64, green: 151, blue: 87)
    static let darkgreen = UIColor(red: 55, green: 128, blue: 75)
    static let blue = UIColor(red: 0, green: 105, blue: 192)
    static let darkblue = UIColor(red: 14, green: 10, blue: 68)
    static let purple = UIColor(red: 54, green: 0, blue: 166)
	static let indigo = UIColor(red: 55, green: 17, blue: 211)
    static let gray = UIColor(white: 0.5, alpha: 1.0)
    static let lightPurple = UIColor(red: 0.19, green: 0.20, blue: 0.42, alpha: 1.00)
    static var allColors: [UIColor] {
        return [blue, green, orange, purple, red, indigo, darkred, darkgreen]
    }
    
    static func colorFrom(string: String) -> UIColor {
        switch string {
        case "darkred": return darkred
        case "red": return red
        case "orange": return orange
        case "green": return green
        case "darkgreen": return darkgreen
        case "blue": return blue
        case "darkblue": return darkblue
        case "purple": return purple
        case "indigo": return indigo
        default: return gray
        }
    }
    
    static func stringFrom(color: UIColor) -> String {
        switch color {
        case darkred: return "darkred"
        case red: return "red"
        case orange: return "orange"
        case green: return "green"
        case darkgreen: return "darkgreen"
        case blue: return "blue"
        case darkblue: return "darkblue"
        case purple: return "purple"
        case indigo: return "indigo"
        default: return "gray"
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255

        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}
