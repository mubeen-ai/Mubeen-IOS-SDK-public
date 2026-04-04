# MubeenDeviceSDK

iOS Device Intelligence SDK for fraud prevention and risk evaluation. Collects device fingerprint signals and submits them to the Mubeen backend for real-time risk scoring.

## Requirements

- iOS 15.0+
- Swift 5.10+
- Xcode 15+

## Installation

### Swift Package Manager (recommended)

In Xcode:

1. **File > Add Package Dependencies...**
2. Enter: `https://github.com/mubeen-ai/MubeenDeviceSDK.git`
3. Select version: **1.0.0**
4. Click **Add Package**

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mubeen-ai/MubeenDeviceSDK.git", from: "1.0.0")
]
```

### CocoaPods

```ruby
pod 'MubeenDeviceSDK', '~> 1.0'
```

Or point directly to this repo:

```ruby
pod 'MubeenDeviceSDK', :podspec => 'https://raw.githubusercontent.com/mubeen-ai/MubeenDeviceSDK/main/MubeenDeviceSDK.podspec'
```

## Quick Start

```swift
import MubeenDeviceSDK

// 1. Configure (call once at app launch)
try await Mubeen.configure(MubeenConfig(
    tenantId: "your_tenant_id",
    publishableKey: "pk_live_your_key",
    apiBaseURL: URL(string: "https://api.mubeen.ai")!
))

// 2. Evaluate a business event
let verdict = try await Mubeen.evaluate(
    event: "checkout",
    correlationId: "order_12345",
    metadata: ["account_id": "user_456", "cart_value": "299.99"]
)

// 3. Act on the verdict
switch verdict.action {
case .allow:  proceedWithTransaction()
case .review: flagForManualReview()
case .deny:   blockTransaction()
case .challenge: triggerStepUp()
}

// 4. Get the device token for your backend
let state = Mubeen.getLocalState()
let deviceToken = state.deviceToken  // Send this to your backend
```

## Features

- Device fingerprinting with 8 signal categories
- Apple App Attest integration
- Certificate pinning with remote pin rotation
- Jailbreak and tamper detection
- Rate limiting and kill switch support
- Offline retry queue (network-aware)
- Zero external dependencies (Apple frameworks only)

## Privacy

The SDK does not access GPS, contacts, photos, camera, or microphone. All PII (account IDs, emails, phone numbers) is SHA-256 hashed client-side before transmission.

See [PrivacyInfo.xcprivacy](Sources/MubeenDeviceSDK/PrivacyInfo.xcprivacy) for the full privacy manifest.

## Support

Contact [engineering@mubeen.ai](mailto:engineering@mubeen.ai) for integration support.
