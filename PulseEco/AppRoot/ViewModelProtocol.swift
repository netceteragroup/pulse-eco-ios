//
//  ViewModelProtocol.swift
//  PulseEco
//
//  Created by Stefan Lazarevski on 12.5.22.
//  Copyright © 2022 Monika Dimitrova. All rights reserved.
//

import SwiftUI

protocol ViewModelProtocol: ObservableObject {}

protocol ViewWithViewModel: View {
    
    associatedtype ViewModel: ViewModelProtocol
    var viewModel: ViewModel { get }
    init(viewModelClosure: @autoclosure @escaping () -> ViewModel)
    
}

protocol ViewModelDependency: AnyObject {}
