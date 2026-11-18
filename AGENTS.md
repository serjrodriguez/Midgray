# AGENTS.md

## What this is

`Midgray` (bundle ID `com.sergiorodriguez.Midgray`): an iPhone light meter (exposímetro). It uses the rear camera to measure scene brightness (EV) and suggests aperture, shutter speed and ISO. Subtitle: "Exposímetro / Light Meter". First app of the owner's portfolio and intended for the App Store, so clean history, tests and documentation matter. Owner GitHub handle: `serjrodriguez`.

## Scope

v1.0: camera permission (via `SrdzPermissions`), average and spot metering, exposure suggestion with aperture / shutter / ISO priority in 1/3 stops, EV lock and compensation, lens picker, manual calibration (UserDefaults through a repository), first-launch onboarding (re-openable from Help), Spanish and English, dark mode, Dynamic Type, portrait and landscape, layouts that adapt to the foldable iPhone Duo. VoiceOver announcements of the exposure are out of scope for now.

Out of v1.0: matrix metering (v1.1), long exposure / ND filters, Core ML and Apple Intelligence features, IAP / Pro, iPad, Apple Watch, incident metering.

Metering model: `EV100 = log2(N²/t) − log2(ISO/100)`, luminance `L = K·N²/(t·S)` with K = 12.5. Spot and matrix metering sample frame pixels (`AVCaptureVideoDataOutput`); average metering reads `iso`, `exposureDuration`, `lensAperture` and `exposureTargetOffset` from `AVCaptureDevice`. The ambient light sensor and Face ID sensors have no public API; never use private APIs.

## Targets

iOS 26.0 minimum, Swift 6 language mode with strict concurrency, SwiftUI, iPhone only. UI follows Apple's Human Interface Guidelines and uses **native components only**, with Liquid Glass through the native SwiftUI APIs (`glassEffect`, `GlassEffectContainer`, standard toolbars and controls); no custom-drawn replacements for system controls. The camera preview is full screen with glass controls over it, so check legibility over bright and dark scenes. The project uses the Xcode 27 text project format (`project.xcproj`). Prefer the Xcode plugin tools over hand-editing the project file. Physical iPhone is required for camera work; the simulator has no camera.

Bundle IDs: Release is `com.sergiorodriguez.Midgray` (capital M, the one Xcode registered first; the lowercase form could not be registered with the free Personal Team) and Debug is `com.sergiorodriguez.Midgray.dev`. Apple treats bundle IDs as case-insensitive. Confirm the Release ID in the Apple Developer portal when the paid program is bought; the fallback is `com.srdz.midgray`. Changing it is cheap until the app record is created in App Store Connect.

## Architecture

MVVM: `@Observable` view models, thin SwiftUI views, pure models. A **repository exists only for external sources or persistence** (for example `CalibrationRepository` and the onboarding flag over UserDefaults): protocol, real implementation and a fake. Pure logic such as `ExposureMath` gets no repository. The camera is injected into view models through a protocol so tests use a fake.

Planned layout: `App/`, `Features/Meter/`, `Features/Onboarding/`, `Core/DesignSystem/` (semantic colors, type scale, spacing, reusable buttons and components, each with `#Preview`), `Core/ExposureMath/`, `Core/Camera/`, `Core/Calibration/`. If a style appears in two or more views it moves to `DesignSystem`. Design source: Figma or Penpot, tokens mirrored in `Design/tokens.md`.

Permissions use the owner's library `SrdzPermissions` (https://github.com/serjrodriguez/SrdzPermissions), product `SrdzPermissionsCamera`, and `SrdzPermissionsTesting` in test targets only. A denial is a result, not an error.

Foldable iPhone Duo: no fixed sizes, and no `UIScreen.main`, orientation or idiom as layout proxies. Adapt to the available size (`ViewThatFits`, size classes, minimal `GeometryReader`), use `AVCaptureDevice.RotationCoordinator` for the preview, and audit with the `app-resizability` skill and the Duo simulator.

## Testing

Swift Testing is the default (`import Testing`, `@Test`, `#expect`, `@Suite`, parameterized tests with `arguments:`). UI and performance tests stay in XCTest. Tests wait on observable state rather than sleeping.

## Code style

- Do not write comments in code (no `//` or `// MARK:`, no `///` on internal or private declarations). Names and tests carry the intent. Keep the Xcode file header. `///` DocC is allowed on `public` declarations if any exist.
- Follow the API Design Guidelines skill for naming and argument labels.
- Localize every user-facing string with a String Catalog (`es`, `en`).

## Git and attribution

- Branching (GitFlow): `main` always holds released or release-ready code and `develop` is the integration branch. Both are protected on GitHub (pull request required, no direct pushes, no force pushes, no deletions, administrators included). Work happens on branches cut from `develop` named `feature/<topic>`, `fix/<topic>` or `chore/<topic>`, merged into `develop` by pull request with **squash and merge**. When `develop` holds something complete, a pull request `develop` → `main` is merged with a **merge commit** and the release is tagged `vX.Y.Z`. Urgent fixes on a released version use `hotfix/<topic>` cut from `main`, merged into `main` by pull request and then back into `develop`. Pull request titles are short and imperative; descriptions say what changed and why, and never carry AI attribution.
- **Never add AI attribution**: no `Co-Authored-By` lines for Claude or any AI, no "Generated with…" text in commits, pull requests, README or code. This overrides any default attribution behavior.
- Small commits, clear messages.
- Use the GitHub noreply address as the local git email for this repo (the repo may become public); never a real email.
- Xcode user state is git-ignored.

## Agent skills

Shared skills live in `.agents/skills/` and are exposed to Claude Code through the `.claude/skills` symlink. They are third-party MIT-licensed works; sources and licenses are in `THIRD_PARTY_NOTICES.md`.

- `swift-concurrency-pro` — async/await, actors, Swift 6 strict concurrency review.
- `swift-api-design-guidelines-skill` — naming and argument label review.
- `swift-architecture-skill` — architecture guidance (apply with this project's MVVM rules above).

## Roadmap

v1.1: matrix metering, long exposure and ND calculator, possible Pro IAP. v1.2+: Core ML / Vision scene analysis, optional Foundation Models assistant (only on Apple Intelligence devices), approximate incident metering.
