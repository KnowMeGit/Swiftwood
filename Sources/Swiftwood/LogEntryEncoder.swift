import Foundation

public protocol LogEntryEncoder {
	func encode(_ value: Swiftwood.LogEntry, shouldCensor: Bool) throws -> Data
}

public struct CodableLogEntry: Codable {
	public let timestamp: Date
	public let logLevel: Int
	public let message: [String]
	public let category: LogCategory
	public let sourceFile: String
	public let function: String
	public let lineNumber: Int
	public let buildInfo: String?
	public let context: String?

	public var approximateSize: Int {
		message.count + (context?.count ?? 0)
	}

	public init(_ input: Swiftwood.LogEntry, shouldCensor: Bool) {
		self.timestamp = input.timestamp
		self.logLevel = input.logLevel.level
		self.message = input
			.message
			.map {
				if
					shouldCensor,
					let censored = $0 as? CensoredLogItem {

					return censored.censoredDescription
				} else {
					return String(describing: $0)
				}
			}
		self.category = input.category
		self.sourceFile = URL(fileURLWithPath: input.file).lastPathComponent
		self.function = input.function
		self.lineNumber = input.lineNumber
		self.buildInfo = input.buildInfo
		self.context = input.context.map { "\($0)" }
	}
}

extension JSONEncoder: LogEntryEncoder {
	public func encode(_ value: Swiftwood.LogEntry, shouldCensor: Bool) throws -> Data {
		let codeableEntry = CodableLogEntry(value, shouldCensor: shouldCensor)
		return try encode(codeableEntry)
	}
}
extension PropertyListEncoder: LogEntryEncoder {
	public func encode(_ value: Swiftwood.LogEntry, shouldCensor: Bool) throws -> Data {
		let codeableEntry = CodableLogEntry(value, shouldCensor: shouldCensor)
		return try encode(codeableEntry)
	}
}

class StringEncoder: LogEntryEncoder {
	let format: Swiftwood.Format

	init(format: Swiftwood.Format) {
		self.format = format
	}

	func encode(_ value: Swiftwood.LogEntry, shouldCensor: Bool) throws -> Data {
		let string = format.convertEntryToString(value, censoring: shouldCensor)
		return Data(string.utf8)
	}
}
