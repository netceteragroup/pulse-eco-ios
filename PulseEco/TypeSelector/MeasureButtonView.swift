import SwiftUI

struct MeasureButtonView: View {
    @ObservedObject var viewModel: MeasureButtonViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appDataSource: AppDataSource

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Button(action: {
                Task {
                    await viewModel.measurePressed(appState: appState, appDataSource: appDataSource)
                }
            }) {
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
