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
    @ObservedObject var userSettings: UserSettings
    
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
                
                if appState.isTimelineSliderActive {
                    createTimelineSliderView(appState: appState)
                } else {
                    createFloatingButtonView(appState: appState)
                }
                
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                        .fill(Theme.disclaimerIconColor)
                        .frame(width: Theme.disclaimerIconSize.width, height: Theme.disclaimerIconSize.height)
                        .overlay(Text(Trema.text(for: "crowdsourced_sensor_data"))
                            .foregroundColor(AppColors.black.color)
                        )
                        .padding(.bottom, 35)
                        .onTapGesture {
                            self.appState.activeSheet = .disclaimerView
                        }
                    
                }.padding(.trailing, 15.0)
            }
            
            AverageView(viewModel: AverageUtilModel(measureId: self.appState.selectedMeasureId,
                                                    cityName: self.appState.selectedCity.cityName,
                                                    measuresList: self.dataSource.measures,
                                                    cityValues: self.dataSource.cityOverall,
                                                    currentValue: self.appState.selectedDateAverageValue))
        }
    }
}

@ViewBuilder
private func createTimelineSliderView(appState: AppState) -> some View {
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
    .padding(.bottom, appState.selectedSensor != nil ? 60 : 10)
    .padding(.horizontal)
    .lineLimit(1)
    .minimumScaleFactor(0.5)
    .frame(maxWidth: .infinity, alignment: .center)
    .environmentObject(appState)
}

@ViewBuilder
private func createFloatingButtonView(appState: AppState) -> some View {
    FloatingButton(image: "clock") {
        appState.isTimelineSliderActive = true
    }
    .cornerRadius(15)
    .shadow(radius: 5)
    .padding(.leading, 15)
    .padding(.bottom, appState.selectedSensor != nil ? 60 : 10)
}

enum ActiveSheet: Int, Identifiable {
    var id: Int { self.rawValue }
    
    case disclaimerView
}

#Preview {
    VStack {
        CityMapView(userSettings: AppState().userSettings,
                    mapViewModel: MapViewModel(
                        appState: AppState(),
                        appDataSource: AppDataSource(appState: AppState())
                    )
        )
        .environmentObject(AppState())
        .environmentObject(AppDataSource(appState: AppState()))
    }
}
