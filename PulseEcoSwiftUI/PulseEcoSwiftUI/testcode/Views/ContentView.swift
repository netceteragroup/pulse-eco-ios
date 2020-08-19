//
//  ContentView.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 5/28/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//
//import MapKit
//import SwiftUI
//import Combine
//let UIWidthScreen = UIScreen.main.bounds.width
//
//struct ContentView: View {
//
//    @Environment(\.managedObjectContext) var moc
//    var list = ["PM10", "PM25", "Noise", "Temperture", "Humidity", "Pressure", "NO2", "O3"]
//    @State private var index: Int = 0
//    @State private var selectedItem: String = "PM10"
//    @State private var showDisclaimerView = false
//    @State private var locaitonClicked = false
//    @State var cityName: String = ""
//    @State var city: City = cities1[1]
//    @State var cityModel = CityModel(cityName: "skopje", siteName: "Skopje", siteTitle: "Skopje @ CityPulse", siteURL: "https://skopje.pulse.eco", countryCode: "MK", countryName: "Macedonia", cityLocation: CityCoordinates(latitude: "42.0016", longitute: "21.4302"), cityBorderPoints :[], intialZoomLevel: 12)
//
//    @State var showDetailedView = false
//    @ObservedObject var networkManager = NetworkManager()
//    @State var sensorValues = [String]()
//    var cityList = CityListViewModel()
//    @ObservedObject var measures = MeasureViewModel()
//
//    var body: some View {
//        ZStack(alignment: .top) {
//            NavigationView {
//                VStack {
//                    ScrollView (.horizontal, showsIndicators: false) {
//                        HStack {
//                            ForEach(measures.measures, id: \.id) { item in
//
//                                VStack {
//
//                                    HeaderTabButton(title: item.buttonTitle, selectedItem: self.$selectedItem)
//
//
//                                }
//
//
//                            }
//                        }
//
//                        }.background(Color.white.shadow(color: Color.gray, radius: 5, x: 0, y: 0))
//
//
//
//                    ZStack {
//
//                        VStack {
//
//                            MapView(coordinate: cityModel.cityLocation, cityModel: cityModel, showDetails: self.$showDetailedView, sensors: [SensorModel](), networkManager: self.networkManager, sensorValues: self.$sensorValues)
//                                .edgesIgnoringSafeArea(.all)
//
//
//                        }
//
//                        VStack(alignment: .trailing) {
//                            Spacer()
//                            HStack {
//                                Spacer()
//
//                                RoundedRectangle(cornerRadius: 5, style: .continuous)
//                                    .fill(Color(UIColor.lightGray))
//                                    .frame(width: 220, height: 25)
//                                    .overlay(Text("Crowdsourced sensor data")
//                                        .foregroundColor(Color.white)
//                                )
//                                    .padding(.bottom, 35)
//                                    .onTapGesture {
//                                        self.showDisclaimerView.toggle()
//                                }
//
//                            }.padding(.trailing, 15)
//
//                        }
//                        AverageView(cityModel: self.$cityModel, cityOverallValues: self.$networkManager.cityOverallValues)
//                        VStack {
//                            if locaitonClicked == true {
//                                CityList(locationClicked: self.$locaitonClicked, cityName: self.$cityName, cityModel: self.$cityModel, cityList: self.cityList.cityList).opacity(0.9)
//                            }
//                        }
//                        if showDetailedView == true {
//                            SensorDetailedView()
//                        }
//                    }
//                }
//                .navigationBarTitle("", displayMode: .inline)
//                .navigationBarItems(leading: Button(action: {
//                    self.locaitonClicked = true
//
//                }) {
//
//                    Text(self.locaitonClicked ? "" : cityModel.siteName)
//                        .bold().onAppear{
//                            self.networkManager.fetchCityOverallValues(cityName: self.cityModel.cityName)
//
//                    }
//
//
//                }.accentColor(Color.black), trailing: Image(uiImage: UIImage(named: "logo-pulse")!).imageScale(.large).padding(.trailing, (UIWidthScreen)/2.6).onTapGesture {
//                    //action
//                    }
//                )
//                    .sheet(isPresented: $showDisclaimerView) {
//                        CrowdSourcedSensorData().environment(\.managedObjectContext, self.moc)
//                }
//
//            }
//            ZStack {
//                if self.locaitonClicked {
//                    SearchView(cityName: self.$cityName).padding(.top, 0)
//                }
//            }
//        }
//
//
//    }
//
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
////
////
//////                                            Button(action: {
////                                          self.index = self.list.firstIndex(of: item)!
////                                      }) {
////                                          Text("\(item)")
////
////      //                                        .underline(self.index == self.list.firstIndex(of: item), color: Color.purple)
////
////                                      }
////                                          .accentColor(Color.black)
////                                          .padding([.top, .leading, .trailing], 10)
////
////                                         // if self.index == self.list.firstIndex(of: item) {
////                                              Rectangle()
////                                                .frame(height: 3.0, alignment: .bottom)
////                                                  .foregroundColor(self.index == self.list.firstIndex(of: item) ? Color.purple : Color.white)
////
////                                         // }
////
