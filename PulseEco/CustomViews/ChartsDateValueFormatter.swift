import Foundation
import Charts

class ChartsDateValueFormatter: DateFormatter, AxisValueFormatter {
    override init() {
        super.init()
        self.dateFormat = " h a "
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return self.string(from: Date(timeIntervalSince1970: value))
    }
}
