import XCTest
@testable import pulse_eco

class UserDefaultsPropertyWrapperTests: XCTestCase {

    @UserDefaultCoded("testsCodedCity") var codedCity: City?
    @UserDefaultCoded("testMeasureValue") var codedMeasureValue: MeasureValue?
    @UserDefaultCoded("testMeasureValues") var codedMeasureValues: [MeasureValue]?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCodedCity() {
        // given
        let city = City.defaultCity()
        
        // when
        codedCity = city
        let savedCodedCity = codedCity
        
        // then
        XCTAssertNotNil(savedCodedCity)
    }
    
    func testCodedMeasureValue() {
        // given
        let measureValue = MeasureValue.empty()
        
        // when
        codedMeasureValue = measureValue
        let savedMeasureValue = codedMeasureValue
        
        // then
        XCTAssertNotNil(savedMeasureValue)
    }
    
    func testCodedMeasureValues() {
        // given
        let measureValues = MeasureValue.emptyArray()
        
        // when
        codedMeasureValues = measureValues
        let savedMeasureValues = codedMeasureValues
        
        // then
        XCTAssertNotNil(savedMeasureValues)
    }
}
