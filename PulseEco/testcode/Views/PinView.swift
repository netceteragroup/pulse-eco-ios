//
//  PinView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/2/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI
import MapKit
//
//extension View {
//    func asImage() -> UIImage {
//        let controller = UIHostingController(rootView: self)
//
//         locate far out of screen
//        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
//     UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
//
//        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
//        controller.view.bounds = CGRect(origin: .zero, size: size)
//        controller.view.sizeToFit()
//
//        let image = controller.view.asImage()
//        controller.view.removeFromSuperview()
//        return image
//    }
//}
//
//extension UIView {
//    func asImage() -> UIImage {
//        let renderer = UIGraphicsImageRenderer(bounds: bounds)
//        return renderer.image { rendererContext in
//// [!!] Uncomment to clip resulting image
////             rendererContext.cgContext.addPath(
////                UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath)
////            rendererContext.cgContext.clip()
//            layer.render(in: rendererContext.cgContext)
//        }
//    }
//}


struct PinView: View {
    
    var text = "Pin1"
    var value = 5
    var color = Color.green
    @State var showText = false
    var body: some View {
        
     
        HStack {
            VStack {


                Button(action: {
                    self.showText.toggle()
                }) {
                    VStack{
                    if showText {
                        Text(text)
                        .clipShape(Capsule())
                            .frame(width: 50, height: 30)
                            .background(Color.purple)
                            .foregroundColor(Color.white)
                        Image(uiImage: UIImage(named: "Triangle")!)
                    }
                    Image(uiImage: UIImage(named: "marker")!)
                                   .accentColor(color)
                                   .opacity(1.0)
                        .overlay(Text("\(value)").foregroundColor(Color.black))
                    }
                    
                }.padding()
                }

        }.background(Color.red.opacity(0.0))
    }
//        func render() -> UIImage {
//          PinView().asImage()
  //    }
}


struct PinView_Previews: PreviewProvider {
    static var previews: some View {
        PinView()
    }
}
