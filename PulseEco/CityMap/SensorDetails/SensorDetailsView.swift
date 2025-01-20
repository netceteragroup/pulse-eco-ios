//
//  SensorDView.swift
//  PulseEco
//
//  Created by Maja Mitreska on 1/25/21.
//

import SwiftUI

struct SensorDetailsView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    @ObservedObject var viewModel: SensorDetailsViewModel
    @State var isExpanded: Bool = false
    private var chartViewModel: ChartViewModel {
        ChartViewModel(sensor: appState.selectedSensor ?? SensorPinModel(),
                       sensorsData: dataSource.sensorsData24h,
                       selectedMeasure: dataSource.getCurrentMeasure(selectedMeasure: appState.selectedMeasureId))
    }
    
    var body: some View {
        if chartViewModel.sensor.title == "" {
            noSelectionView
        }
        else {
            showSensorDetailsView
        }
    }
    
    var showSensorDetailsView: some View {
        VStack {
            
            RoundedRectangle(cornerRadius: CGFloat(5.0) / 2.0)
                .frame(width: 40, height: 3.0)
                .foregroundColor(AppColors.gray2.color)
                .padding([.top, .bottom], 10)
            
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 1) {
                        HStack {
                            Image(uiImage: self.viewModel.image)
                            Text("\(self.viewModel.title)").foregroundColor(AppColors.gray.color)
                                .font(.system(size: 13))
                        }
                        HStack {
                            Text(self.viewModel.value).font(.system(size: 40))
                            Text(self.viewModel.unit).padding(.top, 10)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(self.viewModel.time)")
                                Text("\(self.viewModel.date)").foregroundColor(AppColors.gray.color)
                            }
                        }
                    }
                }
                .padding([.horizontal], 20)
            }
            
            VStack {
                LineChartSwiftUI(viewModel: chartViewModel)
                .frame(width: min(350, UIScreen.main.bounds.width - 10),
                       height: 200)
                .padding(.bottom)
                
                WeeklyAverageView(viewModel: WeeklyAverageViewModel(appState: appState,
                                                                    dataSource: dataSource,
                                                                    averages: self.viewModel.dailyAverages))
                    .padding(.bottom, 20)
                
                selectSensorsButtonView()
                
                Text(self.viewModel.disclaimerMessage)
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(self.viewModel.color)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .padding(15)
                    .fixedSize(horizontal: false, vertical: true)
                
                privacyPolicyView()

            }
            Spacer()
        }
    }
    
    var noSelectionView: some View {
        VStack {
            
            RoundedRectangle(cornerRadius: CGFloat(5.0) / 2.0)
                .frame(width: 40, height: 3.0)
                .foregroundColor(AppColors.gray2.color)
                .padding([.top, .bottom], 10)
            
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(Trema.text(for: "default_no_sensors_selected"))
                            .foregroundStyle(.black)
                    }
                }
                .padding([.horizontal], 20)
            }
            
            VStack {
                LineChartSwiftUI(viewModel: chartViewModel)
                .frame(width: min(350, UIScreen.main.bounds.width - 10),
                       height: 200)
                .padding(.bottom)
                
                Text(Trema.text(for: "no_sensors_selected"))
                    .font(.caption)
                    .foregroundStyle(Color(AppColors.darkblue))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                
                selectSensorsButtonView()
                    .padding(.top)
                
                Text(self.viewModel.disclaimerMessage)
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(self.viewModel.color)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .padding([.horizontal, .bottom], 15)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                
                privacyPolicyView()

            }.scaledToFit()
            Spacer()
        }
    }
    
    @ViewBuilder
    func selectSensorsButtonView() -> some View {
        Button(action: {
            
        }) {
            Text("SELECT SENSORS") //add trema
                .font(.caption)
                .padding(12)
                .foregroundStyle(Color(AppColors.darkblue))
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(AppColors.darkblue), lineWidth: 1)
                }
        }
    }
    
    @ViewBuilder
    func privacyPolicyView() -> some View {
        Button(action: {
            
        }) {
            Text(Trema.text(for: "privacy_policy"))
                .foregroundStyle(Color(AppColors.darkblue))
                .font(.footnote)
        }
    }
}
