# Midgray

Exposímetro / Light Meter for iPhone, built with SwiftUI.

Midgray uses the rear camera to measure the light of a scene and suggests the exposure (aperture, shutter speed and ISO) for a photograph.

> First app of my iOS portfolio. Feature work for v1.0 is mostly in place; it is not on the App Store yet.

## Features

- Average and spot metering
- Auto, aperture, shutter and ISO modes in 1/3 stops, with equivalent exposures
- Hold the reading and apply exposure compensation
- Lens picker and manual calibration
- First-launch onboarding, replayable from Settings
- Spanish and English, dark interface, Dynamic Type and VoiceOver labels
- Liquid Glass interface with native components and system toolbar actions
- No accounts, no analytics, no data collection

## Still to do before v1.0

- Validate the readings against a reference meter or camera
- Landscape layout
- Layouts that adapt to the foldable iPhone Duo
- App Store listing and TestFlight

## Tech

- Swift 6 with strict concurrency, SwiftUI, iOS 26+
- MVVM, repositories only for persistence
- The camera sits behind a protocol, so view models are tested with fake sensors
- Permissions with [SrdzPermissions](https://github.com/serjrodriguez/SrdzPermissions)
- Swift Testing

## Project layout

```
Midgray/
  App/
  Core/       shared modules: camera, exposure math, calibration, settings, design system
  Features/   meter, settings, onboarding, camera access
  Resources/
MidgrayTests/
Design/       design notes and icon layers
```

## Running

Open `Midgray.xcodeproj` with Xcode 27. The camera needs a physical iPhone; the simulator uses simulated readings.

## Privacy and support

- [Privacy policy](docs/privacy-policy.md)
- [Support](docs/support.md)
