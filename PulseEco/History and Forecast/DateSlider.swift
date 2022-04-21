//
//  DateSlider.swift
//  PulseEco
//
//  Created by Sara Karachanakova on 19.4.22.
//  Copyright © 2022 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct DateSlider: View {
    
    let backgroundColorNav = #colorLiteral(red: 0.918249011, green: 0.9182489514, blue: 0.9182489514, alpha: 1)
    let firstButtonColor = #colorLiteral(red: 0.05490196078, green: 0.03921568627, blue: 0.2666666667, alpha: 1)
    @State var unimplementedAlert = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                Button {
                    unimplementedAlert = true
                } label: {
                    VStack(spacing: 0) {
                        Image("history")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.white)
                            .frame(width: 20, height: 20, alignment: .center)
                        Text("Explore")
                            .font(.system(size: 10, weight: .regular))
                    }
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.white)
                    .background(Color(firstButtonColor))
                    .cornerRadius(3)
                    .padding(.leading, 10)
                }
                
                WeekDayButton()
                
            }
        }
        .frame(height: 64)
        .background(Color(backgroundColorNav))
        .alert("Not yet implemented!", isPresented: $unimplementedAlert) {
            Button("OK", role: .cancel) {
                unimplementedAlert = false
            }
        }
    }
}
