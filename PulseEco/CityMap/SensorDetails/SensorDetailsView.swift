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
    @Binding var sensorSelectionAlertDialogIsActive: Bool
    @Binding var contentSize: CGFloat
    @Binding var headerSize: CGFloat
    @State var isExpanded: Bool = false
    private var chartViewModel: ChartViewModel {
        ChartViewModel(sensor: appState.selectedSensor ?? SensorPinModel(),
                       sensors: appState.selectedSensorsForGraph,
                       sensorsData: dataSource.sensorsData24h,
                       selectedMeasure: dataSource.getCurrentMeasure(selectedMeasure: appState.selectedMeasureId),
                       sensorDataForSelectedDate: dataSource.sensorDataForSelectedDate)
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
            VStack {
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
                .padding(.top, 24)
            }
            .overlay(
                GeometryReader { proxy in
                    Color.clear.onAppear() {
                        headerSize = proxy.size.height
                    }
                }
            )
            
            ScrollView {
                VStack {
                    SensorsChart(viewModel: chartViewModel)
                        .clipped()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 10)
                    
                    WeeklyAverageView(viewModel: WeeklyAverageViewModel(appState: appState,
                                                                        dataSource: dataSource,
                                                                        averages: self.viewModel.dailyAverages))
                        .padding(.bottom, 20)
                    
                    Text(self.viewModel.disclaimerMessage)
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(self.viewModel.color)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .padding(15)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    privacyPolicyView()
                    
                    Spacer().frame(height: 24)

                }.overlay(
                    GeometryReader { proxy in
                        Color.clear.onAppear() {
                            contentSize = proxy.size.height
                        }
                    }
                )
            }
            .padding(.top, 8)
        }
    }
    
    var noSelectionView: some View {
        VStack {
            VStack {
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            if appState.selectedSensorsForGraph.isEmpty {
                                Text(Trema.text(for: "default_no_sensors_selected"))
                                    .foregroundStyle(.black)
                            } else {
                                Text("Graph data for selected sensors") // add trema
                                    .foregroundStyle(.black)
                            }
                        }
                    }
                }
                .padding(.top, 24)
            }
            .overlay(
                GeometryReader { proxy in
                    Color.clear.onAppear() {
                        headerSize = proxy.size.height
                    }
                }
            )
            
            ScrollView {
                VStack {
                    SensorsChart(viewModel: chartViewModel)
                        .clipped()
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 10)
                    
                    Text("You can select up to 5 sensors.")
                        .font(.caption)
                        .foregroundStyle(Color(AppColors.darkblue))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    selectSensorsButtonView()
                        .padding(.top)
                    
                    Text(self.viewModel.disclaimerMessage)
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(self.viewModel.color)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .padding(15)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    privacyPolicyView()
                    
                    Spacer().frame(height: 24)
                }
                .overlay(
                    GeometryReader { proxy in
                        Color.clear.onAppear() {
                            contentSize = proxy.size.height
                        }
                    }
                )
            }
            .padding(.top, 8)
        }
    }
    
    @ViewBuilder
    func selectSensorsButtonView() -> some View {
        Button(action: {
            sensorSelectionAlertDialogIsActive = true
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
