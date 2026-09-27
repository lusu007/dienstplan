# Liquid Glass integration

The app uses `liquid_glass_widgets` 1.7.2, pinned in `pubspec.yaml`, behind its shared UI components. Flutter 3.44.4 in CI meets the library's Flutter 3.41 minimum.

## App setup

- `main.dart` preloads the library shaders after initialization and before `runApp`.
- `MaterialApp.router.builder` installs `AppGlassTheme` above the navigator, so pages and overlay routes share configuration and accessibility preferences.
- The Material brightness resolver follows the app's chosen light/dark theme, including when it differs from the OS theme.
- `AppGlassTheme` owns the standard rendering quality and base material settings. Adaptive quality and premium rendering are not enabled in this migration.

## Component ownership

| App component | Library implementation | App responsibility |
| --- | --- | --- |
| `GlassContainer` | `GlassContainer` through `AppGlassSurface` | Existing padding, margins, radius and semantic tint |
| `GlassCard` | `AdaptiveGlass.vibrancy` | Lightweight content rows, selection, disabled states and interaction |
| `GlassDialogSurface` | `GlassContainer` through `AppGlassSurface` | Modal tint and radius |
| `GlassBottomSheet`, `GlassAppDialog` | Shared package-backed modal surface | Existing route, content layout, safe area, scrolling, transitions and dismissal contract |
| `GlassButtonSurface` | `GlassButton.custom`; passive package material when disabled | Existing bounds, action, disabled semantics, loading visibility and semantic colors |
| `GlassFilterChip` | `GlassChip` | Selection, label, checkmark and bounded width expansion |
| Icon chips, picker triggers and back buttons | `GlassButtonSurface` | Existing actions, labels and dimensions |
| Picker tiles | `AdaptiveGlass.vibrancy` through `AppGlassSurface` | Current/focused/disabled date states |

The app intentionally keeps its route shells instead of substituting `GlassModalSheet.show` or `GlassScaffold`: those introduce different sheet physics and layout conventions. The library owns the material inside the existing shells. Future changes to navigation behavior should be evaluated separately.

## Composition rules

- Feature screens import app adapters instead of importing the package directly.
- The package's `InheritedLiquidGlass.avoidsRefraction` handles controls inside a modal surface. The old app-specific blur scope has been removed.
- Do not add manual `BackdropFilter` recipes. A nested app surface uses the library's vibrancy fill.
- Calendar day cells, duty list rows, icon badges, native form fields and native switches remain content/control widgets with their existing behavior. Do not add refractive surfaces to every calendar day or row.
- Buttons paint their semantic outline once above the library material because its standard renderer does not paint `LiquidShape.side`. Disabled buttons use passive material to preserve caller-owned opacity and fully visible loading indicators.
- Explicit app tint roles use `GlassBodyMode.clear`. Selection outlines remain app-owned; the package supplies surface rendering and highlights.
- Screen scaffolds leave scroll-edge masking off by default. A viewport-wide `ShaderMask` over multiple glass groups reproducibly hid their contents on Android/Impeller. The standard glass renderer and original shapes remain enabled; sheets retain their existing separate mask policy.

## Validation

Settings uses a provider-independent category list (apart from the shared
backdrop's accent colors), with `/settings/:category` routes for the user's
schedule, partner, appearance, holidays, and app/privacy. Feature providers are
read by the selected subpage. Related rows share one `GlassCardGroup` surface;
their actions, native switches and existing selection sheets remain independent.
The normal `standard` renderer is unchanged. Navigation tests cover all five
categories, back navigation, lazy provider initialization, and shared surfaces.

Migration tests cover package integration, app-vs-OS brightness, accessibility preference propagation, disabled actions, selected/expanded chips, nested modal surfaces, stable sheet content during route animations and dialog return values. Existing calendar, picker, feedback and settings tests remain part of the full suite.

### Android device check (2026-09-27)

On an SM-S908B (S22 Ultra), Impeller Vulkan, the debug build reproduced missing
Settings card contents. The same source in a profile build displayed the contents
through five repeated openings. This does not establish the debug rendering fault's
root cause or guarantee that an intermittent fault is eliminated.

Initial attempts to compare scroll-mask and renderer variants are inconclusive:
a later APK inspection revealed stale Dart code in incremental Android builds.
Use a clean build and verify the packaged implementation before comparing variants.
The original screen's trace recorded 101 frames across five openings and four
returns, with Dart frame median 1.16 ms and raster median 35.26 ms / p95 115.96 ms.
These are short device traces, not isolated opening-only benchmarks. GPU resource
reclamation and intermediate image work dominated; fewer settings rows alone
is not a proven fix.

Keep `GlassQuality.standard` on Android and iOS as explicitly requested. A minimal
quality experiment was abandoned; do not enable it automatically as a workaround.
Further performance work should retain normal rendering and use profile builds.

### Confirmed Settings visibility workaround

A fresh profile build reproduced completely empty group interiors on
`App & Datenschutz` on the SM-S908B. Replacing passive superellipse shapes with
rounded rectangles did not help and was reverted. A second clean build changed
only `GlassScreenScaffold.fadeScrollEdges` to default to false: contents appeared
after a cold start, three subsequent openings, and scrolling to the lower group.
This identifies the viewport shader-mask composition as the trigger on this
device, without asserting a specific engine or driver defect. The normal
`GlassQuality.standard` setting is unchanged. Regression tests reject reintroducing
a ShaderMask around Settings categories and the shared feedback scaffold.
