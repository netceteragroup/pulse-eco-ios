import SwiftUI

struct NoReadingsView: View {
    private var viewModel = NoReadingsViewModel()
    var body: some View {
        HStack {
            VStack {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        VStack {
                            RoundedCorners(topLeft: 8, topRight: 8, bottomLeft: 0, bottomRight: 0)
                                .fill(self.viewModel.backgroundColor)
                                .frame(height: 23)
                            Spacer()
                        }
                        VStack(alignment: .center, spacing: 3) {
                            Image(uiImage: self.viewModel.image)
                            Text(self.viewModel.text)
                                .padding(.horizontal, 5)
                                .scaledToFit()
                                .minimumScaleFactor(0.5)
                                .foregroundColor(self.viewModel.textColor)
                                .padding(.bottom, 3)
                        }.padding(.top, 3)
                    }
                }.frame(width: 115, height: 65)
                    .background(RoundedCorners(topLeft: 8, topRight: 8, bottomLeft: 8, bottomRight: 0)
                    .fill(self.viewModel.backgroundColor))
                    .padding(.top, 10)
                Spacer()
            }
            Spacer()
        }.padding(.leading, 10)
    }
}
