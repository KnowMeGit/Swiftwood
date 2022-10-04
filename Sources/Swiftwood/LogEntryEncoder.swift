import Foundation

protocol LogEntryEncoder {
	func encode(_ value: Swiftwood.LogEntry) throws -> Data
}

struct CodableLogEntry: Codable {
	let timestamp: Date
	let logLevel: Int
	let message: String
	let sourceFile: String
	let function: String
	let lineNumber: Int
	let context: String?

	var approximateSize: Int {
		message.count + (context?.count ?? 0)
	}

	init(_ input: Swiftwood.LogEntry) {
		self.timestamp = input.timestamp
		self.logLevel = input.logLevel.level
		self.message = "\(input.message)"
		self.sourceFile = URL(fileURLWithPath: input.file).lastPathComponent
		self.function = input.function
		self.lineNumber = input.lineNumber
		self.context = input.context.map { "\($0)" }
	}
}

extension JSONEncoder: LogEntryEncoder {
	func encode(_ value: Swiftwood.LogEntry) throws -> Data {
		let codeableEntry = CodableLogEntry(value)
		return try encode(codeableEntry)
	}
}
extension PropertyListEncoder: LogEntryEncoder {
	func encode(_ value: Swiftwood.LogEntry) throws -> Data {
		let codeableEntry = CodableLogEntry(value)
		return try encode(codeableEntry)
	}
}

class StringEncoder: LogEntryEncoder {
	let format: Swiftwood.Format

	init(format: Swiftwood.Format) {
		self.format = format
	}

	func encode(_ value: Swiftwood.LogEntry) throws -> Data {
		let string = format.convertEntryToString(value)
		return Data(string.utf8)
	}
}
