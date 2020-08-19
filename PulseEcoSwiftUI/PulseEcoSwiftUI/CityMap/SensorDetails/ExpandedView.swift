import SwiftUI

struct ExpandedView: View {
    @ObservedObject var viewModel: ExpandedVM
    var body: some View {
        VStack {
            Rectangle().frame(width: 400,height: 200)
            Text(self.viewModel.disclaimerMessage)
                .font(.system(size: 11, weight: .light))
                .foregroundColor(self.viewModel.color)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20).fixedSize(horizontal: false, vertical: true)
            HStack {
                Text("Details").font(.system(size: 13, weight: .medium))
                Text("|").font(.system(size: 13, weight: .medium))
                Text("Privacy Policy").font(.system(size: 13, weight: .medium))
            }.foregroundColor(self.viewModel.color).padding(.top, 10)
           // Spacer().frame(height: 30)
        }
    }
}
