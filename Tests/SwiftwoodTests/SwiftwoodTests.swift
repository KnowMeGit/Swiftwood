import XCTest
@testable import Swiftwood
typealias log = Swiftwood

/**
 Important note for anyone running tests is that they, by nature, many cannot really be automated. Some will need manual verification that what is logged will appear in
 the console (siphoned off into `ManualSwiftwoodTests`) Perhaps some test system will work someday, but that time is not now. 
 */
class SwiftwoodTests: XCTestCase {
	override func tearDown() {
		super.tearDown()

		log.clearDestinations()
		log.testingVerbosity = false
	}
}
