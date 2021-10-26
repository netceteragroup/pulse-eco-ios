//
//  BottomShadow.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 7/23/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct ShadowOnTopOfView: View {
    var body: some View {
       Rectangle()
           .stroke(Color(red: 192/255, green: 189/255, blue: 191/255), lineWidth: 1)
           .shadow(color: Color(red: 192/255, green: 189/255, blue: 191/255), radius: 3, x: 0, y: 3)
    }
}

struct ShadowOnBottomOfView: View {
    var body: some View {
        Rectangle()
            .stroke(Color(red: 192/255, green: 189/255, blue: 191/255), lineWidth: 1)
            .shadow(color: Color(red: 192/255, green: 189/255, blue: 191/255), radius: 3, x: 0, y: -3)
    }
}
