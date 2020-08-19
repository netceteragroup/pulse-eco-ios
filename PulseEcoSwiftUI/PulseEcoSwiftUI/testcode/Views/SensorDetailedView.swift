//
//  SensorDetailedView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/8/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct SensorDetailedView: View {
    @State var showDetails: Bool = true
    var body: some View {
        VStack{
            
           
            GeometryReader{geo in
                
                VStack {
                    Rectangle()
                        .frame(width: 50, height: 3.0, alignment: .bottom)
                        .foregroundColor(Color.black).padding(.top)
                    
                    DetailTop().padding(.top)
                    Spacer()
                    Text("Disclaimer: This data shown ...").padding(.bottom, 50)
                    
                }
                
            }.background(Color(UIColor.white))
                .cornerRadius(40)
                .offset(y: self.showDetails ? UIHeight/3  : UIHeight/17)
                .padding(.top, UIHeight/3)
                .animation(.default)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            //action
                    }
                        
                    .onEnded { _ in
                        self.showDetails.toggle()
                    }
            )
            
        }
    }
}
struct DetailTop: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "star")
                    Text("Karpos3").foregroundColor(Color.gray)
                }
                HStack {
                    Text("980").font(.system(size: 40))
                    Text("hPa").padding(.top, 10)
                    Spacer()
                    VStack (alignment: .leading) {
                        Text("14:10")
                        Text("08.06.2020").foregroundColor(Color.gray)
                    }
                    Image(systemName: "star")
                }
            }
            
        }.padding([.leading, .trailing], 20)
    }
}

struct SensorDetailedView_Previews: PreviewProvider {
    static var previews: some View {
        SensorDetailedView()
    }
}
