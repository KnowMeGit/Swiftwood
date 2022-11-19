# Swiftwood
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FKnowMeGit%2FSwiftwood%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/KnowMeGit/Swiftwood) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FKnowMeGit%2FSwiftwood%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/KnowMeGit/Swiftwood)

A logging package for swift projects.
("swiftwood" is a pun of "driftwood" since logs are often just tossed into the stream of events to be lost amidst the wilderness)

Heavily inspired by SwiftyBeaver, but infinitely simpler. Additionally includes support for (semi)automatic censoring of 
sensitive data.

No remote logging destination is currently included. It isn't that hard to create one, just conform to `SwiftwoodDestination`,
 batch up a few logs, and then send them off to your server. I intend to add a generic implementation/example in the future, 
 as time provides. This would be a good suggestion for a contributor. 

### Initial Setup
```swift 

fileprivate let setupLock = NSLock()
fileprivate var loggingIsSetup = false

func setupLogging() {
	setupLock.lock()
	defer { setupLock.unlock() }
	guard loggingIsSetup == false else { return }
	loggingIsSetup = true

	let consoleDestination = ConsoleLogDestination(maxBytesDisplayed: -1)
	consoleDestination.minimumLogLevel = .verbose
	log.destinations.append(consoleDestination)
}
```

then call `setupLogging()` somewhere early in your app lifecycle.


### Usage

```swift
log.verbose("Something small happened")
//10/04/2022 00:49:40.107 💜 VERBOSE SwiftwoodTests.swift testLogging():19 - Something small happened
log.debug("Some minor update")
//10/04/2022 00:49:40.109 💚 DEBUG SwiftwoodTests.swift testLogging():20 - Some minor update
log.info("Look at me")
//10/04/2022 00:49:40.111 💙 INFO SwiftwoodTests.swift testLogging():21 - Look at me
log.warning("uh oh")
//10/04/2022 00:49:40.113 💛 WARNING SwiftwoodTests.swift testLogging():22 - uh oh
log.error("Failed successfully")
//10/04/2022 00:49:40.115 ❤️ ERROR SwiftwoodTests.swift testLogging():23 - Failed successfully
```

### Censoring Sensitive Data

Simply conform anything you want to censor to `CensoredLogItem` and when you log the item *individually* and have censoring 
on for your destination, it will appear as `**CENSORED**` in the log.

Example:

```swift

struct CensoredPassword: CensoredLogItem, RawRepresentable {
	let rawValue: String
}

let consoleDestination = ConsoleLogDestination(maxBytesDisplayed: -1, shouldCensor: true) // Console destinations default to `false` censorship
let fileDestination = try FilesDestination(logFolder: URL(pretend this is a valid url), shouldCensor: true) // File destinations default to `true` censorship

let password = CensoredPassword(rawValue: "password1234!")
log.info("regular string", password) // regular string CensoredPassword: **CENSORED*
log.info("regular string \(password)") // regular string CensoredPassword(rawValue: "password!1234")
```
Note how if you use string interpolation, censorship will fail!

Alternatively, if you want to obfuscate but reveal a bit, you can provide a custom `censoredDescription`:

```swift
struct CensoredKey: CensoredLogItem, RawRepresentable, CustomStringConvertible {
	let rawValue: String

	var description: String { rawValue }
	var censoredDescription: String {
		guard
			rawValue.count > 10,
			let start = rawValue.index(rawValue.endIndex, offsetBy: -3, limitedBy: rawValue.startIndex)
		else { return "***" }
		return "***" + String(rawValue[start..<rawValue.endIndex])
	}
}

let key = CensoredKey(rawValue: "thisisalongkey")
log.info("My key is:", key) // My key is: ***key
log.info("My key is: \(key)") // My key is: thisisalongkey
```
Be sure not to use string interpolation for values you want to censor!

See tests for additional nuance and examples
