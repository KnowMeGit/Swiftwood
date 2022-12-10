import Foundation

public protocol SwiftwoodDestination: AnyObject {
	var format: Swiftwood.Format { get }
	var minimumLogLevel: Swiftwood.Level { get }
	var logFilter: LogCategory.Filter { get set }
	var shouldCensor: Bool { get set }
	func sendToDestination(_ entry: Swiftwood.LogEntry)
}
