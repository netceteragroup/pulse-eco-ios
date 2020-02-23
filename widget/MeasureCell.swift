import UIKit

class MeasureCell: UICollectionViewCell {
    
    @IBOutlet weak var measureLabel: UILabel!
    @IBOutlet weak var valueLabel: ValueLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        measureLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        valueLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    func setup(withMeasureValue measureValue: MeasureValue) {
        measureLabel.text = measureValue.measure.buttonTitle
        valueLabel.set(value: measureValue.value, unit: measureValue.measure.unit)
        contentView.backgroundColor = measureValue.measure.color(forValue: measureValue.value)
    }
}
