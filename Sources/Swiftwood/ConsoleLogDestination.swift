import Foundation

public class ConsoleLogDestination: SwiftwoodDestination {
	public var format = Swiftwood.Format()
	public var minimumLogLevel: Swiftwood.Level = .info

	public var maxBytesDisplayed: Int

	public init(maxBytesDisplayed: Int) {
		self.maxBytesDisplayed = maxBytesDisplayed
	}

	public func sendToDestination(_ entry: Swiftwood.LogEntry) {
		guard entry.logLevel >= minimumLogLevel else { return }

		let formattedMessage = format.convertEntryToString(entry)

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
