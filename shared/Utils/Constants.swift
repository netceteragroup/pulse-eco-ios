import UIKit

#warning("These values should be put where they belong")

let selectedCityKey = "selectedCity"
let noInternetMessage = "No Internet connection available"
let maxSensorMessage = "You can add up to 5 sensors"
let privacyPolicyLink = "https://www.netcetera.com/home/privacy-policy.html"

let restCityUrl = "https://pulse.eco/rest/city"
let skopjeCityKey = "skopje"

let twoHourInterval = 120 * 60.0
let animationDuration = 0.2

let freshDataThreshold = 900.0 //15 minutes

// Persistence
let citiesPlistKey = "cities"

// Average view
let averageViewCollapsedHeight: CGFloat = 65
let averageViewExpandedHeight: CGFloat = 95
let minRightSpacing: CGFloat = 25
let minLeftSpacing: CGFloat = 13

// Drawer
let openedDrawerConstraintNoChart: CGFloat = -320

// Sensors
let maxFavoriteSensors = 5


