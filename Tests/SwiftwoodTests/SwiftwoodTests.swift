import XCTest
@testable import Swiftwood
typealias log = Swiftwood

final class SwiftwoodTests: XCTestCase {
	override func tearDown() {
		super.tearDown()

		log.clearDestinations()
	}

    func testLogging() throws {

		let consoleDestination = ConsoleLogDestination(maxBytesDisplayed: -1)
		consoleDestination.minimumLogLevel = .veryVerbose
		log.appendDestination(consoleDestination)
		log.appendDestination(try FilesDestination(
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

	func testDestinationAdditionsForfeit() {
		let consoleDestinationA = ConsoleLogDestination(maxBytesDisplayed: -1)
		let consoleDestinationB = ConsoleLogDestination(maxBytesDisplayed: -1)

		log.appendDestination(consoleDestinationA)
		log.appendDestination(consoleDestinationB, replicationOption: .forfeitToAlike)

		XCTAssertTrue(log.destinations.contains(where: { $0 === consoleDestinationA }))
		XCTAssertFalse(log.destinations.contains(where: { $0 === consoleDestinationB }))
		XCTAssertEqual(log.destinations.count, 1)
	}

	func testDestinationAdditionsReplace() {
		let consoleDestinationA = ConsoleLogDestination(maxBytesDisplayed: -1)
		let consoleDestinationB = ConsoleLogDestination(maxBytesDisplayed: -1)

		log.appendDestination(consoleDestinationA)
		log.appendDestination(consoleDestinationB, replicationOption: .replaceAlike)

		XCTAssertFalse(log.destinations.contains(where: { $0 === consoleDestinationA }))
		XCTAssertTrue(log.destinations.contains(where: { $0 === consoleDestinationB }))
		XCTAssertEqual(log.destinations.count, 1)
	}

	func testDestinationAdditionsAppend() {
		let consoleDestinationA = ConsoleLogDestination(maxBytesDisplayed: -1)
		let consoleDestinationB = ConsoleLogDestination(maxBytesDisplayed: -1)

		log.appendDestination(consoleDestinationA)
		log.appendDestination(consoleDestinationB, replicationOption: .appendAlike)

		XCTAssertTrue(log.destinations.contains(where: { $0 === consoleDestinationA }))
		XCTAssertTrue(log.destinations.contains(where: { $0 === consoleDestinationB }))
		XCTAssertEqual(log.destinations.count, 2)
	}
}
