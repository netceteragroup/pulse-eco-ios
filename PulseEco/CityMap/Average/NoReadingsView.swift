import SwiftUI

struct NoReadingsView: View {
    private var viewModel = NoReadingsViewModel()
    var body: some View {
        ZStack {
            viewModel.backgroundColor
            VStack(alignment: .center, spacing: 3) {
                Image(uiImage: self.viewModel.image)
                Text(self.viewModel.text)
                    .padding(.horizontal, 5)
                    .scaledToFit()
                    .minimumScaleFactor(0.5)
                    .foregroundColor(self.viewModel.textColor)
                    .padding(.bottom, 3)
            }
            .padding(.top, 3)
        }
        .frame(width: 115, height: 65)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
    }
}
