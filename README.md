# Beanstalk Engage iOS SDK


## Requirements

- iOS 8.4+
- Xcode 8.1+
- Swift 3.0

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```
> CocoaPods 1.0.1+ is required to build BeanstalkEngageiOSSDK.

To integrate BeanstalkEngageiOSSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
pod 'BeanstalkEngageiOSSDK', :git => 'git@github.com:BeanstalkData/beanstalk-ios-sdk.git', :tag => '0.6.14'
end
```

Then, run the following command:

```bash
$ pod update
```

## Usage

Check Example project.

## License

BeanstalkEngageiOSSDK is released under the MIT license. See LICENSE for details.
