//
//  MeasureModelView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/11/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class MeasureViewModel:  ObservableObject {
    
    @Published var measures = [Measure]()
    private var cancellable: AnyCancellable?
    
    init () {

     self.cancellable = NetworkManager().downloadMeasures().sink(receiveCompletion: { _ in }, receiveValue: { measures in
               self.measures = measures
        
     })
      
    }

}
