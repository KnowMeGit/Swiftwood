import XCTest
@testable import Swiftwood

/**
 These tests are those that (at least thus far) I have not devised a way (read 'easy way') to verify automatically (could probably redirect `stdout` to a file, read it in,
 regex parse, and confirm...). In the mean time, these tests largely serve as templates by which you can manually run them and verify that they perform as expected.
 */
final class ManualSwiftwoodTests: SwiftwoodTests {
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

		let password = CensoredPassword(rawValue: "shouldbeconditionallycensored")
		let key = CensoredKey(rawValue: "thisisalongkey")

		let numericalValue = 3
		log.info("a", numericalValue, password, key)

		// manual verification - should resemble
		/*
		 11/17/2022 14:54:33.345 💙 INFO SwiftwoodTests.swift testCensoring():152 - a 3 CensoredPassword: **CENSORED** ***key
		 11/17/2022 14:54:33.345 💙 INFO SwiftwoodTests.swift testCensoring():152 - a 3 shouldbeconditionallycensored thisisalongkey
		 */
	}

	func testCategoryFilteringNone() {
		let consoleDestination = ConsoleLogDestination(maxBytesDisplayed: -1)
		consoleDestination.logFilter = .none
		log.appendDestination(consoleDestination)

		log.info("fake doors!", category: .fakeDoors)
		log.info("real doors!", category: .realDoors)
		log.info("real fake doors!", category: .realFakeDoors)
		// manual verification - should resemble

		/*
		 12/10/2022 00:10:27.170 💙 INFO ManualSwiftwoodTests.swift testCategoryFilteringNone():102 - fake doors!
		 12/10/2022 00:10:27.172 💙 INFO ManualSwiftwoodTests.swift testCategoryFilteringNone():103 - real doors!
		 12/10/2022 00:10:27.172 💙 INFO ManualSwiftwoodTests.swift testCategoryFilteringNone():104 - real fake doors!
		 */
	}

	func testCategoryFilteringAllow() {
		let consoleDestination = ConsoleLogDestination(maxBytesDisplayed: -1)
		consoleDestination.logFilter = .allow([.realFakeDoors])
		log.appendDestination(consoleDestination)

		log.info("fake doors!", category: .fakeDoors)
		log.info("real doors!", category: .realDoors)
		log.info("real fake doors!", category: .realFakeDoors)

		// manual verification - should resemble
		/*
		 12/10/2022 00:10:27.172 💙 INFO ManualSwiftwoodTests.swift testCategoryFilteringNone():104 - real fake doors!
		 */
	}

	func testCategoryFilteringBlock() {
		let consoleDestination = ConsoleLogDestination(maxBytesDisplayed: -1)
		consoleDestination.logFilter = .block([.realFakeDoors])
		log.appendDestination(consoleDestination)

		log.info("fake doors!", category: .fakeDoors)
		log.info("real doors!", category: .realDoors)
		log.info("real fake doors!", category: .realFakeDoors)

		// manual verification - should resemble
		/*
		 12/10/2022 00:10:27.170 💙 INFO ManualSwiftwoodTests.swift testCategoryFilteringNone():102 - fake doors!
		 12/10/2022 00:10:27.172 💙 INFO ManualSwiftwoodTests.swift testCategoryFilteringNone():103 - real doors!
		 */
	}
}


fileprivate extension LogCategory {
	static let fakeDoors: LogCategory = "fakeDoors"
	static let realDoors: LogCategory = "realDoors"
	static let realFakeDoors: LogCategory = "realFakeDoors"
}
