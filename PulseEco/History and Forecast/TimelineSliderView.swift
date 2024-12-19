//
//  TimelineSliderView.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 10.12.24.
//

import SwiftUI

struct TimelineSliderView: View {
    @StateObject var viewModel: TimelineSliderViewModel
    @EnvironmentObject private var appState: AppState
    private let timeRange = 0...24

    var body: some View {
        VStack {
            Text("\(formatTime(for: viewModel.sliderValue))")
                .font(.headline)
                .padding(6)
                .background(Capsule().fill(Color.blue))
                .foregroundColor(.white)
                .offset(y: 5)

            ZStack {
                sliderWithClamping()

                VStack {
                    Spacer()
                    HStack(alignment: .top) {
                        ForEach(timeRange.lowerBound...timeRange.upperBound, id: \.self) { hour in
                            Rectangle()
                                .fill(hour % 2 == 0 ? Color.gray.opacity(0.5) : Color.clear)
                                .frame(width: 1, height: hour % 6 == 0 ? 10 : 5)

                            if hour != timeRange.upperBound {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .offset(y: -5)
                }
            }
            .frame(height: 30)

            HStack {
                ForEach(timeRange.lowerBound...timeRange.upperBound, id: \.self) { hour in
                    if hour % 6 == 0 {
                        Text("\(formatTime(for: Double(hour)))")
                            .font(.caption2)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(.white)
                .opacity(0.90)
        )
        .onChange(of: appState.selectedDate) { _ in
            viewModel.assignSliderValue(newValue: viewModel.sliderValue, selectedDate: appState.selectedDate)
        }
    }
    
    private func sliderWithClamping() -> some View {
        Slider(value: Binding(
            get: {
                viewModel.sliderValue
            },
            set: { newValue in
                viewModel.assignSliderValue(newValue: newValue,
                                            selectedDate: appState.selectedDate)
            }),
               in: Double(timeRange.lowerBound)...Double(timeRange.upperBound), step: 1)
            .accentColor(.blue)
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
            .onAppear {
                let progressCircleConfig = UIImage.SymbolConfiguration(scale: .small)
                UISlider.appearance()
                    .setThumbImage(UIImage(systemName: "circle.fill",
                                           withConfiguration: progressCircleConfig), for: .normal)
            }
    }

    private func formattedTime(for value: Double) -> String {
        let hour = Int(value)
        return String(format: "%02d:00", hour)
    }
    
    private func formatTime(for time: Double) -> String {
        let hour = Int(time)
        
        if hour == 12 {
            return "\(hour) PM"
        }
        else if hour == 0 || hour == 24 {
            return "12 AM"
        }
        
        let displayTime = hour % 12
        
        return hour > 12 ? "\(displayTime) PM" : "\(displayTime) AM"
    }
}
