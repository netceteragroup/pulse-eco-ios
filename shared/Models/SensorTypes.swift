import Foundation
import CoreLocation
import UIKit

enum SensorType: String, Codable {
	case MOEPP = "0"
	case LoRaWAN = "1"
	case Wifi = "2"
	case WifiV2 = "3"
	case undefined = "-1"
    case Pengy = "20001"
}

extension SensorType {
	public var imageForType: UIImage? {
        #warning("Use appropriate image for Pengy")
		switch self {
		case .MOEPP: return UIImage(named: "moeppTypeIcon")
		case .LoRaWAN: return UIImage(named: "loraTypeIcon")
		case .Wifi: return UIImage(named: "wifiTypeIcon")
		case .WifiV2: return UIImage(named: "wifiTypeIcon")
        case .Pengy: return UIImage(named: "moeppTypeIcon") 
		default: return nil
		}
	}
}
