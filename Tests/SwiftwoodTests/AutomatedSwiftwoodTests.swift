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

	func testFileDestination() throws {
		let logFolder = try logFolder()
		let fileDestination = try FilesDestination(logFolder: logFolder, fileformat: .formattedString, minimumLogLevel: .info)
		let consoleDestination = ConsoleLogDestination(maxBytesDisplayed: -1)
		consoleDestination.minimumLogLevel = .verbose

		log.appendDestination(fileDestination)
		log.appendDestination(consoleDestination)

		var logContent: [URL] = []
		logContent = try FileManager.default.contentsOfDirectory(at: logFolder, includingPropertiesForKeys: nil)
		XCTAssertTrue(logContent.isEmpty)

		let message = "test file destination"
		log.info(message)
		logContent = try FileManager.default.contentsOfDirectory(at: logFolder, includingPropertiesForKeys: nil)
		XCTAssertEqual(1, logContent.count)

		let consoleOnly = "test console destination"
		log.verbose(consoleOnly)
		log.debug(consoleOnly)
		logContent = try FileManager.default.contentsOfDirectory(at: logFolder, includingPropertiesForKeys: nil)
		XCTAssertEqual(1, logContent.count)
	}

	func testFileDestinationFormattedString() throws {
		let logFolder = try logFolder()
		let fileDestination = try FilesDestination(logFolder: logFolder, fileformat: .formattedString, minimumLogLevel: .info)
		let consoleDestination = ConsoleLogDestination(maxBytesDisplayed: -1)

		log.appendDestination(fileDestination)
		log.appendDestination(consoleDestination)

		var logContent: [URL] = []

		let message = "test file destination"
		log.info(message)
		logContent = try FileManager.default.contentsOfDirectory(at: logFolder, includingPropertiesForKeys: nil)
		XCTAssertEqual(1, logContent.count)

		let logFileURL = logContent[0]
		let logFileData = try Data(contentsOf: logFileURL)

		let logFile = try XCTUnwrap(String(data: logFileData, encoding: .utf8))
		XCTAssertTrue(logFile.contains(message))
		XCTAssertTrue(logFile.contains("💙 INFO AutomatedSwiftwoodTests.swift testFileDestinationFormattedString()"))
	}

	func testFileDestinationJSON() throws {
		let logFolder = try logFolder()
		let fileDestination = try FilesDestination(logFolder: logFolder, fileformat: .json, minimumLogLevel: .info)
		let consoleDestination = ConsoleLogDestination(maxBytesDisplayed: -1)

		log.appendDestination(fileDestination)
		log.appendDestination(consoleDestination)

		var logContent: [URL] = []

		let message = "test file destination"
		log.info(message)
		logContent = try FileManager.default.contentsOfDirectory(at: logFolder, includingPropertiesForKeys: nil)
		XCTAssertEqual(1, logContent.count)

		let logFileURL = logContent[0]
		let logFileData = try Data(contentsOf: logFileURL)

		let logFile = try JSONDecoder().decode(CodableLogEntry.self, from: logFileData)
		XCTAssertEqual(message, logFile.message.first)
		XCTAssertEqual(Swiftwood.Level.info.level, logFile.logLevel)
	}

	func testFileDestinationCensored() throws {
		let logFolder = try logFolder()
		let fileDestination = try FilesDestination(logFolder: logFolder, shouldCensor: true)
		let consoleDestination = ConsoleLogDestination(maxBytesDisplayed: -1)

		log.appendDestination(fileDestination)
		log.appendDestination(consoleDestination)

		var logContent: [URL] = []

		let message = "test file destination"
		let password = CensoredPassword(rawValue: "password!1234")
		log.info(message, password)
		logContent = try FileManager.default.contentsOfDirectory(at: logFolder, includingPropertiesForKeys: nil)
		XCTAssertEqual(1, logContent.count)

		let logFileURL = logContent[0]
		let logFileData = try Data(contentsOf: logFileURL)

		let logFile = try JSONDecoder().decode(CodableLogEntry.self, from: logFileData)
		XCTAssertEqual(message, logFile.message.first)
		XCTAssertEqual(password.censoredDescription, logFile.message.last)
		XCTAssertNotEqual(password.rawValue, logFile.message.last)
		XCTAssertEqual(Swiftwood.Level.info.level, logFile.logLevel)
	}

	func testFileDestinationUncensored() throws {
		let logFolder = try logFolder()
		let fileDestination = try FilesDestination(logFolder: logFolder, shouldCensor: false)
		let consoleDestination = ConsoleLogDestination(maxBytesDisplayed: -1)

		log.appendDestination(fileDestination)
		log.appendDestination(consoleDestination)

		var logContent: [URL] = []

		let message = "test file destination"
		let password = CensoredPassword(rawValue: "password!1234")
		log.info(message, password)
		logContent = try FileManager.default.contentsOfDirectory(at: logFolder, includingPropertiesForKeys: nil)
		XCTAssertEqual(1, logContent.count)

		let logFileURL = logContent[0]
		let logFileData = try Data(contentsOf: logFileURL)

		let logFile = try JSONDecoder().decode(CodableLogEntry.self, from: logFileData)
		XCTAssertEqual(message, logFile.message.first)
		XCTAssertEqual(password.rawValue, logFile.message.last)
		XCTAssertNotEqual(password.censoredDescription, logFile.message.last)
		XCTAssertEqual(Swiftwood.Level.info.level, logFile.logLevel)
	}
}
