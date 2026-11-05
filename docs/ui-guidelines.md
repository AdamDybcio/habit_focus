# UI guidelines

Goal: a modern, calm, tactile app that feels native-quality. These rules are for
humans and AI agents. Build on **Material 3** via `material_ui`; adopt Material 3
Expressive ideas (spring motion, shape variety, strong type hierarchy) where they
fit, but keep the design system ours.

## Principles

1. One source of truth: the theme. No hard-coded colors, fonts or magic spacing.
2. Content first. Few elements per screen, clear hierarchy, generous whitespace.
3. Motion explains, never decorates: it shows cause and effect and stays short.
4. Every interaction has feedback (state layer, motion, haptic where useful).
5. Every screen handles loading, empty, error and offline states.
6. Accessible by default (see checklist).

## Design tokens (live in `lib/core/theme/`)

- **Color:** `ColorScheme.fromSeed` with our seed color, light and dark. Support
  dynamic color (Material You) on Android as an option. Semantic colors
  (success, warning) go into a `ThemeExtension`, never raw `Color(0x..)` in widgets.
- **Typography:** one family, 4-5 sizes in use from the Material type scale
  (display, headline, title, body, label). Access via `Theme.of(context).textTheme`.
- **Spacing:** 4-pt grid. Constants `AppSpacing.xs=4, s=8, m=16, l=24, xl=32, xxl=48`.
- **Shape:** corner radii from the theme (`AppRadius`), consistent per component type.
- **Elevation:** prefer tonal surfaces (`surfaceContainer*`) over shadows.
- **Motion:** `AppDurations.short=150ms, medium=250ms, long=400ms`; curves from
  `Curves.easeOutCubic` / emphasized curves; springs for drag/release and
  morphing. Respect `MediaQuery.disableAnimations`.

## Layout

- Edge-to-edge with `SafeArea` and proper insets; keyboard-aware forms.
- Mobile-first, but use `LayoutBuilder`/`MediaQuery` breakpoints so tablets do
  not look broken. Never hard-code widths from one device.
- Prefer slivers for long scrolling screens; large collapsing headers over a
  plain `AppBar` where it helps the design.
- Navigation: `go_router`; bottom navigation only if the information
  architecture needs it. Predictive back on Android must keep working.

## Widget patterns

- One widget per file; small, focused, `const` constructors.
- Stateless by default; local UI state (animation controllers, focus nodes) in
  `StatefulWidget`; app state in BLoC.
- Compose, do not parameterize endlessly: when a widget gets more than ~6 props,
  split it.
- Shared building blocks live in `core/ui/` (e.g. `AppButton`, `AppCard`,
  `StateView` for loading/empty/error). Features reuse them instead of
  restyling raw Material widgets.
- Lists: `ListView.builder`/slivers, stable `Key`s for reorderable or dynamic items.
- Images/illustrations: vector (SVG) where possible, with explicit sizes.
- Custom painting (progress visual): `CustomPainter` with `shouldRepaint`
  implemented correctly, wrapped in `RepaintBoundary`.

## Interaction patterns

- Hold-to-confirm for check-ins: progress ring fills while pressed, haptic tick
  at start, stronger haptic at completion, cancel on release.
- Destructive actions: undo via snackbar instead of confirmation dialogs.
- Pull-to-refresh only where data is remote; optimistic updates for local-first data.
- Empty states have an illustration/icon, one sentence, and a primary action.

## Haptics

Use a `HapticsService` (domain interface, native implementation). Patterns:
`selection` (light tick), `success`, `warning`. Never spam: at most one haptic
per user action, and respect the system "vibration off" setting.

## Accessibility checklist

- Touch targets at least 48x48 dp.
- Contrast: text at least 4.5:1, large text at least 3:1, in both themes.
- Support system text scaling up to 200% without clipping.
- `Semantics` labels on icon-only buttons and custom-painted widgets.
- Do not rely on color alone to convey state.
- Screen reader order matches visual order; test with TalkBack and VoiceOver.

## Do / Don't

| Do | Don't |
|---|---|
| `Theme.of(context).colorScheme.primary` | `Color(0xFF6750A4)` in a widget |
| `AppSpacing.m` | `EdgeInsets.all(15)` |
| `const` constructors | helper methods returning widgets |
| Animate with implicit widgets first | One giant `AnimationController` for everything |
| Test in light, dark, large font | Only check on one emulator |

## Review checklist for UI changes

- [ ] Light and dark themes checked
- [ ] Polish and English strings (and long Polish words do not overflow)
- [ ] Loading, empty, error, offline states
- [ ] Large text scale and small screen (360 dp width)
- [ ] No jank in DevTools Performance (profile mode, real device)
- [ ] Widget test added or updated
