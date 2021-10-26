//
//  CityListViewModel.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/11/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class CityListViewModel:  ObservableObject {
    
    @Published var cityList = [CityModel]()
    private var cancellable: AnyCancellable?
    
   
    init () {

        self.cancellable = NetworkManager().getCities1().catch{ _ in
            Just([CityModel]())
        }.assign(to: \.cityList, on: self)
    }
  
}
