//
//  CityMapView.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/17/20.
//

import SwiftUI
import Factory

struct CityMapView: View {
    
    struct Theme {
        static let disclaimerIconColor: Color = AppColors.white.color
        static let disclaimerIconSize: CGSize = CGSize(width: 220, height: 25)
    }
    
    @Injected(\.appData) private var appData: AppDataProtocol
    @EnvironmentObject var refreshService: RefreshService
    
    @Binding private var bottomSheetHeaderSize: CGFloat
    
    init(bottomSheetHeaderSize: Binding<CGFloat>, mapViewModel: MapViewModel) {
        self._bottomSheetHeaderSize = bottomSheetHeaderSize
        self.mapViewModel = mapViewModel
    }
    
    let mapViewModel: MapViewModel
    
    var body: some View {
        
        ZStack {
            MapView(viewModel: mapViewModel)
                .id("MapView")
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    ShadowOnTopOfView()
                )
            
            VStack(alignment: .leading) {
                Spacer()
                
                HStack {
                    if appData.isTimelineSliderActive {
                        createTimelineSliderView()
                    } else {
                        createFloatingButtonView()
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
    
    @ViewBuilder
    private func createFloatingButtonView() -> some View {
        HStack {
            FloatingButton(image: "access-time") {
                mapViewModel.onFloatingButtonTap()
            }
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding(.leading, 15)
            .padding(.trailing, 15)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func createTimelineSliderView() -> some View {
        HStack {
            Spacer()
            
            TimelineSliderView(viewModel: TimelineSliderViewModel(onSliderValueChanged: { sliderValue in
                mapViewModel.onSliderChanged(value: sliderValue)
            }))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal)

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
                    mapViewModel: MapViewModel()
        )
        .environmentObject(AppDataManager())
    }
}
