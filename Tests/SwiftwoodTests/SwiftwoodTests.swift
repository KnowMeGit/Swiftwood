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

		do {
			try FileManager.default.removeItem(at: logFolder())
		} catch where (error as NSError).code == 4 {
			// do nothing, this is fine
		} catch {
			print("Error removing log folder from test run: \(error)")
		}
	}

	func logFolder() throws -> URL {
		let cacheFolder = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		let logFolder = cacheFolder.appendingPathComponent("logs")
		return logFolder
	}
}
