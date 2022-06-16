//
//  MonthButtonView.swift
//  PulseEco
//
//  Created by Sara Karachanakova on 16.6.22.
//

import SwiftUI

struct MonthButtonView: View {
    
    let month: String
    let date: Date
    let color: String
    let highlighted: Bool
   
    var body: some View {
        Text("\(month)")
            .font(.system(size: 12, weight: .regular))
            .frame(alignment: .center)
            .foregroundColor(Color(color))
            .padding()
            .overlay(Circle()
                .stroke(Color(color), lineWidth: 1))
    }
}
