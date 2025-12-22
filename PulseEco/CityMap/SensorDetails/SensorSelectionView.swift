//
//  SensorSelectionView.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 21.1.25.
//

import SwiftUI

struct SensorSelectionView: View {
    @ObservedObject var viewModel: SensorSelectionViewModel
    @EnvironmentObject var appData: AppData
    @Binding var sensorSelectionAlertDialogIsActive: Bool
    
    var body: some View {
        if sensorSelectionAlertDialogIsActive {
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        sensorSelectionAlertDialogIsActive = false
                    }
                
                VStack {
                    Text(Trema.text(for: "tooltip_maximum_sensors_reached"))
                        .font(.title3)
                        .padding()
                    
                    ScrollView {
                        VStack(spacing: 32) {
                            ForEach(viewModel.filteredSensors, id: \.self) { sensor in
                                button(for: sensor)
                                    .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.top)
                    .frame(maxHeight: 350)
                    
                    HStack {
                        Spacer()
                        
                        Button(Trema.text(for: "cancel")) {
                            viewModel.cancel(sensorSelectionAlertDialogIsActive: &sensorSelectionAlertDialogIsActive)
                            appData.showSensorDetails = true
                        }
                        .font(.headline)
                        .foregroundStyle(Color(AppColors.gray))
                        .padding(.trailing)
                        
                        Button(Trema.text(for: "ok")) {
                            viewModel.addToSelectedSensors(sensorSelectionAlertDialogIsActive: &sensorSelectionAlertDialogIsActive)
                            appData.showSensorDetails = true
                        }
                        .font(.headline)
                        .foregroundStyle(Color(AppColors.firstButtonColor))
                    }
                    .padding()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 10)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
            .onAppear() {
                appData.showSensorDetails = false
            }
        }
    }
    
    @ViewBuilder
    private func button(for sensor: SensorPinModel) -> some View {
        Button(action: {
            viewModel.toggleSelection(for: sensor)
        }) {
            HStack {
                viewModel.tmpSelectedSensors.contains(where: {$0.sensorID == sensor.sensorID})
                ? Image(systemName: "checkmark.square")
                    .foregroundColor(Color(AppColors.darkblue))
                : Image(systemName: "square")
                    .foregroundColor(Color(AppColors.gray))
                
                Text(sensor.title ?? "Sensor")
                    .padding(.leading)
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .disabled(viewModel.isDisabled(sensor: sensor))
    }
}
