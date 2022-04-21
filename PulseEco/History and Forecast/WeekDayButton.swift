//
//  WeekDayButton.swift
//  PulseEco
//
//  Created by Sara Karachanakova on 20.4.22.
//  Copyright © 2022 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct WeekDayButton: View {
    
    var body: some View {
        Button {
            
        } label: {
            VStack(spacing: 3) {
                Text("Mon")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(AppColors.black))
                
                Text("52")
                    .font(.system(size: 10, weight: .regular))
                    .frame(width: 34, height: 12, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color(AppColors.orange)))
                
            }
            .frame(width: 50, height: 50)
            .foregroundColor(Color(AppColors.white))
            .background(Color(AppColors.white))
            .cornerRadius(3)
        }
        
        Button {
            
        } label: {
            VStack(spacing: 3) {
                Text("Tue")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(AppColors.black))
                
                Text("30")
                    .font(.system(size: 10, weight: .regular))
                    .frame(width: 34, height: 12, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color(AppColors.green)))
                
            }
            .frame(width: 50, height: 50)
            .foregroundColor(Color(AppColors.white))
            .background(Color(AppColors.white))
            .cornerRadius(3)
        }
        Button {
            
        } label: {
            VStack(spacing: 3) {
                Text("Wed")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(AppColors.black))
                
                Text("82")
                    .font(.system(size: 10, weight: .regular))
                    .frame(width: 34, height: 12, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color(AppColors.red)))
                
            }
            .frame(width: 50, height: 50)
            .foregroundColor(Color(AppColors.white))
            .background(Color(AppColors.white))
            .cornerRadius(3)
        }
        Button {
            
        } label: {
            VStack(spacing: 3) {
                Text("Thu")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(AppColors.black))
                
                Text("50")
                    .font(.system(size: 10, weight: .regular))
                    .frame(width: 34, height: 12, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color(AppColors.orange)))
                
            }
            .frame(width: 50, height: 50)
            .foregroundColor(Color(AppColors.white))
            .background(Color(AppColors.white))
            .cornerRadius(3)
        }
        Button {
            
        } label: {
            VStack(spacing: 3) {
                Text("Today")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(AppColors.black))
                
                Text("22")
                    .font(.system(size: 10, weight: .regular))
                    .frame(width: 34, height: 12, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color(AppColors.green)))
                
            }
            .frame(width: 50, height: 50)
            .foregroundColor(Color(AppColors.white))
            .background(Color(AppColors.white))
            .cornerRadius(3)
        }
        Button {
            
        } label: {
            VStack(spacing: 3) {
                Text("Thu")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(AppColors.black))
                
                Text("50")
                    .font(.system(size: 10, weight: .regular))
                    .frame(width: 34, height: 12, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color(AppColors.orange)))
                
            }
            .frame(width: 50, height: 50)
            .foregroundColor(Color(AppColors.white))
            .background(Color(AppColors.white))
            .cornerRadius(3)
        }
    }
}
