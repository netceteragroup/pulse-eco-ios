//
//  CityRow.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/3/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI
import CoreLocation


struct City: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var coordinates: Coordinates
    var country: String
    var description: String
    
    
    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude)
    }
    init(id: Int, name: String, coordinates: Coordinates, country: String, description: String) {
        self.id = id
        self.name = name
        self.coordinates = coordinates
        self.country = country
        self.description = description
    }
    
}

struct Coordinates: Hashable, Codable {
    var latitude: Double
    var longitude: Double
}


struct CityRow: View {
    
    var city: CityModel
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading){
                    Text(city.siteName).font(.headline)
                    Text(city.countryName).padding(.top, 2)
                    Text(city.siteTitle).padding(.top, 2)
                }
                Spacer()
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(UIColor.systemGreen))
                    .frame(width: 80, height: 80)
                    .overlay(Text("2"))
                    .foregroundColor(Color.white)
                    .padding(10)
                
            }
            .padding([.leading, .top, .trailing], 10)
            .frame(height: 90)
            Divider()

        }
        
    }
}

//struct CityRow_Previews: PreviewProvider {
//    static var previews: some View {
//        CityRow(city: CityModel(id: 1, name: "name", coordinates: Coordinates(latitude: 2.0, longitude: 2.0), country: "country", description: "desscription"))
//
//    }
//}
