//
//  HeaderTabButton.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/4/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI



struct HeaderTabButton: View {
  
    var title: String
    @Binding var selectedItem: String

    var isSelected: Bool {
        selectedItem == title
    }

    var body: some View {
        VStack {
            
            Button(action: { self.selectedItem = self.title }) {
                Text(title).accentColor(Color.black)
                .padding([.top, .leading, .trailing], 10)
                      
            }
                Rectangle()
                    .frame(height: 3.0, alignment: .bottom)
                .foregroundColor(isSelected ? Color.purple : Color.white)
                        

            
        }
    }
}

struct HeaderTabButton_Previews: PreviewProvider {
    static var previews: some View {
        HeaderTabButton(title: "PM10", selectedItem: .constant("PM10"))
    }
}
