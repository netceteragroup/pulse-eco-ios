//
//  CalendarViewModel.swift
//  PulseEco
//
//  Created by Stefan Lazarevski on 17.5.22.
//

import Combine

class CalendarViewModel: ViewModelProtocol {
    private let appState: AppState
    private let appDataSource: AppDataSource
    
    @Published var monthlyData: [DayDataWrapper] = []
    private var cancelables = Set<AnyCancellable>()
    
    init(appState: AppState, appDataSource: AppDataSource) {
        self.appState = appState
        self.appDataSource = appDataSource
        
        self.appDataSource.$monthlyData.sink {
            self.monthlyData = $0
        }
        .store(in: &cancelables)
    }
    
}
