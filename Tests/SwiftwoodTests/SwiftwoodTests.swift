import XCTest
@testable import Swiftwood
typealias log = Swiftwood

/**
 Important note for anyone running tests is that they, by nature, many cannot really be automated. Most will need manual verification that what is logged will appear in
 the console. Perhaps some test system will work someday, but that time is not now. In the mean time, these tests largely serve as templates by which you can manually
 run them and verify that it performs as expected. (those with some variant of `XCTAssert` should be fine to just trust the result)
 */
final class SwiftwoodTests: XCTestCase {
	override func tearDown() {
		super.tearDown()

		log.clearDestinations()
		log.testingVerbosity = false
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

		// manual verification - should resemble
		/*
		 11/17/2022 12:34:34.255 🤎 VERY VERBOSE SwiftwoodTests.swift testLogging():27 - Don't even worry
		 11/17/2022 12:34:34.258 💜 VERBOSE SwiftwoodTests.swift testLogging():28 - Something small happened
		 11/17/2022 12:34:34.261 💚 DEBUG SwiftwoodTests.swift testLogging():29 - Some minor update
		 11/17/2022 12:34:34.263 💙 INFO SwiftwoodTests.swift testLogging():30 - Look at me
		 11/17/2022 12:34:34.265 💛 WARNING SwiftwoodTests.swift testLogging():31 - uh oh
		 11/17/2022 12:34:34.267 ❤️ ERROR SwiftwoodTests.swift testLogging():32 - Failed successfully
		 */
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

	func testBuildInfo() {
		log.testingVerbosity = true
		let consoleDestination = ConsoleLogDestination(maxBytesDisplayed: -1)
		consoleDestination.format.parts.append(.staticText(" -- build: "))
		consoleDestination.format.parts.append(.buildInfo)

		log.appendDestination(consoleDestination)

		log.info("testttt")
		log.info("should be cached")

		log.buildInfoGenerator = {
			print("generated nil")
			return nil
		}

		log.info("should be nil")
		log.info("should be cached")

		log.buildInfoGenerator = {
			print("generated toot")
			return "toot"
		}
		log.info("should be toot")
		log.info("should be cached")

		// manual verification - should resemble
		/*
		 11/17/2022 12:33:32.347 💙 INFO SwiftwoodTests.swift testBuildInfo():79 - testttt -- build: 21501
		 cache hit
		 11/17/2022 12:33:32.348 💙 INFO SwiftwoodTests.swift testBuildInfo():80 - should be cached -- build: 21501
		 generated nil
		 11/17/2022 12:33:32.348 💙 INFO SwiftwoodTests.swift testBuildInfo():87 - should be nil -- build: nil
		 cache hit
		 11/17/2022 12:33:32.348 💙 INFO SwiftwoodTests.swift testBuildInfo():88 - should be cached -- build: nil
		 generated toot
		 11/17/2022 12:33:32.348 💙 INFO SwiftwoodTests.swift testBuildInfo():94 - should be toot -- build: toot
		 cache hit
		 11/17/2022 12:33:32.348 💙 INFO SwiftwoodTests.swift testBuildInfo():95 - should be cached -- build: toot
		 */
	}

	func testCensoring() {
		let censoredConsoleDestination = ConsoleLogDestination(maxBytesDisplayed: -1, shouldCensor: true)
		let unCensoredConsoleDestination = ConsoleLogDestination(maxBytesDisplayed: -1, shouldCensor: false)
		log.appendDestination(censoredConsoleDestination)
		log.appendDestination(unCensoredConsoleDestination, replicationOption: .appendAlike)

		struct Password: CensoredLogItem, RawRepresentable, CustomStringConvertible {
			let rawValue: String

			var description: String { rawValue }
		}

		struct Key: CensoredLogItem, RawRepresentable, CustomStringConvertible {
			let rawValue: String

			var description: String { rawValue }
			var censoredDescription: String {
				guard
					rawValue.count > 10,
					let start = rawValue.index(rawValue.endIndex, offsetBy: -3, limitedBy: rawValue.startIndex)
				else { return "***" }
				return "***" + String(rawValue[start..<rawValue.endIndex])
			}
		}

		let password = Password(rawValue: "shouldbeconditionallycensored")
		let key = Key(rawValue: "thisisalongkey")

		let numericalValue = 3
		log.info("a", numericalValue, password, key)

		// manual verification - should resemble
		/*
		 11/17/2022 14:54:33.345 💙 INFO SwiftwoodTests.swift testCensoring():152 - a 3 Password: **CENSORED** ***key
		 11/17/2022 14:54:33.345 💙 INFO SwiftwoodTests.swift testCensoring():152 - a 3 shouldbeconditionallycensored thisisalongkey
		 */
	}
}
