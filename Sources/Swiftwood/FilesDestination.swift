import Foundation

/**
 Named "Files" because it creates a new file with each new log entry. Intending to create an additional single file solution in the future. Currently, no cleanup is done automatically for accumulated log files.
 */
public class FilesDestination: SwiftwoodDestination {
	/// Ignored for any `fileFormat` other than `formattedString`
	public var format: Swiftwood.Format = .init()

	public let fileFormat: FileFormat
	public enum FileFormat: String {
		case json
		case propertyList = "plist"
		case formattedString = "log"
	}

	private let encoder: any CodableLogEntryEncoder

	public var minimumLogLevel: Swiftwood.Level = .init(rawValue: 0)

//	public enum RotationStyle {
//		case filesize(bytes: Int)
//		case entries(count: Int)
//	}
//	public let rotationStyle: RotationStyle

	public let ageBeforeCulling: TimeInterval?

	public let logFolder: URL

	public init(
		logFolder: URL?,
		ageBeforeCulling: TimeInterval?,
		format: Swiftwood.Format = .init(),
		fileformat: FileFormat = .json,
		minimumLogLevel: Swiftwood.Level = .init(rawValue: 0)) throws {

			if let logFolder {
				self.logFolder = logFolder
			} else {
				let logFolder = try FileManager
					.default
					.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
					.appendingPathComponent("SwiftwoodLogs")
				self.logFolder = logFolder
			}
			self.ageBeforeCulling = ageBeforeCulling
			self.format = format
			self.fileFormat = fileformat
			self.minimumLogLevel = minimumLogLevel
			switch fileformat {
			case .json:
				let json = JSONEncoder()
				json.dateEncodingStrategy = .secondsSince1970
				self.encoder = json
			case .propertyList:
				let plist = PropertyListEncoder()
				plist.outputFormat = .binary
				self.encoder = plist
			case .formattedString:
				self.encoder = StringEncoder(format: format)
			}

			try FileManager.default.createDirectory(at: self.logFolder, withIntermediateDirectories: true)
		}

	private var currentFileInfo: FileInfo?
	struct FileInfo {
		let location: URL
		var fileSize: Int
		var entries: Int
	}

	public func sendToDestination(_ entry: Swiftwood.LogEntry) {
		guard entry.logLevel >= minimumLogLevel else { return }
		let level = entry.logLevel.level

		let filename = "\(entry.timestamp.timeIntervalSince1970)-\(UUID())-\(level)"

		do {
			let data = try encoder.encode(entry)

			let options: Data.WritingOptions
			if #available(macOS 11.0, *) {
				options = [.atomic, .completeFileProtectionUnlessOpen]
			} else {
				options = [.atomic]
			}
			try data.write(
				to: logFolder
					.appendingPathComponent(filename)
					.appendingPathExtension(fileFormat.rawValue),
				options: options)
		} catch {
			print("Error!! Could not save log file!")
		}

	}
}
