# MubeenDeviceSDK — Integration Guide (2.0)

`import MubeenDeviceSDK` — the SDK is a signed XCFramework (iOS 15+ / macOS 12+, Swift 5.10+).
All entry points are static methods on `Mubeen`.

> **2.0 is a breaking change from 1.0.** The `evaluate()` → risk-verdict model is
> replaced by a persistent device ID and a one-way `sendFingerprint()`.

## 1. Configure

Call once at launch. It ensures the device ID exists and starts the background retry drain.

```swift
try await Mubeen.configure(
    MubeenConfig(
        apiKey: "pk_live_your_key",
        endpoint: URL(string: "https://fp.sa.mubeen.ai")!,
        environment: .production,          // or .sandbox
        enableJailbreakChecks: true,       // default true
        enableBehavioralSignals: false,    // default false
        logLevel: .warning                 // .verbose/.debug/.info/.warning/.error/.none
    )
)
```
`apiKey` and `endpoint` are required; the rest have defaults. Throws `MubeenSDKError.configurationInvalid` on an empty `apiKey`.

## 2. Device ID

```swift
let id = Mubeen.deviceId          // UUIDv7, never nil; lazily generated + persisted
```
- Stored in the **Keychain** — survives app reinstall (best-effort; a full device erase resets it).
- On iOS the final hex character is `2`. Available immediately, even before `configure()`.

```swift
let newId = Mubeen.resetDeviceId()   // wipe + regenerate (privacy/GDPR delete, logout)
```

## 3. Send a fingerprint

```swift
do {
    try await Mubeen.sendFingerprint(metadata: [
        "account_id": "user_12345",      // auto-detected + SHA-256 hashed for linkage
        "cart_value": "299.99"           // passed through as a custom signal
    ])
    // accepted (2xx) or queued for retry
} catch let error as MubeenSDKError {
    // terminal error (e.g. bad apiKey → 401). See error.errorCode.
}
```

Behavior:
- **2xx (200/202/204)** → accepted.
- **400 / 401 / 403** → throws `MubeenSDKError.serverError`.
- **429 / 5xx / offline** → enqueued and retried automatically; the call returns.
- Throws `MubeenSDKError.killSwitchActive` if the SDK is disabled via remote config.

### Metadata & linkage
Keys `account_id`, `payment_token_id`, `email`, `phone` are auto-detected and **SHA-256 hashed** before transmission. Any other keys pass through as custom string signals.
**Never put raw PII in other keys** — only the four recognized keys are hashed.

## 4. Observability (optional)

```swift
final class Monitor: MubeenSDKDelegate {
    func mubeenSDKDidSendRequest(path: String, bodySize: Int) { }
    func mubeenSDKDidReceiveResponse(path: String, statusCode: Int, durationMs: Int) { }
}
Mubeen.delegate = Monitor()   // MainActor-dispatched; no request/response bodies exposed
```

## 5. Errors

`MubeenSDKError` cases carry a stable `errorCode` string (e.g. `MUBEEN_E_SERVER`, `MUBEEN_E_KILL_SWITCH`, `MUBEEN_E_NOT_CONFIGURED`) for logging and support.

## 6. Privacy

- Linkage values are **SHA-256 hashed on-device** — no plaintext PII is transmitted.
- The SDK does **not** access GPS, contacts, photos, camera, or microphone.
- `device_id` is a persistent, linkable identifier for fraud prevention. The framework bundles a **privacy manifest** (`PrivacyInfo.xcprivacy`). If you pass linkage metadata (`account_id`/`email`/`phone`), declare those data types in **your app's** privacy nutrition label. Provide a deletion path via `Mubeen.resetDeviceId()`.

## Support

engineering@mubeen.ai
