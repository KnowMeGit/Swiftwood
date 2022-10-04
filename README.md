# Swiftwood

A logging package for swift projects.

Heavily inspired by SwiftyBeaver, but infinitely simpler.

("swiftwood" is a pun of "driftwood" since logs are often just tossed into the stream of events to be lost amidst the wilderness)


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
