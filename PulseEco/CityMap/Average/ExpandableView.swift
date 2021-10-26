import SwiftUI
import Combine

struct ExpandableView: View {
    @EnvironmentObject var appState: AppState
    @State var isExpanded = false
    @State var width: CGFloat = 115
    var viewModel: AverageViewModel
    @State var geometry: GeometryProxy
    var body: some View {
        VStack {
            
            HStack {
                
                VStack {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        RoundedCorners(tl: 8, tr: 8, bl: 0, br: 0)
                            .fill(Color(UIColor(white: 0, alpha: 0.3)))
                            .frame(height:  20)
                            .overlay(Text(Trema.text(for: "average"))
                                        .font(.system(size: 13))
                                        .foregroundColor(AppColors.white.color)
                                        .padding(.leading, 10), alignment: .leading
                            )
                        
                        HStack(alignment: .top) {
                            
                            VStack {
                                HStack(spacing: 3) {
                                    Text("\(Int(self.viewModel.value))")
                                        .font(.system(size: 25))
                                        .foregroundColor(AppColors.white.color)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .padding(.top, 5)
                                        .animation(.none)
                                    Text(self.viewModel.unit)
                                        .font(.system(size: 15))
                                        .foregroundColor(AppColors.white.color).padding(.top, 15)
                                        .animation(.none)
                                }
                                .padding(.leading, 10)
                                Spacer()
                                    .frame(height: 10)
                            }
                            
                            if self.isExpanded {
                                
                                Text(self.viewModel.message)
                                    .font(.system(size: 15))
                                    .foregroundColor(AppColors.white.color)
                                    .padding([.trailing], 10)
                                    .padding(.top, 4)
                                    .padding(.bottom, 10)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                            }
                        }
                        
                        if self.isExpanded {
                            bar.transition(.asymmetric(
                                insertion:
                                    .opacity.animation(.default.delay(0.19)),
                                removal:
                                    .opacity.animation(.default.speed(7))
                            ))
                            
                        }
                        
                    }
                    .frame(width: self.width)
                    .background(RoundedCorners(tl: 8, tr: 8, bl: 8, br: 8)
                                    .fill(Color(self.viewModel.colorForValue())))
                    .onTapGesture {
                        self.isExpanded.toggle()
                        self.width = self.isExpanded ? self.geometry.frame(in: .local).maxX - 20 : 115
                    }
                    .padding(.top, 10)
                    .padding(.leading, 10)
                    .animation(.easeInOut(duration: 0.3),
                               value: isExpanded)
                    Spacer()
                }
                
                Spacer()
            }            
        }
        
    }
    
    var bar: some View {
        ZStack(alignment: .leading) {
            HStack(alignment: .bottom, spacing: 0) {
                if self.viewModel.bands.count != 0 {
                    ForEach(0...self.viewModel.bands.count - 1, id: \.self) { indx in
                        RoundedCorners(tl: 0,
                                       tr: 0,
                                       bl: indx == 0 ? 8 : 0,
                                       br: indx == self.viewModel.bands.count - 1 ? 8 : 0)
                            .fill(Color(self.viewModel.bands[indx].legendColor))
                            .frame(width: CGFloat((self.viewModel.bands[indx].width) *
                                                    Double(self.width) / 100),
                                   height: 6,
                                   alignment: .bottom)
                    }
                }
            }.frame(height: 6)
            .shadow(color: self.viewModel.shadow, radius: 0.9, x: 0, y: 0)
            SliderCircle()
                .offset(x: CGFloat(self.viewModel.sliderValue()) * self.width / 100)
                .frame(height: 6)
        }
    }
}
