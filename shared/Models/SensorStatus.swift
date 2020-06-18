import Foundation

enum SensorStatus: String, Codable {
    // The sensor is up and running properly
    case active = "ACTIVE"
    // The sensor is registered but turned off and ignored
    case inactive = "INACTIVE"
    // The sensor is registered, but so far not bound to an owner
    case notClaimed = "NOT_CLAIMED"
    // The sensor is manually removed from evidence in order to keep data sanity
    case banned = "BANNED"
    // A user requested this location with a device ID, but not sending data yet
    case requested = "REQUESTED"
    // The sensor is up and running properly but not yet confirmed by the community lead
    case activeUnconfirmed = "ACTIVE_UNCONFIRMED"
    // The sensor is registered, but so far not bound to an owner nor confirmed by the community lead
    case notClaimedUnconfirmed = "NOT_CLAIMED_UNCONFIRMED"
    // Used as a default value
    case unknown = "UNKNOWN"
    
}
