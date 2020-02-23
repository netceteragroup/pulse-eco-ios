import Foundation
import Charts

class LimitLines {
    
    static func getLimitLines(for measure: Measure) -> [ChartLimitLine] {
        var limitLines: [ChartLimitLine] = []
            
        for band in measure.bands {
            let limitLine = ChartLimitLine(limit: Double(band.legendPoint), label: band.shortGrade)
            limitLine.lineColor = band.legendColor
            limitLines.append(limitLine)
        }

        for limitLine in limitLines {
            limitLine.lineWidth = 1
            limitLine.lineDashLengths = [5, 5]
            limitLine.labelPosition = .bottomRight
            limitLine.valueFont = .systemFont(ofSize: 8)
        }
        return limitLines
    }
    
}
