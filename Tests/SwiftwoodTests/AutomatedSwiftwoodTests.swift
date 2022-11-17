import XCTest
@testable import Swiftwood

/// These tests should correctly work with automation.
final class AutomatedSwiftwoodTests: SwiftwoodTests {
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
