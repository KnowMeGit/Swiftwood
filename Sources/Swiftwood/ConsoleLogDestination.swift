import Foundation

public class ConsoleLogDestination: SwiftwoodDestination {
	public var format = Swiftwood.Format()
	public var minimumLogLevel: Swiftwood.Level = .info
	public var logFilter: LogCategory.Filter = .none
	public var shouldCensor: Bool

	public var maxBytesDisplayed: Int

	public init(maxBytesDisplayed: Int, shouldCensor: Bool = false) {
		self.maxBytesDisplayed = maxBytesDisplayed
		self.shouldCensor = shouldCensor
	}

	public func sendToDestination(_ entry: Swiftwood.LogEntry) {
		let formattedMessage = format.convertEntryToString(entry, censoring: shouldCensor)

		guard maxBytesDisplayed > 0 else {
			print(formattedMessage)
			return
		}

		guard
			let sectionEndIndex = formattedMessage.index(formattedMessage.startIndex, offsetBy: maxBytesDisplayed, limitedBy: formattedMessage.endIndex)
		else {
			print(formattedMessage)
			return
		}

		let firstXCharacters = formattedMessage[formattedMessage.startIndex..<sectionEndIndex]

		print(firstXCharacters + "... (too large to output in console)")
	}
}
