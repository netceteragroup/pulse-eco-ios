//
//  TimelineSliderViewModel.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 19.12.24.
//
import SwiftUI
import Combine

class TimelineSliderViewModel: ObservableObject {
    @Published var sliderValue: Double
    var onSliderValueChanged: ((Double) -> Void)?
    var currentDate: Date
    var hour: Int
    
    private var cancellables = Set<AnyCancellable>()
    
    init(onSliderValueChanged: @escaping (Double) -> Void) {
        currentDate = Date()
        let calendar = Calendar.current
        self.hour = calendar.component(.hour, from: currentDate)
        sliderValue = Double(hour)
        self.onSliderValueChanged = onSliderValueChanged
        addSubscribers()
    }
    
    func addSubscribers() {
        $sliderValue
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] newValue in
                guard let self = self else { return }
                onSliderValueChanged?(newValue)
            }
            .store(in: &cancellables)
    }
    
    func assignSliderValue(newValue: Double, selectedDate: Date) {
        if isTryingToSelectFutureTime(selectedDate: selectedDate,
                                      newValue: newValue) {
            sliderValue = Double(hour)
        }
        else {
            sliderValue = newValue
        }
    }
    
    func isTryingToSelectFutureTime(selectedDate: Date, newValue: Double) -> Bool {
        selectedDate >= calendar.startOfDay(for: currentDate) && newValue > Double(hour)
    }
}
