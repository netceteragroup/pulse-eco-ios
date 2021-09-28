import SwiftUI

struct LoadingView<Content>: View where Content: View {
    
    @Binding var isShowing: Bool
    @Binding var loadingMeasures: Bool
    
    var content: () -> Content
    
    var body: some View {
        ZStack(alignment: .center) {
            if (self.isShowing || self.loadingMeasures) {
                self.content()
                    .disabled(true)
                    .blur(radius: 3)
                VStack {
                    LoadingDialog()
                }
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
            }
            else {
                self.content()
                    .disabled(false)
                    .blur(radius: 0)
            }
        }
    }
}

struct LoadingDialog: View {
    var body: some View {
        ZStack(alignment: .center) {
            Image(uiImage: UIImage(named: "launchScreenBackground") ?? UIImage()).resizable()
            VStack {
                Spacer()
                LottieView().frame(width: 176, height: 66, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                Image(uiImage: UIImage(named: "launchScreenName") ?? UIImage())
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

struct ActivityIndicator: UIViewRepresentable {
    
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
