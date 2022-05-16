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
    init(vModel: @autoclosure @escaping () -> ViewModel)
}

struct SomeView: ViewWithViewModel {
    @StateObject var viewModel: SomeViewModel
    
    var body: some View {
        EmptyView()
    }
    init(vModel: @autoclosure @escaping () -> SomeViewModel) {
        _viewModel = StateObject(wrappedValue: vModel())
    }
}

class SomeViewModel: ViewModelProtocol {}

struct SomeOtherView: View {
    var body: some View {
        SomeView(vModel: SomeViewModel())
    }
}
