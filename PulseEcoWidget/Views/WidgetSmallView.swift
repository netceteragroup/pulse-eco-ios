import SwiftUI
import WidgetKit

struct WidgetSmallView: View {
    var entry: WidgetTimelineProvider.Entry
    
    var body: some View {
        ZStack {
            entry.averageUtilModel.colorForValue
            sideInfo
            mainInfo
        }
    }
    
    var mainInfo: some View {
        HStack(spacing: 3) {
            Text(entry.averageUtilModel.rounderValueString)
                .font(.system(size: 45))
                .foregroundColor(AppColors.white.color)
            Text(entry.averageUtilModel.unit)
                .font(.system(size: 25))
                .foregroundColor(AppColors.white.color)
                .padding(.top, 15)
        }
    }
    
    var sideInfo: some View {
        VStack {
            ZStack {
                darkBar
                Text(entry.averageUtilModel.cityName.capitalized)
                    .font(.title2)
                    .foregroundColor(AppColors.white.color)
            }
            Spacer()
            ZStack {
                darkBar
                Text(entry.averageUtilModel.measurementTitle)
                    .font(.body)
                    .foregroundColor(AppColors.white.color)
            }
        }
    }
    
    // MARK: - Utils
    var darkBar: some View {
        Color(UIColor(white: 0, alpha: 0.3))
            .frame(height: darkBarHeight)
    }
    
    var darkBarHeight: CGFloat {
        round(entry.displaySize.height / 5)
    }
}

struct WidgetSmallView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyEntry = SimpleEntry(date: Date(),
                                     displaySize: CGSize(width: 158, height: 158),
                                     averageUtilModel: AverageUtilModel.dummy)
        WidgetSmallView(entry: dummyEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
