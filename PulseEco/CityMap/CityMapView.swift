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
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var refreshService: RefreshService
    
    @Binding private var bottomSheetHeaderSize: CGFloat
    
    init(bottomSheetHeaderSize: Binding<CGFloat>, mapViewModel: MapViewModel) {
        self._bottomSheetHeaderSize = bottomSheetHeaderSize
        self.mapViewModel = mapViewModel
    }
    
    let mapViewModel: MapViewModel
    
    var body: some View {
        
        ZStack {
            MapView(viewModel: mapViewModel, appState: appState)
                .id("MapView")
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    ShadowOnTopOfView()
                )
            
            VStack(alignment: .leading) {
                Spacer()
                
                HStack {
                    if appState.isTimelineSliderActive {
                        createTimelineSliderView(appState: appState)
                    } else {
                        createFloatingButtonView(appState: appState)
                    }
                }
                .padding(.bottom, bottomSheetHeaderSize + getSafeAreaBottom() + 8)
                
            }
            
            AverageView(viewModel: AverageUtilModel(measureId: self.appState.selectedMeasureId,
                                                    cityName: UserSettings.selectedCity.cityName,
                                                    measuresList: self.dataSource.measures,
                                                    cityValues: self.dataSource.cityOverall,
                                                    currentValue: self.appState.selectedDateAverageValue))
        }
    }
}

@ViewBuilder
private func createTimelineSliderView(appState: AppState) -> some View {
    HStack {
        Spacer()
        
        TimelineSliderView(viewModel: TimelineSliderViewModel(onSliderValueChanged: { sliderValue in
            guard let sensorPinsForSelectedHour = appState.hourlySensors[Int(sliderValue)] else {
                appState.sensorPins = [SensorPinModel()]
                return
            }
            
            if sensorPinsForSelectedHour.isEmpty || sensorPinsForSelectedHour == appState.sensorPins {
                return
            }
            
            appState.sensorPins = sensorPinsForSelectedHour
        }))
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .environmentObject(appState)
        
        Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .padding(.horizontal)
}

@ViewBuilder
private func createFloatingButtonView(appState: AppState) -> some View {
    HStack {
        FloatingButton(image: "access-time") {
            appState.isTimelineSliderActive = true
        }
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.leading, 15)
        .padding(.trailing, 15)
        
        Spacer()
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
                    mapViewModel: MapViewModel(
                        appState: AppState(),
                        appDataSource: AppDataSource(appState: AppState())
                    )
        )
        .environmentObject(AppState())
        .environmentObject(AppDataSource(appState: AppState()))
    }
}
