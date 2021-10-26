//
//  TabView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/4/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI

let UIWidth = UIScreen.main.bounds.width
let UIHeight = UIScreen.main.bounds.height

struct SearchView: View {
    @State var showField: Bool = false
    @Binding var cityName: String
    @State var endEditing: Bool = true
    var body: some View {
        ZStack {
            ZStack(alignment: .leading) {
                
                TextField("Enter City Name", text: self.$cityName) {
                    self.searchCity()
                    }.padding(.all, 10)
                    .frame(width: UIWidth - 50, height: 40)
                    .background(Color.white)
                    .cornerRadius(30)
                    .foregroundColor(.black)
                    .offset(x: self.showField ? 0 : (-UIWidth / 2 - 180))
                    .animation(.spring())
                
                Image(systemName: "magnifyingglass.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.purple)
                    .offset(x: self.showField ? (UIWidth - 85) : 0)
                    .animation(.spring())
                    .onTapGesture {
                        self.showField.toggle()
                        
                }.onTapGesture {
                    self.endEditing.toggle()
                }
            }
        }
    }
    func searchCity(){
        
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(cityName: .constant("Skopje"))
    }
}
