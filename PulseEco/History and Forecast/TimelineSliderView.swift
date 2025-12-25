//
//  TimelineSliderView.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 10.12.24.
//

import SwiftUI

struct TimelineSliderView: View {
    @StateObject var viewModel: TimelineSliderViewModel
    @EnvironmentObject private var appData: AppData
    private let timeRange = 0...24
    
    @Binding private var isTimelineSliderActive: Bool
    
    init(viewModel: TimelineSliderViewModel, isTimelineSliderActive: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isTimelineSliderActive = isTimelineSliderActive
    }

    var body: some View {
        VStack {
            Text("\(viewModel.formatTime(for: viewModel.sliderValue))")
                .font(.headline)
                .padding(6)
                .background(Capsule().fill(Color(AppColors.firstButtonColor)))
                .foregroundColor(.white)
                .offset(y: 5)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing) {
                    Image(systemName: "xmark")
                        .padding(6)
                        .offset(y: 5)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isTimelineSliderActive = false
                            }
                        }
                }
            
                

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
                        Text("\(viewModel.formatTime(for: Double(hour)))")
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
    }
    
    private func sliderWithClamping() -> some View {
        Slider(
            value: Binding(
                get: {
                    Double(viewModel.sliderValue)
                },
                set: { newValue in
                    let clampedValue = round(newValue)
                    viewModel.assignSliderValue(newValue: clampedValue,
                                                selectedDate: appData.selectedDate)
                }
            ),
            in: Double(timeRange.lowerBound)...Double(timeRange.upperBound),
            step: 1
        )
        .accentColor(Color(AppColors.firstButtonColor))
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
        .onAppear {
            let progressCircleConfig = UIImage.SymbolConfiguration(scale: .small)
            UISlider.appearance()
                .setThumbImage(
                    UIImage(systemName: "circle.fill",
                            withConfiguration: progressCircleConfig),
                    for: .normal
                )
        }
    }
}
