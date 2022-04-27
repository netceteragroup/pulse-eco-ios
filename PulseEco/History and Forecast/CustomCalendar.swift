//
//  CustomCalendar.swift
//  PulseEco
//
//  Created by Sara Karachanakova on 26.4.22.
//  Copyright © 2022 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct CustomCalendar: View {
    
    @State var currentDate: Date = Date()
    @State var currentMonth: Int = 0
    @Binding var showingCalendar: Bool
    
    let firstButtonColor = #colorLiteral(red: 0.05490196078, green: 0.03921568627, blue: 0.2666666667, alpha: 1)
    let greenColor = #colorLiteral(red: 0.3035327792, green: 0.6464360356, blue: 0.4156317115, alpha: 1)
    let orangeColor = #colorLiteral(red: 1, green: 0.5960784314, blue: 0, alpha: 1)
    let redColor = #colorLiteral(red: 0.6941176471, green: 0.168627451, blue: 0.2196078431, alpha: 1)
    let greyColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
    let chevronColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.54)
    
    var body: some View {
        
        //ScrollView(.vertical, showsIndicators: false) {
        
        VStack(spacing: 10) {
            
            HStack() {
                Button {
                    
                } label: {
                    Text("Day")
                        .font(.system(size: 13, weight: .regular))
                        .frame(width: 59, height: 40, alignment: .center)
                        .foregroundColor(Color.white)
                        .background(Color(firstButtonColor))
                        .cornerRadius(4)
                }
                
                Button {
                    
                } label: {
                    Text("Month")
                        .font(.system(size: 13, weight: .regular))
                        .frame(width: 59, height: 40, alignment: .center)
                        .foregroundColor(firstButtonColor.color)
                        .background(Color.white)
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 3) .stroke(Color(firstButtonColor), lineWidth: 1))
                }
                Spacer()
            }
            
            
            let days: [String] = ["M", "T", "W", "T", "F", "S", "S"]
            
            HStack() {
                
                Text("\(extraDate())")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(greyColor))
                
                Spacer(minLength: 0)
                
                Button {
                    withAnimation {
                        currentMonth -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .foregroundColor(Color(chevronColor))
                        .frame(width: 7.41, height: 12)
                }
                .padding(.all)
                
                Button {
                    withAnimation {
                        currentMonth += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .foregroundColor(Color(chevronColor))
                        .frame(width: 7.41, height: 12)
                }
                .padding(.all)
            }
            
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(greyColor))
                }
            }
            
            HStack(spacing: 0) {
                
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(extractDate()) { value in
                        CardView(value: value)
                            .onTapGesture {
                                currentDate = value.date
                            }
                    }
                }
            }
            
            HStack() {
                
                Spacer()
                
                Button {
                    showingCalendar = false
                } label: {
                    Text("CANCEL")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(greyColor))
                }
                .padding(.top)
                
                Button {
                    showingCalendar = false
                } label: {
                    Text("OK")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(firstButtonColor))
                }
                .padding(.top)
                
            }
            .padding(.all)
            
        }
        .onChange(of: currentMonth) { newValue in
            currentDate = getCurrentMonth()
        }
        .padding(.all)
        .background(Color.white)
    }
    
    @ViewBuilder
    func CardView(value: DateValueModel) -> some View {
        
        VStack {
            if value.day != -1 {
                Text("\(value.day)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(redColor))
                    .frame(maxWidth:. infinity)
                    .overlay(
                        Circle()
                            .stroke(Color(redColor), lineWidth: 1)
                            .frame(width: 30, height: 30)
                    )
            }
        }
        .padding(.vertical, 5)
        .frame(height: 20, alignment: .top)
    }
    
    func extraDate() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        
        let date = formatter.string(from: currentDate)
        
        return date
    }
    
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else {
            return Date()
        }
        return currentMonth
    }
    
    func extractDate() -> [DateValueModel] {
        
        let calendar = Calendar.current
        
        let currentMonth = getCurrentMonth()
        
        var days = currentMonth.getAllDates().compactMap { date -> DateValueModel in
            
            let day = calendar.component(.day, from: date)
            
            return DateValueModel(day: day, date: date)
        }
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<firstWeekday - 1 {
            days.insert(DateValueModel(day: -1, date: Date()), at: 0)
        }
        return days
    }
}

extension Date{
    
    func getAllDates()->[Date] {
        
        let calendar = Calendar.current
        
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        return range.compactMap { day->Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}
