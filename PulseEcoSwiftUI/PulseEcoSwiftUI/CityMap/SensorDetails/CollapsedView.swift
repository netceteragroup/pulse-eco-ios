import SwiftUI


struct CollapsedView: View {
    var viewModel: SensorDetailsVM
    var body: some View {
        VStack {
            //Rectangle()
                //.frame(width: 50, height: 3.0, alignment: .bottom)
                //.foregroundColor(Color.gray).padding(.top, 10)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 1) {
                    HStack {
                        Image(uiImage: self.viewModel.image)//.animation(.none)
                        Text("\(self.viewModel.title)").foregroundColor(Color.gray)
                            .font(.system(size: 13))//.animation(.none)
                    }
                    HStack {
                        Text(self.viewModel.value).font(.system(size: 40))
                        Text(self.viewModel.unit).padding(.top, 10)
                        Spacer()
                        VStack (alignment: .trailing) {
                            Text("\(self.viewModel.time)")
                            Text("\(self.viewModel.date)").foregroundColor(Color.gray)
                        }
                        // Image(uiImage: UIImage(named: "unselectedFavorites") ?? UIImage())
                    }
                   //Spacer().frame(height: 10)
                }
            }.padding([.horizontal], 20)
        }
    }
}
