//
//  CityList.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/3/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI
import MapKit

struct CityList: View {
    @Binding var locationClicked: Bool
    @Binding var cityName: String
    @Binding var cityModel: CityModel
    @ObservedObject var networkManager = NetworkManager()
    var cityList: [CityModel]
    
    var body: some View {
        List(cityList.filter {
            cityName.isEmpty ? true :
                $0.siteName.localizedCaseInsensitiveContains(cityName)
        }, id: \.id) { city in
            CityRow(city: city).onTapGesture {
                self.locationClicked = false
                self.cityName = ""
                self.cityModel = city
            }.opacity(1.0)
        }.onAppear(perform: { UITableView.appearance().separatorColor = .clear
        })
    }
}
