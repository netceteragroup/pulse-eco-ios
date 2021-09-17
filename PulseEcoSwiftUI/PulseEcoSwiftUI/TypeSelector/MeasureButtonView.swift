import SwiftUI

struct MeasureButtonView: View {
    @ObservedObject var viewModel: MeasureButtonViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Button(action:  {
                self.appState.selectedMeasure = self.viewModel.id
                self.appState.updateMapRegion = false
                //self.appState.updateMapAnnotations = true
                self.appState.getNewSensors = true
                self.appState.showSensorDetails = false
                self.appState.selectedSensor = self.appState.selectedSensor
            }) {
                VStack(spacing: 0) {
                    Text(self.viewModel.title)
                        .font(Font.custom("TitilliumWeb-Regular", size: 13))
                        .accentColor(self.viewModel.titleColor)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .scaledToFit()
                    Rectangle()
                        .frame(height: 2.0)
                        .foregroundColor(self.viewModel.underlineColor)
                }
            }
            .disabled(self.viewModel.clickDisabled)
        }
        .frame(maxHeight: .infinity)
    }
}

