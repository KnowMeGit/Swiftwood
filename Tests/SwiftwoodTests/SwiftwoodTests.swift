import XCTest
@testable import Swiftwood

final class SwiftwoodTests: XCTestCase {
    func testLogging() throws {
		typealias log = Swiftwood

		let consoleDestination = ConsoleLogDestination(maxBytesDisplayed: -1)
		consoleDestination.minimumLogLevel = .veryVerbose
		log.destinations.append(consoleDestination)
		log.destinations.append(try FilesDestination(
			logFolder: nil,
			fileformat: .formattedString
		))

		log.veryVerbose("Don't even worry")
		log.verbose("Something small happened")
		log.debug("Some minor update")
		log.info("Look at me")
		log.warning("uh oh")
		log.error("Failed successfully")
    }
}
