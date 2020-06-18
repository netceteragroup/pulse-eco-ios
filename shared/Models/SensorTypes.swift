import Foundation
import CoreLocation
import UIKit

enum SensorType: String, Codable {
    case MOEPP = "0"
    case LoRaWAN = "1"
    case Wifi = "2"
    case WifiV2 = "3"
    //pulse.eco LoRaWAN based sensor. version 2
    case LoRaWANV2 = "4"
    case undefined = "-1"
    case Pengy = "20001"
    //URAD Monitor device
    case URAD = "20002"
    //AirThings platform device
    case AirThings = "20003"
    //sensor.community crowdsourced device
    case CommunitySensor = "20004"
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
        case .LoRaWANV2: return UIImage(named: "loraTypeIcon")
        case .URAD: return UIImage(named: "wifiTypeIcon")
        case .AirThings: return UIImage(named: "wifiTypeIcon")
        case .CommunitySensor: return UIImage(named: "wifiTypeIcon")
        default: return nil
        }
    }
}
