import XCTest
@testable import pulse_eco

class SensorDataTests: XCTestCase {
    
    func testCorrectSensorDataDecoding() {
        // Given
        let jsonString = "{\"sensorId\":\"1002\",\"position\":\"41.9875,21.6525\",\"comments\":\"MOEPP sensor at Miladinovci\",\"type\":\"4\",\"description\":\"MOEPP Miladinovci\",\"status\":\"ACTIVE_UNCONFIRMED\"}"
        let data = jsonString.data(using: .utf8)!
        
        // When
        let response = try? JSONDecoder().decode(Sensor.self, from: data)
        
        // Then
        XCTAssert(response != nil)
        XCTAssert(response!.status == .activeUnconfirmed)
        XCTAssert(response!.type == .LoRaWANV2)
    }
    
    func testIncorrectSensorDataDecoding() {
        // Given
        let jsonString = "{\"sensorId\":\"1002\",\"position\":\"41.9875,21.6525\",\"comments\":\"MOEPP sensor at Miladinovci\",\"type\":\"6\",\"description\":\"MOEPP Miladinovci\",\"status\":\"ACTIVE_CONFIRMED\"}"
        let data = jsonString.data(using: .utf8)!
        
        // When
        let response = try? JSONDecoder().decode(Sensor.self, from: data)
        
        // Then
        XCTAssert(response != nil)
        XCTAssert(response!.status == .unknown)
        XCTAssert(response!.type == .undefined)
    }
    
}
