import Foundation

/**
 Extend `LogCategory` with your own categories if desired (as static constants: `static let yourCategory: LogCategory = "yourCategory"`).
 Categories would be anticipated to be things like `ui`, `networking`, or `CoreData`, but the sky's really the limit. You can then use `LogCategory`s to
 filter output from logging destinations, or perhaps send everything to a remote destination and then use categories for filtering in remote logging. Again, sky's the limit.
 You are an adult. You can come up with your own ideas.
 */
public struct LogCategory: RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible, Codable, Hashable {
	public let rawValue: String

	public var description: String { rawValue }

	public init(rawValue: String) {
		self.rawValue = rawValue
	}

	public init(stringLiteral value: StringLiteralType) {
		self.init(rawValue: value)
	}
}

public extension LogCategory {
	static let `default`: LogCategory = "default"
}


public extension LogCategory {
	enum Filter {
		case allow(Set<LogCategory>)
		case block(Set<LogCategory>)
		case none

		public func allows(_ category: LogCategory) -> Bool {
			switch self {
			case .allow(let allowList):
				return allowList.contains(category)
			case .block(let blockList):
				return blockList.contains(category) == false
			case .none:
				return true
			}
		}
	}
}
