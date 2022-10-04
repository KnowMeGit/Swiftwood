import Foundation

public protocol SwiftwoodDestination: AnyObject {
	var format: Swiftwood.Format { get }
	var minimumLogLevel: Swiftwood.Level { get }
	func sendToDestination(_ entry: Swiftwood.LogEntry)
}

// log dumping
public class Swiftwood {
	public static let logFileURLs: [URL] = []

	public struct Format {
		public init(parts: [Swiftwood.Format.Part] = [
			.timestamp(),
			.staticText(" "),
			.logLevel,
			.staticText(" "),
			.file,
			.staticText(" "),
			.function,
			.staticText(":"),
			.lineNumber,
			.staticText(" - "),
			.message,
		], separator: String = "") {
			self.parts = parts
			self.separator = separator
		}


		public static var defaultDateFormatter: DateFormatter = {
			let formatter = DateFormatter()
			formatter.dateFormat = "MM/dd/yyyy HH:mm:ss.SSS"
			return formatter
		}()

		public enum Part {
			case timestamp(format: DateFormatter = Format.defaultDateFormatter)
			case logLevel
			case staticText(String)
			case message
			case file
			case function
			case lineNumber
			case context
		}

		public var parts: [Part]
		public var separator: String

		public func convertEntryToString(_ entry: LogEntry) -> String {
			var output: [String] = []

			for part in parts {
				switch part {
				case .timestamp(let formatter):
					output.append(formatter.string(from: entry.timestamp))
				case .logLevel:
					output.append(entry.logLevel.textValue)
				case .staticText(let string):
					output.append(string)
				case .message:
					output.append("\(entry.message)")
				case .file:
					let url = URL(fileURLWithPath: entry.file)
					let file = url.lastPathComponent
					output.append(file)
				case .function:
					output.append(entry.function)
				case .lineNumber:
					output.append("\(entry.lineNumber)")
				case .context:
					output.append("\(entry.context as Any)")
				}
			}

			return output.joined(separator: separator)
		}
	}

	public struct LogEntry {
		let timestamp: Date
		let logLevel: Level
		let message: Any
		let file: String
		let function: String
		let lineNumber: Int
		let context: Any?
	}

	public static var destinations: [SwiftwoodDestination] = []

	public static var logFormat = Format()

	public static func info(
		_ message: Any,
		file: String = #file,
		function: String = #function,
		line: Int = #line,
		context: Any? = nil) {
			custom(level: .info, message, file: file, function: function, line: line, context: context)
		}

	public static func warning(
		_ message: Any,
		file: String = #file,
		function: String = #function,
		line: Int = #line,
		context: Any? = nil) {
			custom(level: .warning, message, file: file, function: function, line: line, context: context)
		}

	public static func error(
		_ message: Any,
		file: String = #file,
		function: String = #function,
		line: Int = #line,
		context: Any? = nil) {
			custom(level: .error, message, file: file, function: function, line: line, context: context)
		}

	public static func debug(
		_ message: Any,
		file: String = #file,
		function: String = #function,
		line: Int = #line,
		context: Any? = nil) {
			custom(level: .debug, message, file: file, function: function, line: line, context: context)
		}

	public static func verbose(
		_ message: Any,
		file: String = #file,
		function: String = #function,
		line: Int = #line,
		context: Any? = nil) {
			custom(level: .verbose, message, file: file, function: function, line: line, context: context)
		}

	public static func custom(
		level: Level,
		_ message: Any,
		file: String = #file,
		function: String = #function,
		line: Int = #line,
		context: Any? = nil) {
//			guard level >= minimumLogLevel else { return }
			let date = Date()
			let logEntry = LogEntry(
				timestamp: date,
				logLevel: level,
				message: message,
				file: file,
				function: function,
				lineNumber: line,
				context: context)

			destinations.forEach {
				$0.sendToDestination(logEntry)
			}
		}

	public static func clearLogs() {}

//	if useTerminalColors {
//		// use Terminal colors
//		reset = "\u{001b}[0m"
//		escape = "\u{001b}[38;5;"
//		levelColor.verbose = "251m"     // silver
//		levelColor.debug = "35m"        // green
//		levelColor.info = "38m"         // blue
//		levelColor.warning = "178m"     // yellow
//		levelColor.error = "197m"       // red
//	} else {
//		// use colored Emojis for better visual distinction
//		// of log level for Xcode 8
//		levelColor.verbose = "💜 "     // silver
//		levelColor.debug = "💚 "        // green
//		levelColor.info = "💙 "         // blue
//		levelColor.warning = "💛 "     // yellow
//		levelColor.error = "❤️ "       // red
//	}

	public struct Level: Comparable, Equatable {
		public static var verbose = Level(textValue: "💜 VERBOSE", level: 20)
		public static var debug = Level(textValue: "💚 DEBUG", level: 40)
		public static var info = Level(textValue: "💙 INFO", level: 60)
		public static var warning = Level(textValue: "💛 WARNING", level: 80)
		public static var error = Level(textValue: "❤️ ERROR", level: 100)

		public let textValue: String
		public let level: Int

		public init(textValue: String, level: Int) {
			self.textValue = textValue
			self.level = level
		}

		/// automatically assigns to the closest default log level
		public init(rawValue: Int) {
			switch rawValue {
			case ...20:
				self.textValue = "💜 VERBOSE"
				self.level = 20
			case 21...40:
				self.textValue = "💚 DEBUG"
				self.level = 40
			case 41...60:
				self.textValue = "💙 INFO"
				self.level = 60
			case 61...80:
				self.textValue = "💛 WARNING"
				self.level = 80
			default: // aka case 81...:
				self.textValue = "❤️ ERROR"
				self.level = 100
			}
		}

		public static func < (lhs: Swiftwood.Level, rhs: Swiftwood.Level) -> Bool {
			lhs.level < rhs.level
		}
	}
}
