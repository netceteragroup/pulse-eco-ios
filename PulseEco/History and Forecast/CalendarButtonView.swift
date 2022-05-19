//
//  CalendarButtonView.swift
//  PulseEco
//
//  Created by Sara Karachanakova on 13.5.22.
//

import Foundation
import SwiftUI

struct CalendarButtonView: View {
    
    let day: Int
    let date: Date
    let color: String
    let isDateToday: Bool
    
    var body: some View {
        Text("\(day)")
            .font(.system(size: 14, weight: .regular))
            .frame(maxWidth: .infinity)
            .foregroundColor(isDateToday ? Color.white : Color(color))
            .frame(width: 30, height: 30)
            .overlay(Circle()
                .stroke(Color(color), lineWidth: 1))
            .background(isDateToday ?
                        Circle()
                .fill(Color(color)) : nil )
    }
}
