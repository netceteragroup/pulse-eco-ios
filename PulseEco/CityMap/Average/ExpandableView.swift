import SwiftUI
import Combine

struct ExpandableView: View {
    @EnvironmentObject var appState: AppState
    @State var isExpanded = false
    @State var width: CGFloat = 115
    var viewModel: AverageUtilModel
    @State var geometry: GeometryProxy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            mainContent
        }
        .frame(width: self.width)
        .background(Rectangle().fill(self.viewModel.colorForValue))
        .onTapGesture {
            self.isExpanded.toggle()
            self.width = self.isExpanded ? self.geometry.frame(in: .local).maxX - 20 : 115
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.top, 10)
        .padding(.leading, 10)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
    
    var mainContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack {
                    HStack(spacing: 3) {
                        Text(viewModel.rounderValueString)
                            .font(.system(size: 25))
                            .foregroundColor(AppColors.white.color)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.top, 5)
                            .animation(.none)
                        Text(viewModel.unit)
                            .font(.system(size: 15))
                            .foregroundColor(AppColors.white.color).padding(.top, 15)
                            .animation(.none)
                    }
                    .padding(.leading, 10)
                    Spacer()
                        .frame(height: 10)
                }
                if isExpanded {
                    Text(self.viewModel.message)
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.white.color)
                        .padding([.trailing], 10)
                        .padding(.top, 4)
                        .padding(.bottom, 10)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            if isExpanded {
                gradientBar.transition(.asymmetric(
                    insertion: .opacity.animation(.default.delay(0.2)),
                    removal: .opacity.animation(.default.speed(7))
                ))
            }
        }
    }
    
    var header: some View {
        Color(UIColor(white: 0, alpha: 0.3))
            .frame(height: 20)
            .overlay(Text(Trema.text(for: "average"))
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.white.color)
                        .padding(.leading, 10), alignment: .leading
            )
    }
    
    var gradientBar: some View {
        ZStack(alignment: .leading) {
            HStack(alignment: .bottom, spacing: 0) {
                if self.viewModel.bands.count != 0 {
                    ForEach(0...self.viewModel.bands.count - 1, id: \.self) { indx in
                        Color(self.viewModel.bands[indx].legendColor)
                            .frame(width: CGFloat((self.viewModel.bands[indx].width) * Double(self.width) / 100),
                                   alignment: .bottom)
                    }
                }
            }
            .frame(height: 10)
            .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 0)
            SliderCircle()
                .offset(x: CGFloat(self.viewModel.sliderValue) * self.width / 100, y: -3)
                .frame(height: 10)
                .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 0)
        }
    }
}
