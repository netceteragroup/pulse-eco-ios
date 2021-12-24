import SwiftUI

struct AverageView: View {
    var viewModel: AverageUtilModel
    var body: some View {
        GeometryReader { geo in
            VStack {
                if self.viewModel.clickDisabled {
                    NoReadingsView()
                } else {
                    ExpandableView(viewModel: self.viewModel, geometry: geo)
                }
            }
        }
    }
}
