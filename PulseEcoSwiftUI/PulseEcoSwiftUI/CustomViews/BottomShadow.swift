//
//  BottomShadow.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 7/23/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct BottomShadow: View {
    var body: some View {
       Rectangle()
           .stroke(Color(red: 236/255, green: 234/255, blue: 235/255), lineWidth: 3)
           .shadow(color: Color(red: 192/255, green: 189/255, blue: 191/255), radius: 3, x: 0, y: 5)
           .clipShape(
               Rectangle()
       )
           .shadow(color: Color.white, radius: 2, x: -2, y: -2)
           .clipShape(
               Rectangle()
       )
    }
}

