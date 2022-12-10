import Foundation

public protocol SwiftwoodDestination: AnyObject {
	var format: Swiftwood.Format { get }
	var minimumLogLevel: Swiftwood.Level { get }
	var logFilter: LogCategory.Filter { get set }
	var shouldCensor: Bool { get set }
	func sendToDestination(_ entry: Swiftwood.LogEntry)
}

extension SwiftwoodDestination {
	func qualifiesForFilters(entry: Swiftwood.LogEntry) -> Bool {
		entry.logLevel >= minimumLogLevel && logFilter.allows(entry.category)
	}

	func sendToDestinationIfPassesFilters(_ entry: Swiftwood.LogEntry) {
		guard qualifiesForFilters(entry: entry) else { return }
		sendToDestination(entry)
	}
}
