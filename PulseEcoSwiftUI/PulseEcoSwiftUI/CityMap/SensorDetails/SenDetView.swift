//
//  SenDetView.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 1/28/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import SwiftUI

struct SenDetView: View {
    @State var isExpanded: Bool = false
    @EnvironmentObject var appVM: AppVM
    @State var collapsedViewSize: CGSize = .zero
    @State var expandedViewSize: CGSize = .zero
    @EnvironmentObject var dataSource: DataSource
    @EnvironmentObject var partialSheet : PartialSheetManager
    @State var isSheetShown: PartialSheetState = .hidden
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: CGFloat(5.0) / 2.0)
                .frame(width: 40, height: 3.0)
                .foregroundColor(Color(UIColor.systemGray2)).padding(.top, 10)
            
            
            ChildSizeReader(size: self.$collapsedViewSize) {
                
                CollapsedView(viewModel: SensorDetailsVM(sensor: self.appVM.selectedSensor ?? SensorVM(), sensorsData: self.dataSource.sensorsData24h, selectedMeasure: self.dataSource.getCurrentMeasure(selectedMeasure: self.appVM.selectedMeasure))).padding(.top, 5)
                    .padding(.bottom, 40)
                    .partialSheet(isPresented: self.$isSheetShown) {
                        SensorDView(viewModel: ExpandedVM(sensorData24h: self.dataSource.sensorsData24h)).padding(.bottom, 30)
                }
                
            }
        }.background(RoundedCorners(tl: 40, tr: 40, bl: 0, br: 0).fill(Color.white))
            .offset(y: self.isExpanded ? UIHeight/2 - (self.expandedViewSize.height) + self.collapsedViewSize.height/2 : UIHeight/2 - (self.collapsedViewSize.height))
            .animation(.easeIn)
            .transition(.slide)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.height < -50 {
                            self.isSheetShown = .expanded
                            //self.isExpanded = true
                        } else if value.translation.height < 30 {
                            //self.isExpanded = false
                            self.isSheetShown = .partial
                            
                        }else{
                            //self.isExpanded = false
                            self.isSheetShown = .hidden
                        }
                }
        )
    }
}

