//
//  DateSlider.swift
//  PulseEco
//
//  Created by Sara Karachanakova on 19.4.22.
//

import SwiftUI

struct DateSlider: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataSource: AppDataSource
    
    @Binding var unimplementedAlert: Bool
    @Binding var unimplementedPicker: Bool
    @Binding var selectedDate: Date
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                LazyHStack {
                    Button {
                        unimplementedAlert.toggle()
                        unimplementedPicker = true
                    } label: {
                        VStack(spacing: 0) {
                            Image("history")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color.white)
                                .frame(width: 20, height: 20, alignment: .center)
                            Text(Trema.text(for: "explore"))
                                .font(.system(size: 10, weight: .regular))
                        }
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color.white)
                        .background(Color(AppColors.firstButtonColor))
                        .cornerRadius(3)
                        .padding(.leading, 10)
                    }
                    Group {
                        ForEach(dataSource.weeklyData, id: \.date) { item in
                            WeekDayButton(date: item.date,
                                          value: item.value,
                                          color: item.color,
                                          highlighted: selectedDate.isSameDay(with: item.date)) {
                                selectedDate = item.date
                                Task {
                                    do {
                                        await try dataSource.updatePins(selectedDate: selectedDate)
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                                          .id(item.date)
                        }
                    }
                }
                .padding(.trailing)
                .onAppear(perform: {
                    proxy.scrollTo(Date(), anchor: .trailing)
                })
            }
            .frame(height: 64)
            .background(Color(AppColors.backgroundColorNav))
        }
        .background(Color(AppColors.backgroundColorNav))
    }
}
