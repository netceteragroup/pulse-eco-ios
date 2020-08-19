import SwiftUI

struct MeasureButtonView: View {
    @ObservedObject var viewModel: MeasureButtonVM
    @EnvironmentObject var appVM: AppVM
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Button(action:  {
                self.appVM.selectedMeasure = self.viewModel.id
                self.appVM.updateMapRegion = false
                self.appVM.updateMapAnnotations = true
            }) {
                Text(self.viewModel.title)
                    .font(Font.custom("TitilliumWeb-Regular", size: 13))
                    .accentColor(self.viewModel.titleColor)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, 8)
                    .scaledToFit()
            }.disabled(self.viewModel.clickDisabled).padding(.top, 5)
            Rectangle()
                .frame(height: 2.0)
                .foregroundColor(self.viewModel.underlineColor)
        }
    }
}

