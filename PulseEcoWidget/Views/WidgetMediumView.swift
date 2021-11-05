import SwiftUI
import WidgetKit

struct WidgetMediumView: View {
    var entry: WidgetTimelineProvider.Entry
    
    var body: some View {
        ZStack {
            entry.averageUtilModel.colorForValue
            VStack(spacing: 0) {
                header
                mainContent
                gradientBar
            }
        }
    }
    
    var mainContent: some View {
        HStack {
            VStack {
                HStack(spacing: 3) {
                    Text(entry.averageUtilModel.rounderValueString)
                        .font(.system(size: 35))
                        .foregroundColor(AppColors.white.color)
                    Text(entry.averageUtilModel.unit)
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.white.color)
                        .padding(.top, 15)
                }
                .padding(.top, -5)
                Spacer()
            }
            
            Spacer()
            VStack {
                Text(entry.averageUtilModel.shortMessage)
                    .font(.body)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(AppColors.white.color)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Spacer()
                Text(entry.averageUtilModel.suggestion)
                    .font(.footnote)
                    .multilineTextAlignment(.trailing)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(AppColors.white.color)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
    }
    
    var header: some View {
        ZStack {
            darkBar
            HStack {
                Text(entry.averageUtilModel.cityName.capitalized)
                    .font(.title2)
                    .foregroundColor(AppColors.white.color)
                Spacer()
                Text(entry.averageUtilModel.measurementTitle)
                    .font(.body)
                    .foregroundColor(AppColors.white.color)
            }.padding(.horizontal, 15)
        }
    }
    
    var gradientBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                HStack(alignment: .bottom, spacing: 0) {
                    if bands.count != 0 {
                        ForEach(0...bands.count - 1, id: \.self) { indx in
                            Color(bands[indx].legendColor)
                                .frame(width: bands[indx].width * geometry.size.width / 100)
                        }
                    }
                }
                SliderCircle()
                    .offset(x: (CGFloat(entry.averageUtilModel.sliderValue) * geometry.size.width / 100) - 8,
                            y: -4)
            }
            
        }
        .frame(height: 12)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
    }
    
    // MARK: - Utils
    var darkBar: some View {
        Color(UIColor(white: 0, alpha: 0.3))
            .frame(height: darkBarHeight)
    }
    
    var bands: [BandUtilModel] {
        entry.averageUtilModel.bands
    }
    
    var darkBarHeight: CGFloat {
        round(entry.displaySize.height / 5)
    }
}

struct WidgetMediumView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyEntry = SimpleEntry(date: Date(),
                                     displaySize: CGSize(width: 316, height: 158),
                                     averageUtilModel: AverageUtilModel.dummy)
        WidgetMediumView(entry: dummyEntry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
