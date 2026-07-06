# MubeenDeviceSDK

iOS/macOS Device Intelligence SDK. Mints a persistent **UUIDv7 device ID** and submits a **device fingerprint** to the Mubeen backend for server-side analysis. Distributed as a signed, closed-source XCFramework.

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.10+ / Xcode 15+

## Installation

### Swift Package Manager (recommended)

In Xcode: **File → Add Package Dependencies…**, enter
`https://github.com/mubeen-ai/Mubeen-IOS-SDK-public.git`, and pick **2.0.0**.

Or in `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/mubeen-ai/Mubeen-IOS-SDK-public.git", from: "2.0.0")
]
```

### CocoaPods
```ruby
pod 'MubeenDeviceSDK', '~> 2.0'
```

## Quick Start

```swift
import MubeenDeviceSDK

// 1. Configure once at app launch (mints + persists the device ID).
try await Mubeen.configure(
    MubeenConfig(
        apiKey: "pk_live_your_key",
        endpoint: URL(string: "https://api.mubeen.io")!
    )
)

// 2. Read the stable device ID (UUIDv7, Keychain-persisted, survives reinstall).
let id = Mubeen.deviceId

// 3. Send a device fingerprint (e.g. at login/checkout).
try await Mubeen.sendFingerprint(metadata: ["account_id": "user_12345"])

// 4. Reset the device ID (privacy / GDPR delete / logout).
Mubeen.resetDeviceId()
```

`sendFingerprint` succeeds on any 2xx; transient errors (offline / 429 / 5xx) are queued and retried automatically; terminal client errors (400/401/403) throw a `MubeenSDKError`.

See [INTEGRATION.md](INTEGRATION.md) for the full guide (config options, metadata/linkage, error handling, and privacy).

## License

Commercial. Copyright 2026 Mubeen AI. All rights reserved.
