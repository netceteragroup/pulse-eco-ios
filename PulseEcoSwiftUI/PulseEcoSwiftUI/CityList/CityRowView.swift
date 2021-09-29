
import Foundation
import SwiftUI

struct CityRowView: View {
    
    var viewModel: CityRowViewModel
    var addCheckMark: Bool
    var showCountryName: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(self.viewModel.siteName).foregroundColor(Color.black)
                    if (showCountryName) {
                        Text(self.viewModel.countryName).font(.system(size: 12)).foregroundColor(Color(AppColors.gray))
                    }
                }
                .padding(.leading, 10)
                Spacer()
                if (addCheckMark){
                    Image(systemName: "checkmark")
                        .foregroundColor(.black)
                        .padding(.trailing, 10)
                }
            }
            
        }
        .frame(height: 60)
        .padding(.horizontal, 10)
        .contentShape(Rectangle())
        .resignKeyboardOnDragGesture()
    }
}
