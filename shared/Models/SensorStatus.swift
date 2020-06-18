import Foundation

enum SensorStatus: String, Codable {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
    case notClaimed = "NOT_CLAIMED"
    case banned = "BANNED"
    //A user requested this location with a device ID, but not sending data yet
    case requested = "REQUESTED"
    //The sensor is up and running properly but not yet confirmed by the community lead
    case activeUnconfirmed = "ACTIVE_UNCONFIRMED"
    //The sensor is registered, but so far not bound to an owner nor confirmed by the community lead
    case notClaimedUnconfirmed = "NOT_CLAIMED_UNCONFIRMED"
    case unknown = "UNKNOWN"
   
}
