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
  //  @Binding var city: City
    @Binding var cityModel: CityModel
   // var cities = cities1
    @ObservedObject var networkManager = NetworkManager()
    var cityList: [CityModel]
    var body: some View {
        
//        List(cities.filter {
//            cityName.isEmpty ? true :
//                 $0.name.localizedCaseInsensitiveContains(cityName)
//            }, id: \.id) { city in
//                CityRow(city: city).onTapGesture {
//                    self.locationClicked = false
//                    self.cityName = ""
//                    self.city = city
//                }.opacity(1.0)
        List(cityList.filter {
                    cityName.isEmpty ? true :
                        $0.siteName.localizedCaseInsensitiveContains(cityName)
                    }, id: \.id) { city in
            CityRow(city: city).onTapGesture {
                                self.locationClicked = false
                                self.cityName = ""
                            //    self.city = city
                                self.cityModel = city
//                self.networkManager.fetchCityOverallValues(cityName: city.cityName)
//                self.cityOverallValues = self.networkManager.cityOverallValues
//                               
                            }.opacity(1.0)
            
        }.onAppear(perform: { UITableView.appearance().separatorColor = .clear
//            self.networkManager.fetchAllCities()
            })
       
    }
}

//struct CityList_Previews: PreviewProvider {
//    static var previews: some View {
//        CityList(locationClicked: .constant(true), cityName: .constant(""), city: .constant(City(id: 1, name: "name", coordinates: Coordinates(latitude: 2.0, longitude: 2.0), country: "country", description: "desscription")))
//    }
//}
