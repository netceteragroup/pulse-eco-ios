//
//  TimelineSliderViewModel.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 19.12.24.
//
import SwiftUI
import Combine
import Factory

@MainActor
class TimelineSliderViewModel: ObservableObject {
    @Injected(\.appDataManager) private var appDataManager
    @Published var sliderValue: Double
    let currentDate: Date
    var hour: Int
    
    private var cancellables = Set<AnyCancellable>()
    
    init(appData: AppData) {
        currentDate = Date()
        self.hour = appData.selectedHour
        sliderValue = Double(hour)
        addSubscribers()
    }
    
    func addSubscribers() {
        $sliderValue
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] newValue in
                guard let self = self else { return }
                self.sliderValueChanged(newValue: newValue)
            }
            .store(in: &cancellables)
    }
    
    private func sliderValueChanged(newValue: Double) {
        let hour = Int(newValue)
        guard self.hour != hour else { return }
        self.hour = hour
        appDataManager.selectFromHourlySlider(selectedHour: hour)
    }
    
    func assignSliderValue(newValue: Double, selectedDate: Date) {
        if isTryingToSelectFutureTime(selectedDate: selectedDate,
                                      newValue: newValue) {
            sliderValue = Double(calendar.component(.hour, from: Date.now))
        }
        else {
            sliderValue = newValue
        }
    }
    
    func isTryingToSelectFutureTime(selectedDate: Date, newValue: Double) -> Bool {
        selectedDate.isSameDay(with: Date.now) && Int(newValue) > calendar.component(.hour, from: Date.now)
    }
    
    func formatTime(for time: Double) -> String {
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
