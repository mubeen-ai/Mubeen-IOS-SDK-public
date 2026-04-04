# MubeenDeviceSDK — Integration Guide

> iOS Device Intelligence SDK for fraud prevention and risk evaluation.
> Version 1.0.0

---

## Table of Contents

1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [Configuration](#configuration)
5. [Evaluating Events](#evaluating-events)
6. [Device Token & Backend Linking](#device-token--backend-linking)
7. [Handling Verdicts](#handling-verdicts)
8. [Error Handling](#error-handling)
9. [Network Monitoring (Delegate)](#network-monitoring-delegate)
10. [API Reference](#api-reference)
11. [Privacy & Data Collection](#privacy--data-collection)
12. [FAQ](#faq)

---

## Requirements

| Requirement | Minimum |
|-------------|---------|
| iOS         | 15.0+   |
| Swift       | 5.10+   |
| Xcode       | 15+     |

The SDK has **zero external dependencies** — it uses only Apple system frameworks (Foundation, UIKit, DeviceCheck, CryptoKit, Security, Network).

---

## Installation

### Swift Package Manager (recommended)

**In Xcode:**

1. Go to **File > Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/mubeen-ai/MubeenDeviceSDK.git
   ```
3. Select version **1.0.0** (or "Up to Next Major")
4. Click **Add Package**

**In Package.swift:**

```swift
dependencies: [
    .package(url: "https://github.com/mubeen-ai/MubeenDeviceSDK.git", from: "1.0.0")
]
```

Then add `"MubeenDeviceSDK"` to your target's dependencies.

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'MubeenDeviceSDK', :podspec => 'https://raw.githubusercontent.com/mubeen-ai/MubeenDeviceSDK/main/MubeenDeviceSDK.podspec'
```

Then run `pod install`.

---

## Quick Start

```swift
import MubeenDeviceSDK

// 1. Configure once at app launch
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
if verdict.action == .deny {
    blockTransaction()
}

// 4. Get device token for your backend
let deviceToken = Mubeen.getLocalState().deviceToken
```

---

## Configuration

Call `Mubeen.configure()` **once** when your app launches — ideally in your App struct's `.task` modifier or `AppDelegate.didFinishLaunching`.

```swift
let config = MubeenConfig(
    tenantId: "your_tenant_id",         // Required — provided by Mubeen
    publishableKey: "pk_live_your_key", // Required — provided by Mubeen
    environment: .production,           // .production (default) or .sandbox
    apiBaseURL: URL(string: "https://api.mubeen.ai")!,  // Required
    enableAppAttest: true,              // Apple App Attest (default: true)
    enableJailbreakChecks: true,        // Jailbreak detection (default: true)
    enableBehavioralSignals: false,     // Behavioral signals (default: false)
    logLevel: .warning                  // Logging verbosity (default: .warning)
)

try await Mubeen.configure(config)
```

### Configuration Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tenantId` | `String` | — | Your Mubeen tenant identifier |
| `publishableKey` | `String` | — | Publishable API key (starts with `pk_`) |
| `environment` | `MubeenEnvironment` | `.production` | `.production` or `.sandbox` |
| `apiBaseURL` | `URL` | — | Mubeen API base URL |
| `appGroupId` | `String?` | `nil` | App Group ID for cross-app data sharing |
| `enableAppAttest` | `Bool` | `true` | Enable Apple App Attest |
| `enableJailbreakChecks` | `Bool` | `true` | Enable jailbreak/tamper detection |
| `enableBehavioralSignals` | `Bool` | `false` | Enable behavioral analysis |
| `logLevel` | `LogLevel` | `.warning` | `.verbose`, `.debug`, `.info`, `.warning`, `.error`, `.none` |

### What happens during configure

1. SDK validates your configuration
2. Generates or loads device identity (keypair + identifiers)
3. Registers the device with the Mubeen backend (async, non-blocking)
4. Prepares Apple App Attest if enabled and available
5. Fetches remote configuration (feature flags, kill switch)
6. Drains any queued payloads from previous offline sessions

`configure()` returns as soon as local setup completes. Network operations (registration, attestation, remote config) run in the background so your app isn't blocked.

### Recommended placement

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    do {
                        try await Mubeen.configure(MubeenConfig(
                            tenantId: "your_tenant_id",
                            publishableKey: "pk_live_your_key",
                            apiBaseURL: URL(string: "https://api.mubeen.ai")!
                        ))
                    } catch {
                        print("Mubeen SDK init failed: \(error)")
                    }
                }
        }
    }
}
```

---

## Evaluating Events

Call `Mubeen.evaluate()` at key business events — login, registration, checkout, payment, password change, etc.

```swift
let verdict = try await Mubeen.evaluate(
    event: "checkout",
    correlationId: "order_abc123",
    metadata: [
        "account_id": "user_456",
        "payment_token_id": "tok_visa_4242",
        "cart_value": "299.99",
        "currency": "USD"
    ]
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `event` | `String` | Yes | Event type: `"login"`, `"signup"`, `"checkout"`, `"payment"`, etc. |
| `correlationId` | `String` | Yes | Your transaction/request ID for tracing |
| `metadata` | `[String: String]?` | No | Key-value context about the event |

### Metadata keys with special handling

These metadata keys are automatically detected and **SHA-256 hashed** before transmission. Pass them as plaintext — the SDK handles privacy:

| Key | Description |
|-----|-------------|
| `account_id` | User's account identifier |
| `payment_token_id` | Payment instrument token |
| `email` | User's email address |
| `phone` | User's phone number |

All other metadata keys are sent as-is (no hashing). Do not include raw PII in other keys.

### What the SDK collects

The SDK automatically collects and sends these signals with each evaluation:

- **Identity** — device keypair hash, vendor ID hash, App Attest key
- **Integrity** — jailbreak score, tamper indicators, debugger detection
- **Device** — model, OS version, screen, locale, timezone, storage
- **App** — bundle ID, version, install date
- **Network** — connection type, carrier info
- **Session** — session ID, event count, duration
- **Linkage** — hashed account/email/phone for cross-device linking

---

## Device Token & Backend Linking

After `configure()` completes, the SDK assigns a **device token** — a unique identifier for this device. Use it to link SDK fingerprint data with your server-side risk checks.

```swift
let state = Mubeen.getLocalState()

if let deviceToken = state.deviceToken {
    // Send deviceToken to your backend with each API call
    // Your backend passes it to Mubeen Risk Engine for enriched scoring
    yourAPI.submitOrder(orderId: "123", deviceToken: deviceToken)
}
```

### Device token lifecycle

| State | `deviceToken` | `isProvisionalToken` | Meaning |
|-------|---------------|----------------------|---------|
| Before `configure()` | `nil` | `false` | SDK not initialized |
| After `configure()`, registration pending | `"prov_a1b2c3..."` | `true` | Provisional token — available immediately, usable for linking |
| After registration succeeds | `"mdid_x7y8z9..."` | `false` | Registered device token — canonical identifier |

The provisional token is available **instantly** (no network needed) and is linked to the registered token once registration completes. You can start sending it to your backend immediately.

### Server-side integration

Your backend calls the Mubeen Risk Engine API with the device token:

```
POST https://api.mubeen.ai/v1/risk/assess
{
    "device_token": "mdid_x7y8z9...",
    "event": "payment",
    "amount": 149.50,
    "currency": "USD",
    "account_id": "user_456"
}
```

The Risk Engine uses the latest fingerprint data associated with this device token to enrich its risk decision.

---

## Handling Verdicts

Each `evaluate()` call returns a `MubeenVerdict`:

```swift
let verdict = try await Mubeen.evaluate(
    event: "checkout",
    correlationId: orderId,
    metadata: metadata
)

switch verdict.action {
case .allow:
    // Low risk — proceed normally
    processOrder()

case .review:
    // Medium risk — flag for manual review, but allow to proceed
    flagForReview(correlationId: verdict.correlationId)
    processOrder()

case .challenge:
    // Elevated risk — request additional verification
    requestMFA(onSuccess: { processOrder() })

case .deny:
    // High risk — block the transaction
    showBlockedMessage()
}

// The score provides granularity (0 = safe, 100 = highest risk)
print("Risk score: \(verdict.score)")
```

### MubeenVerdict properties

| Property | Type | Description |
|----------|------|-------------|
| `score` | `Int` | Risk score (0–100). 0 = safe, 100 = highest risk |
| `action` | `VerdictAction` | Recommended action: `.allow`, `.review`, `.challenge`, `.deny` |
| `correlationId` | `String` | Echoed from your request for transaction matching |

---

## Error Handling

All SDK errors are typed as `MubeenSDKError` with machine-readable error codes:

```swift
do {
    let verdict = try await Mubeen.evaluate(
        event: "payment",
        correlationId: paymentId,
        metadata: ["account_id": userId]
    )
    handleVerdict(verdict)
} catch let error as MubeenSDKError {
    switch error {
    case .notConfigured:
        // SDK not initialized — call configure() first
        initializeSDK()

    case .rateLimited:
        // Too many requests — back off and retry
        showMessage("Please wait a moment before trying again.")

    case .killSwitchActive:
        // SDK disabled remotely — proceed without risk check or block
        handleDegradedMode()

    case .networkError(let message):
        // Network issue — SDK queues the payload for retry automatically
        showMessage("Connection issue. Your transaction will be verified shortly.")

    case .serverError(let statusCode, let message):
        // Backend error
        logError("Server error \(statusCode): \(message ?? "")")

    default:
        // Log the error code for support
        logError("Mubeen error: \(error.errorCode) — \(error.localizedDescription)")
    }
} catch {
    logError("Unexpected: \(error)")
}
```

### Error codes reference

| Error | Code | Recoverable? |
|-------|------|-------------|
| `notConfigured` | `MUBEEN_E_NOT_CONFIGURED` | Call `configure()` |
| `configurationInvalid` | `MUBEEN_E_CONFIG` | Fix config params |
| `rateLimited` | `MUBEEN_E_RATE_LIMITED` | Retry after delay |
| `killSwitchActive` | `MUBEEN_E_KILL_SWITCH` | Contact Mubeen support |
| `networkError` | `MUBEEN_E_NETWORK` | Auto-retried via offline queue |
| `serverError` | `MUBEEN_E_SERVER` | Depends on status code |
| `registrationFailed` | `MUBEEN_E_REGISTRATION` | Auto-retried on next `evaluate()` |
| `attestationFailed` | `MUBEEN_E_ATTESTATION` | Non-fatal, SDK continues |
| `signalCollectionFailed` | `MUBEEN_E_SIGNALS` | Non-fatal, partial signals sent |
| `payloadSigningFailed` | `MUBEEN_E_SIGNING` | Non-fatal, unsigned payload sent |
| `keychainError` | `MUBEEN_E_KEYCHAIN` | Device keychain issue |
| `internalError` | `MUBEEN_E_INTERNAL` | Contact Mubeen support |

### Graceful degradation

The SDK is designed to be non-blocking:

- **Attestation failures** are non-fatal — the SDK continues with reduced signal quality
- **Signing failures** are non-fatal — unsigned payloads are still submitted
- **Network failures** trigger automatic retry — payloads are queued (up to 50) and retried when connectivity returns
- **Registration failures** are retried automatically on the next `evaluate()` call

---

## Network Monitoring (Delegate)

Optionally observe SDK network activity using `MubeenSDKDelegate`:

```swift
class MyViewModel: MubeenSDKDelegate {

    func mubeenSDKDidSendRequest(path: String, bodySize: Int) {
        // Called on MainActor — safe for UI updates
        print("Request: \(path) (\(bodySize) bytes)")
    }

    func mubeenSDKDidReceiveResponse(path: String, statusCode: Int, durationMs: Int) {
        // Called on MainActor — safe for UI updates
        print("Response: \(path) — \(statusCode) in \(durationMs)ms")
    }
}

// Set delegate before or after configure
Mubeen.delegate = myViewModel
```

The delegate does **not** expose request or response bodies for security reasons.

---

## API Reference

### `Mubeen`

The main SDK interface. All methods are static.

```swift
public final class Mubeen {
    /// Initialize the SDK. Call once at app launch.
    public static func configure(_ config: MubeenConfig) async throws

    /// Evaluate a business event and return a risk verdict.
    public static func evaluate(
        event: String,
        correlationId: String,
        metadata: [String: String]? = nil
    ) async throws -> MubeenVerdict

    /// Get the current SDK state. No network calls.
    public static func getLocalState() -> MubeenDeviceState

    /// Optional network activity observer.
    public static weak var delegate: MubeenSDKDelegate?
}
```

### `MubeenConfig`

```swift
public struct MubeenConfig: Sendable {
    public init(
        tenantId: String,
        publishableKey: String,
        environment: MubeenEnvironment = .production,
        apiBaseURL: URL,
        appGroupId: String? = nil,
        enableAppAttest: Bool = true,
        enableJailbreakChecks: Bool = true,
        enableBehavioralSignals: Bool = false,
        logLevel: LogLevel = .warning
    )
}
```

### `MubeenVerdict`

```swift
public struct MubeenVerdict: Sendable {
    public let score: Int            // 0–100
    public let action: VerdictAction // .allow, .review, .challenge, .deny
    public let correlationId: String // Echoed from request
}
```

### `MubeenDeviceState`

```swift
public struct MubeenDeviceState: Sendable {
    public let isReady: Bool           // SDK configured + device registered
    public let deviceToken: String?    // MDID or provisional token
    public let isProvisionalToken: Bool // true if pre-registration
}
```

### `VerdictAction`

```swift
public enum VerdictAction: String, Sendable, Codable {
    case allow     // Safe to proceed
    case review    // Flag for manual review
    case deny      // Block the action
    case challenge // Request step-up verification
}
```

### `MubeenEnvironment`

```swift
public enum MubeenEnvironment: String, Sendable, Codable {
    case production
    case sandbox
}
```

### `LogLevel`

```swift
public enum LogLevel: Int, Sendable, Comparable {
    case verbose = 0
    case debug   = 1
    case info    = 2
    case warning = 3  // default
    case error   = 4
    case none    = 5
}
```

### `MubeenSDKDelegate`

```swift
public protocol MubeenSDKDelegate: AnyObject, Sendable {
    @MainActor func mubeenSDKDidSendRequest(path: String, bodySize: Int)
    @MainActor func mubeenSDKDidReceiveResponse(path: String, statusCode: Int, durationMs: Int)
}
```

### `MubeenSDKError`

```swift
public enum MubeenSDKError: Error, Sendable {
    case notConfigured
    case configurationInvalid(String)
    case identityInitializationFailed(String)
    case keychainError(String)
    case registrationFailed(String)
    case attestationUnsupported
    case attestationFailed(String)
    case assertionFailed(String)
    case networkError(String)
    case serverError(statusCode: Int, message: String?)
    case signalCollectionFailed(String)
    case payloadSigningFailed(String)
    case rateLimited
    case killSwitchActive
    case internalError(String)

    public var errorCode: String { get } // e.g. "MUBEEN_E_RATE_LIMITED"
}
```

---

## Privacy & Data Collection

### What the SDK collects

| Category | Examples | PII? |
|----------|----------|------|
| Device info | Model, OS version, screen size, locale | No |
| App info | Bundle ID, version, install date | No |
| Identity | Keypair hash, vendor ID hash | Hashed |
| Network | Connection type, carrier | No |
| Integrity | Jailbreak indicators, tamper score | No |
| Linkage | Account ID, email, phone | SHA-256 hashed |
| Session | Session ID, event count, timing | No |

### What the SDK does NOT access

- GPS / location
- Contacts
- Photos / camera
- Microphone
- Advertising identifier (IDFA)
- Clipboard contents

### Privacy manifest

The SDK includes an Apple Privacy Manifest (`PrivacyInfo.xcprivacy`) declaring:

- **UserDefaults access** — for non-sensitive SDK state (registration status, session data)
- **No tracking** — `NSPrivacyTracking: false`
- **No tracking domains**

---

## FAQ

### When should I call `configure()`?

Once, at app launch. The `.task` modifier on your root view or `AppDelegate.didFinishLaunching` are ideal locations.

### Can I call `evaluate()` before registration completes?

Yes. If the device isn't registered yet, `evaluate()` will retry registration first. A provisional device token is used in the meantime.

### What happens when the device is offline?

Failed payloads are automatically queued (up to 50) and retried when connectivity returns. The SDK monitors network state and drains the queue when the device comes back online.

### Does the SDK work on jailbroken devices?

Yes. The SDK detects jailbreak indicators and reports them as risk signals. It does not block operation on jailbroken devices — the risk score reflects the elevated risk.

### What is the kill switch?

A server-side toggle that can disable SDK operations remotely. When active, `evaluate()` throws `MubeenSDKError.killSwitchActive`. The SDK fetches kill switch state during `configure()` and refreshes it periodically.

### How do I test in sandbox?

Set `environment: .sandbox` in your `MubeenConfig`. Sandbox returns mock verdicts and does not affect production data.

### What Swift concurrency model does the SDK use?

The SDK uses `async/await` throughout. All public methods are safe to call from any actor context. The delegate methods are dispatched on `@MainActor` for safe UI updates.

### How large is the SDK binary?

The XCFramework is approximately 485KB compressed. The SDK has zero external dependencies.

---

## Support

For integration support, contact [engineering@mubeen.ai](mailto:engineering@mubeen.ai).

For bug reports, include:
- SDK version (`1.0.0`)
- Error code (e.g., `MUBEEN_E_NETWORK`)
- Device model and iOS version
- Steps to reproduce
