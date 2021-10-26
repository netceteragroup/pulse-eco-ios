import SwiftUI

struct SensorDetailsView: View {
    @State var isExpanded: Bool = false
    @EnvironmentObject var appVM: AppVM
    @State var collapsedViewSize: CGSize = .zero
    @State var expandedViewSize: CGSize = .zero
    
    var body: some View {
        VStack {
            ChildSizeReader(size: self.$collapsedViewSize) {
                CollapsedView(viewModel: SensorDetailsVM(sensor: self.appVM.selectedSensor ?? SensorVM()))
                    .padding(.top, 5)
            }
            if self.isExpanded {
                ChildSizeReader(size: self.$expandedViewSize) {
                    ExpandedView()
                }
            }
        }.background(RoundedCorners(tl: 40, tr: 40, bl: 0, br: 0).fill(Color(UIColor.white)))
        .offset(y: self.isExpanded
                    ? UIHeight/2 - (self.expandedViewSize.height) + self.collapsedViewSize.height/2
                    : UIHeight/2 - (self.collapsedViewSize.height))
        .animation(.easeIn)
        .transition(.slide)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height < 0 {
                        self.isExpanded = true
                        self.appVM.blurBackground = true
                    } else {
                        self.isExpanded = false
                        self.appVM.blurBackground = false
                    }
                }
        )
    }
}
