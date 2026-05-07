# Maps QR Generator

A cross-platform Flutter app that generates QR codes for Google Maps locations. Scan the QR code on any device to open the location directly in the Google Maps app (or fall back to the browser).

## Features

- **Universal Google Maps Links** — Generates `https://www.google.com/maps/search/?api=1&query=...` URLs that work on Android, iOS, and Web
- **Real-time QR Preview** — QR code updates live as you type
- **Branded QR Codes** — Google Maps icon embedded in the center of the QR code
- **Input Validation** — Validates coordinate format and sanitizes all inputs (URL-encoded)
- **Cross-platform Export** — Share/save PNG on mobile, browser download on web
- **Test Link Button** — Open the generated link directly to verify it works

## Supported Input Formats

| Input | Example |
|-------|---------|
| Coordinates | `37.7749,-122.4194` |
| Place name | `Eiffel Tower` |
| Address | `1600 Amphitheatre Parkway, Mountain View` |

## Getting Started

### Prerequisites

- Flutter SDK (3.11+)
- Android Studio / Xcode (for mobile builds)
- Chrome (for web builds)

### Installation

```bash
git clone https://github.com/kp-abhi/qr-map-generator.git
cd qr-map-generator
flutter pub get
```

### Run

```bash
# Mobile
flutter run

# Web (CanvasKit renderer configured in index.html)
flutter run -d chrome
```

## Project Structure

```
lib/
├── main.dart              # App UI, QR generation, validation
├── export_qr.dart         # Conditional export (routes to web/mobile)
├── export_qr_mobile.dart  # Mobile: save to file + share sheet
├── export_qr_web.dart     # Web: browser download via anchor element
└── export_qr_stub.dart    # Stub for unsupported platforms
```

## Dependencies

| Package | Purpose |
|---------|---------|
| `pretty_qr_code` | Customizable QR code rendering with center image support |
| `url_launcher` | Open/test generated Google Maps links |
| `share_plus` | Native share sheet on mobile |
| `path_provider` | Temp file storage for PNG export |
| `web` | Browser download on Flutter web |

## Platform Configuration

- **Android** — `AndroidManifest.xml` includes `<queries>` for `com.google.android.apps.maps` to enable intent resolution
- **iOS** — `Info.plist` includes `LSApplicationQueriesSchemes` for `comgooglemaps` and `https`
- **Web** — `index.html` configured for CanvasKit renderer

## How It Works

1. User enters a location (coordinates or place name)
2. Input is validated and URL-encoded
3. A universal Google Maps URL is constructed
4. QR code is rendered in real-time with the Maps icon overlay
5. On scan, the OS intercepts the HTTPS link and opens Google Maps (or falls back to browser)

## License

This project is open source and available under the [MIT License](LICENSE).

