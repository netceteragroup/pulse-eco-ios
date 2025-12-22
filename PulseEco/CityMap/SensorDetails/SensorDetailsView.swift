//
//  SensorDView.swift
//  PulseEco
//
//  Created by Maja Mitreska on 1/25/21.
//

import SwiftUI

struct SensorDetailsView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var appDataManager: AppDataManager
    @ObservedObject var viewModel: SensorDetailsViewModel
    @Binding var sensorSelectionAlertDialogIsActive: Bool
    @Binding var contentSize: CGFloat
    @Binding var headerSize: CGFloat
    @State var isExpanded: Bool = false
    private var chartViewModel: ChartViewModel {
        ChartViewModel(sensor: appData.selectedSensor ?? SensorPinModel(),
                       sensors: appData.selectedSensorsForGraph,
                       sensorsData: appData.sensorsData24h,
                       selectedMeasure: appDataManager.getCurrentMeasure(selectedMeasure: appData.selectedMeasureId))
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
                    
                    WeeklyAverageView(viewModel: WeeklyAverageViewModel(appData: appData,
                                                                        appDataManager: appDataManager,
                                                                        averages: viewModel.pastWeekAverages))
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
                            if appData.selectedSensorsForGraph.isEmpty {
                                Text(Trema.text(for: "default_no_sensors_selected"))
                                    .foregroundStyle(.black)
                            } else {
                                Text(Trema.text(for: "graph_data_for_selected_sensors"))
                                    .foregroundStyle(.black)
                            }
                        }
                        .padding(10)
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
                    
                    Text(Trema.text(for: "select_up_to_5_sensors"))
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
            Text(Trema.text(for: "select_sensors_button"))
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
