[![Mihael Isaev](https://user-images.githubusercontent.com/1272610/53910913-767d1580-406e-11e9-8ed6-f3025f193342.png)](http://mihaelisaev.com)

<p align="center">
    <a href="LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/swift-4.2-brightgreen.svg" alt="Swift 4.2">
    </a>
    <a href="https://cocoapods.org/pods/SwifCron">
        <img src="https://img.shields.io/cocoapods/v/SwifCron.svg" alt="Cocoapod">
    </a>
    <img src="https://img.shields.io/github/workflow/status/MihaelIsaev/SwifCron/test" alt="Github Actions">
</p>
<p align="center"><a href="https://discord.gg/q5wCPYv">SWIFT.STREAM COMMUNITY IN DISCORD</a></p>
<br>

### Don't forget to support the lib by giving a ⭐️

## How to install

### CocoaPods

SwifCron is available through [CocoaPods](https://cocoapods.org)

To install it, simply add the following line in your Podfile:
```ruby
pod 'SwifCron', '~> 1.3.0'
```

### Swift Package Manager

```swift
.package(url: "https://github.com/MihaelIsaev/SwifCron.git", from:"1.3.0")
```
In your target's dependencies add `"SwifCron"` e.g. like this:
```swift
.target(name: "App", dependencies: ["SwifCron"]),
```

## Usage

```swift
import SwifCron

do {
    let cron = try SwifCron("* * * * *")

    //for getting next date related to current date
    let nextDate = try cron.next()

    //for getting next date related to custom date
    let nextDate = try cron.next(from: Date())
} catch {
    print(error)
}
```

## Limitations

I use [CrontabGuru](https://crontab.guru/) as a reference

So you could parse any expression which consists of digits with `*` `,` `/` and `-` symbols

## Contributing

Please feel free to contribute!

## ToDo

- write more tests
- support literal names of months and days of week in expression
- support non-standard digits like `7` for Sunday in day of week part of expression
