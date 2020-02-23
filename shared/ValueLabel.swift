import Foundation
import UIKit

@IBDesignable class ValueLabel: UILabel {
    func set(value: Int?, unit: String?) {
        
        var valueString = "--"
        if let value = value {
            valueString = String(value) 
        }
        let newUnit = unit ?? "--"
        
        let fullString = NSMutableAttributedString(string: "\(valueString) \(newUnit)")
        
        let font = self.font ?? UIFont.systemFont(ofSize: 17)
        let valueRange = NSRange(location: 0, length: valueString.count)
        let valueFontAttribute = [NSAttributedString.Key.font: font]
        fullString.addAttributes(valueFontAttribute, range: valueRange)
        
        let smallFont = font.withSize(font.pointSize * 0.7)
        let unitRange = NSRange(location: valueString.count, length: fullString.length - valueString.count)
        let unitFontAttribute = [NSAttributedString.Key.font: smallFont]
        fullString.addAttributes(unitFontAttribute, range: unitRange)
        
        self.attributedText = fullString
    }
}
