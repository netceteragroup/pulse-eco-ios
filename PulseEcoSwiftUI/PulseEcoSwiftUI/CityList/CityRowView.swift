
import Foundation
import SwiftUI

struct CityRowView: View {
    
    var viewModel: CityRowViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                //                Image(systemName: "pin")
                Image(uiImage: UIImage(named: "whitepin") ?? UIImage()).resizable()
                    .frame(width: 20, height: 25)
                    .foregroundColor(Color.white)
                
                //.scaledToFit()
                VStack(alignment: .leading) {
                    Text("\(self.viewModel.siteName)").foregroundColor(Color.white)
                    Text("\(self.viewModel.countryName)").font(.system(size: 12)).foregroundColor(Color.blue)
                }
                Spacer()
            }
            Divider()
                .background(Color.gray)
        }
        .frame(height: 60)
        .padding(.horizontal, 10)
        .contentShape(Rectangle())
    }
}
