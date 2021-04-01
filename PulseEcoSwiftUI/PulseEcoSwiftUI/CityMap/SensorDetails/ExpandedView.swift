import SwiftUI

struct ExpandedView: View {
    @State var offset = UIHeight / 3
    @EnvironmentObject var appVM: AppVM
    @EnvironmentObject var dataSource: DataSource
    @ObservedObject var viewModel: ExpandedVM
    var body: some View {
       
            VStack {
                //Rectangle().frame(width: 400,height: 200)
                
                LineChartSwiftUI(viewModel:
                    ChartVM(sensor: self.appVM.selectedSensor ?? SensorVM(), sensorsData: self.dataSource.sensorsData24h, selectedMeasure: self.dataSource.getCurrentMeasure(selectedMeasure: self.appVM.selectedMeasure)
                    )
                ).frame(width: 350,height: 200)
                
                Text(self.viewModel.disclaimerMessage)
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(self.viewModel.color)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20).fixedSize(horizontal: false, vertical: true)
                HStack {
                    Text(Trema.text(for: "details",
                                    language: UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"))
                        .font(.system(size: 13, weight: .medium))
                    Text("|")
                        .font(.system(size: 13, weight: .medium))
                    Text(Trema.text(for: "privacy_policy",
                    language: UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"))
                        .font(.system(size: 13, weight: .medium))
                }.foregroundColor(self.viewModel.color).padding(.top, 10)
                Spacer().frame(height: 40).padding(.bottom, 30)
        }
    }
}
