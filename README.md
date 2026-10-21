# AssistCobrowse iOS SDK

Zoho Assist co-browsing for iOS, distributed as a binary `.xcframework`.

---

## Installation

Swift Package Manager.

In Xcode: **File › Add Package Dependencies…**, enter

```
https://github.com/zoho/AssistCobrowseSDK-iOS.git
```

pick **Up to Next Major Version** from `1.0.0`, and add the `AssistCobrowse` library to your
app target.

Or, in a `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/zoho/AssistCobrowseSDK-iOS.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "AssistCobrowse", package: "AssistCobrowseSDK-iOS")
        ]
    )
]
```

Resolving the package is a plain git clone: it vendors the prebuilt
`SDK/AssistCobrowse.xcframework` and `SDK/ZSocketHandler.xcframework` as binary targets, and
Xcode embeds both. Nothing is downloaded separately and nothing is compiled from source.

Minimum iOS 15.0.

---

## Credentials: base URL and widget code

**Both values come from the Assist co-browse web app.** Sign in to your co-browse account to
get them — they cannot be obtained from the SDK or from this repository.

| Value | Where to get it |
|---|---|
| `baseURL` | The origin of the co-browse web app you sign in to, e.g. `https://assist.zoho.com` |
| `widgetCode` | The co-browse widget settings in that web app — the long token identifying your app |
| `sessionKey` | The support code shown when an agent starts a session; the customer types it into your app |

`baseURL` and `widgetCode` are fixed for your account — set them once in your app.
`sessionKey` is per-session and entered by the user at runtime.

`baseURL` must be the origin only, with no trailing slash and no path — the SDK appends
`/api/v1/cobrowsewidget/join` to it:

```
https://assist.zoho.com          ✅
https://assist.zoho.com/         ❌  trailing slash
https://assist.zoho.com/api/v1   ❌  path already included
```

---

## Usage

```swift
import AssistCobrowse

let config = ZAssistCobrowseConfig(
    sessionKey: code,          // support code entered by the user
    widgetCode: widgetCode,    // from the co-browse web app
    baseURL:    baseURL        // from the co-browse web app
)

ZAssistCobrowseSession.shared.listener = self

ZAssistCobrowseSession.shared.register(config: config) { result in
    switch result {
    case .success:
        do { try ZAssistCobrowseSession.shared.startCapture() }
        catch { print(error.localizedDescription) }
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

End the session with `ZAssistCobrowseSession.shared.endSession()`.

Conform to `ZAssistCobrowseSessionListener` for state, participant and remote-control
callbacks. Mask sensitive UI with `.cobrowseRedacted()` on a SwiftUI view or a `UIView`, or
implement `ZAssistCobrowseDelegate` to return the views to redact for a view controller.

---

## Running the sample project

[`CobrowseDemo/`](CobrowseDemo) is a SwiftUI banking demo that exercises the whole flow:
support-code entry, the live sharing banner, the remote-control consent alert, and redacted
account details. It depends on the `Package.swift` next to it — a local package reference —
so it builds against the `.xcframework` in this repo rather than a published tag.

**1. Clone and generate the Xcode project**

The `.xcodeproj` is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
git clone https://github.com/zoho/AssistCobrowseSDK-iOS.git
cd AssistCobrowseSDK-iOS
brew install xcodegen
cd CobrowseDemo
xcodegen generate
```

**2. Set your credentials**

In [`CobrowseSession.swift`](CobrowseDemo/CobrowseDemo/CobrowseSession.swift), replace the two
static values with your own from the co-browse web app:

```swift
private static let widgetCode = "<your widget code>"
private static let baseURL    = "<https://your-assist-origin>"
```

**3. Run**

```bash
open CobrowseDemo.xcodeproj
```

Select a simulator or device and press ⌘R. From the command line:

```bash
xcodebuild -project CobrowseDemo.xcodeproj -scheme CobrowseDemo \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build
```

**4. Start a session**

1. In the co-browse web app, start a session — it shows a support code.
2. In the demo app, sign in (the login is mocked), then tap **Contact Support**.
3. Enter the support code and tap **Start**.

The app registers and begins capturing, and the sharing banner appears. On the web side the
screen is visible with account number, balance and card fields masked.
