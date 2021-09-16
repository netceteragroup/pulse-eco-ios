import SwiftUI

struct MeasureButtonView: View {
    @ObservedObject var viewModel: MeasureButtonVM
    @EnvironmentObject var appVM: AppVM
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Button(action:  {
                self.appVM.selectedMeasure = self.viewModel.id
                self.appVM.updateMapRegion = false
                //self.appVM.updateMapAnnotations = true
                self.appVM.getNewSensors = true
                self.appVM.showSensorDetails = false
                self.appVM.selectedSensor = self.appVM.selectedSensor
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

