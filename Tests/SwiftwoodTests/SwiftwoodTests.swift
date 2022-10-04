import XCTest
@testable import Swiftwood

final class SwiftwoodTests: XCTestCase {
    func testLogging() throws {
		typealias log = Swiftwood

		log.destinations.append(ConsoleLogDestination(maxBytesDisplayed: 1024))
		log.destinations.append(try FilesDestination(
			logFolder: nil,
			ageBeforeCulling: nil))

		log.warning("test warning")
		log.error("Test error")
    }
}
