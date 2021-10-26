import SwiftUI

struct LineGraph: Shape {
    var dataPoints: [CGFloat]
    
    func path(in rect: CGRect) -> Path {
        func makePoint(at idx: Int) -> CGPoint {
            let point = dataPoints[idx]
            let pointX = rect.width * CGFloat(idx) / CGFloat(dataPoints.count - 1)
            let pointY = (1-point) * rect.height
            return CGPoint(x: pointX, y: pointY)
        }
        
        return Path { point in
            guard dataPoints.count > 1 else { return }
            let start = dataPoints[0]
            point.move(to: CGPoint(x: 0, y: (1-start) * rect.height))
            for idx in dataPoints.indices {
                point.addLine(to: makePoint(at: idx))
            }
        }
    }
}
