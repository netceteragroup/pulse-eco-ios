import SwiftUI

struct MeasureButtonView: View {
    @ObservedObject var viewModel: MeasureButtonViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Button(action: viewModel.measurePressed) {
                VStack(spacing: 0) {
                    Text(self.viewModel.title)
                        .font(.system(size: 13, weight: .regular))
                        .accentColor(self.viewModel.titleColor)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
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
