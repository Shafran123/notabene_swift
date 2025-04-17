# NotaBene Swift

[![Version](https://img.shields.io/cocoapods/v/notabene_swift.svg?style=flat)](https://cocoapods.org/pods/notabene_swift)
[![License](https://img.shields.io/cocoapods/l/notabene_swift.svg?style=flat)](https://cocoapods.org/pods/notabene_swift)
[![Platform](https://img.shields.io/cocoapods/p/notabene_swift.svg?style=flat)](https://cocoapods.org/pods/notabene_swift)

## Overview

NotaBene Swift provides a clean integrating the Notabene widget into iOS applications. It handles configuration, presentation, and communication with the widget, making it easy to implement transaction validation and compliance features in your iOS app.

## Requirements

- iOS 14.0+
- Swift 5.0
- Xcode 12.0+

## Installation

NotaBene Swift is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile: 

```ruby
pod 'notabene_swift'
```

Then, run the following command:

```bash
pod install
```

## Getting Started

To get started with NotaBene Swift, follow these steps:

1. Add the `notabene_swift` pod to your Podfile.
2. Run `pod install` to install the pod.
3. Import the module in your Swift files where you intend to use it.

## Usage

Here's a basic example of how to use NotaBene Swift in your project:

```swift
import NotaBeneSwift

// Initialize and configure the widget
let widget = NotaBeneWidget()
widget.configure(with: yourConfiguration)

// Present the widget
widget.present(from: yourViewController)
```

## Contributing

Contributions are welcome! If you have suggestions or improvements, please open an issue or submit a pull request.

## Author

mshafran13@gmail.com

## License

notabene_swift is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
