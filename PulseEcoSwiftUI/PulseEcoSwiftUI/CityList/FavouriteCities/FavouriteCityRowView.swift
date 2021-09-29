//
//  CityRowView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/17/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI
import CoreLocation

struct FavouriteCityRowView: View {
    var viewModel: FavouriteCityRowViewModel
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(self.viewModel.siteName)
                        .font(Font.custom("TitilliumWeb-Bold", size: 14))
                    Text(self.viewModel.countryName)
                        .font(Font.custom("TitilliumWeb-SemiBold", size: 11))
                        .foregroundColor(Color.gray)
                    Text(self.viewModel.message)
                        .font(Font.custom("TitilliumWeb-SemiBold", size: 11))
                }
                Spacer()
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(self.viewModel.color)
                    .frame(width: 65, height: 65)
                    .overlay(VStack {
                        if self.viewModel.noReadings == false {
                            Text("\(Int(self.viewModel.value))")
                                .font(.system(size: 20))
                            Text(self.viewModel.unit)
                             .font(.system(size: 14))
                        } else {
                            Image(uiImage: self.viewModel.noReadingsImage)
                                .resizable()
                                .scaledToFit()
                                .padding(20)
                        }
                    })
                    .foregroundColor(Color.white)
                    .padding(10)
            }
            .padding([.leading, .trailing], 10)
            .frame(height: 80)
           // Divider()
        }
    }
}
