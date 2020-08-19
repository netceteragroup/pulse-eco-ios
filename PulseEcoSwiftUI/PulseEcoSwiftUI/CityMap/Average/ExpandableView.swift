import SwiftUI
import Combine

struct ExpandableView: View {
    @State var isExpanded = false
    @State var width: CGFloat = 115
    var viewModel: AverageVM
    @State var geometry: GeometryProxy
    var body: some View {
        HStack {
            VStack {
                VStack(alignment: .leading, spacing: 0) {
                    RoundedCorners(tl: 8, tr: 8, bl: 0, br: 0)
                        .fill(Color(UIColor(white: 0, alpha: 0.3)))
                        .frame(height:  20)
                        .overlay( Text("Average")
                            .font(.system(size: 13))
                            .foregroundColor(Color.white)
                            .padding(.leading, 10), alignment: .leading
                        )
                    HStack(alignment: .top) {
                        VStack {
                            HStack(spacing: 3) {
                                Text("\(Int(self.viewModel.value))")
                                    .font(.system(size: 25))
                                    .foregroundColor(Color.white)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .padding(.top, 5)
                                    .animation(.none)
                                Text(self.viewModel.unit)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.white).padding(.top, 15)
                                    .animation(.none)
                            }
                            .padding(.leading, 10)
                            Spacer()
                                .frame(height: 10)
                        }
                        if self.isExpanded {
                            VStack {
                                Text(self.viewModel.message)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.white)
                                    .padding(.leading, 10)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                                    .frame(height: 10)
                            }
                        }
                    }
                    if self.isExpanded {
                        ZStack(alignment: .leading) {
                            HStack(alignment: .bottom, spacing: 0) {
                                if self.viewModel.bands.count != 0 {
                                        ForEach(0...self.viewModel.bands.count - 1, id: \.self) { indx in
                                                RoundedCorners(tl: 0, tr: 0, bl: indx == 0 ? 8 : 0, br: indx == self.viewModel.bands.count - 1 ? 8 : 0) .fill(Color(self.viewModel.bands[indx].legendColor))
                                                    .frame(width: CGFloat((self.viewModel.bands[indx].width) * Double(self.width) / 100), height: 6, alignment: .bottom)
                                        }
                                }
                            }.frame(height: 6)
                            SliderCircle()
                                .offset(x: CGFloat(self.viewModel.sliderValue()) * self.width / 100)
                                .frame(height: 6)
                        }.animation(.default)
                    }
                }.frame(width: self.width)
                    .background(RoundedCorners(tl: 8, tr: 8, bl: 8, br: 8)
                        .fill(Color(self.viewModel.colorForValue())))
                    .onTapGesture {
                        self.isExpanded.toggle()
                        self.width = self.isExpanded ? self.geometry.frame(in: .local).midX * 1.8 : 115
                }.padding(.top, 10)
                    .animation(.easeOut(duration: 0.3))
                Spacer()
            }
            Spacer()
        }.padding(.leading, 10)
    }
}
