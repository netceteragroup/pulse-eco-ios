// swiftlint:disable all
import Foundation
import CoreLocation
import UIKit

enum SensorType: String, Codable {
    // MOEPP measurement station
    case MOEPP = "0"
    // SkopjePulse LoRaWAN based sensor, version 1
    case LoRaWAN = "1"
    // SkopjePulse WiFi based sensor, version 1
    case Wifi = "2"
    // Pulse.eco WiFi based sensor, version 2
    case WifiV2 = "3"
    // Pulse.eco LoRaWAN based sensor. version 2
    case LoRaWANV2 = "4"
    case Pengy = "20001"
    // URAD Monitor device
    case URAD = "20002"
    // AirThings platform device
    case AirThings = "20003"
    // Sensor.community crowdsourced device
    case CommunitySensor = "20004"
    // Used as a default value
    case undefined = "-1"
}

extension SensorType {
    public var imageForType: UIImage? {
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
        default: return UIImage(named: "wifiTypeIcon")
        }
    }
}
