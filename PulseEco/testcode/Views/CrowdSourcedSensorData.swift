//
//  CrowdSourcedSensorData.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/1/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct CrowdSourcedSensorData: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack{
            HStack {
                Spacer()
                Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                               }
                ) {
                    Image(systemName: "star.fill")
                        .padding([.top, .trailing], 26.0)
                        .frame(width: 20.0, height: 22.0)
                }
         
            }
            Spacer()
            
                
            Image(systemName: "star.fill")
            Text("Disclaimer")
                .font(.title)
            Text("The data collected are not manipulated...")
            Spacer()
        }
       
    }
    
}

struct CrowdSourcedSensorData_Previews: PreviewProvider {
    static var previews: some View {
        CrowdSourcedSensorData()
    }
}
