// swiftlint:disable cyclomatic_complexity
import Foundation
import UIKit
import SwiftUI

struct AppColors {
    
    static let shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)
    static let backgroundColorNav = #colorLiteral(red: 0.918249011, green: 0.9182489514, blue: 0.9182489514, alpha: 1)
    static let firstButtonColor = #colorLiteral(red: 0.05490196078, green: 0.03921568627, blue: 0.2666666667, alpha: 1)
    static let greyColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
    static let chevronColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.54)
    static let pickerColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
    static let borderColor = #colorLiteral(red: 0.06629675627, green: 0.06937607378, blue: 0.3369944096, alpha: 1)
    
    static let darkred = UIColor(named: "darkred")!
    static let red = UIColor(named: "red")!
    static let orange = UIColor(named: "orange")!
    static let green = UIColor(named: "green")!
    static let darkgreen = UIColor(named: "darkgreen")!
    static let blue = UIColor(named: "blue")!
    static let darkblue = UIColor(named: "darkblue")!
    static let purple = UIColor(named: "purple")!
	static let indigo = UIColor(named: "indigo")!
    static let gray = UIColor(named: "gray")!
    static let gray2 = UIColor(named: "gray2")!
    static let lightGray = UIColor(named: "lightGray")!
    static let lightPurple = UIColor(named: "lightPurple")!
    static let white = UIColor(named: "white")!
    static let black = UIColor(named: "black")!
    
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
        case "lightGray": return lightGray
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
        case lightGray: return "lightGray"
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

    var color: Color {
        Color(self)
    }
}
