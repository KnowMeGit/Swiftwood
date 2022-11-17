import Foundation

public protocol CensoredLogItem {
	var censoredDescription: String { get }
}

public extension CensoredLogItem {
	var censoredDescription: String {
		"\(type(of: self)): **CENSORED**"
	}
}
