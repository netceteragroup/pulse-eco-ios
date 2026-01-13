//
//  CityMapView.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/17/20.
//

import SwiftUI

struct CityMapView: View {
    
    struct Theme {
        static let disclaimerIconColor: Color = AppColors.white.color
        static let disclaimerIconSize: CGSize = CGSize(width: 220, height: 25)
    }
    
    @EnvironmentObject var appData: AppData
    
    @Binding private var bottomSheetHeaderSize: CGFloat
    @State private var isTimelineSliderActive: Bool = false
    
    init(bottomSheetHeaderSize: Binding<CGFloat>,
         viewModel: CityMapViewModel) {
        self._bottomSheetHeaderSize = bottomSheetHeaderSize
        self.viewModel = viewModel
    }
    
    let viewModel: CityMapViewModel
    
    var body: some View {
        
        ZStack {
            MapView(viewModel: viewModel.mapViewModel, appData: appData)
                .id("MapView")
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    ShadowOnTopOfView()
                )
            
            VStack(alignment: .leading) {
                Spacer()
                
                HStack {
                    if isTimelineSliderActive {
                        timelineSliderView
                    } else {
                        floatingButtonView
                    }
                }
                .padding(.bottom, bottomSheetHeaderSize + getSafeAreaBottom() + 8)
                
            }
            
            AverageView(viewModel: AverageUtilModel(measureId: self.appData.selectedMeasureId,
                                                    cityName: UserSettings.selectedCity.cityName,
                                                    measuresList: self.appData.measures,
                                                    cityValues: self.appData.cityOverall,
                                                    currentValue: self.appData.selectedDateAverageValue))
        }
    }
    
    private var timelineSliderView: some View {
        HStack {
            Spacer()
            TimelineSliderView(viewModel: TimelineSliderViewModel(appData: appData),
                               isTimelineSliderActive: $isTimelineSliderActive)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .environmentObject(appData)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal)
    }
    
    private var floatingButtonView: some View {
        HStack {
            FloatingButton(text: viewModel.formatTime(for: appData.selectedHour)) {
                isTimelineSliderActive = true
            }
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding(.leading, 15)
            .padding(.trailing, 15)
            
            Spacer()
        }
    }
}

func getSafeAreaBottom() -> CGFloat {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window.safeAreaInsets.bottom
        }
    }
    return 0
}

#Preview {
    VStack {
        CityMapView(bottomSheetHeaderSize: .constant(.zero),
                    viewModel: CityMapViewModel()
        )
    }
}
