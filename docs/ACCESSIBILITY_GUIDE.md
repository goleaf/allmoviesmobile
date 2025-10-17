# Accessibility Implementation Guide

This guide turns the accessibility items from the QA checklist into concrete implementation tasks for the Flutter app. Each subsection explains why the requirement matters, how to wire it up in Flutter, and what to verify manually.

## Screen reader support (semantic labels)
- Use `Semantics` (and when needed `MergeSemantics`) to provide readable labels for custom widgets, carousels, and grouped content.
- Favor widgets with built-in semantics (`ListTile`, `ElevatedButton`) but override `semanticsLabel`, `tooltip`, or `Semantics(label: ...)` when the visible text is ambiguous.
- Ensure state is voiced: expose `value`, `checked`, `inMutuallyExclusiveGroup`, and `enabled` flags where applicable.
- Test with TalkBack/VoiceOver and Android/iOS screen reader emulators to confirm the reading order and announced information match visual intent.

## High contrast mode
- Extend `ThemeData` with a dedicated high-contrast palette (e.g., `ThemeData.highContrastLight()`/`highContrastDark()`) and expose it alongside the existing light/dark/system choices.
- Keep contrast ratios ≥ 4.5:1 for text and ≥ 3:1 for large UI; lint color choices with tools such as the Flutter `flutter_test` accessibility guidelines or external contrast checkers.
- Avoid using semi-transparent overlays as the only state indicator; pair with icons or patterns that remain legible on dark/bright backgrounds.

## Font scaling
- Respect `MediaQuery.textScaleFactor`; never clamp it unless the layout breaks completely. Replace fixed heights with `Flexible`, `Wrap`, or `FittedBox` where necessary.
- Audit text-heavy screens (details, biographies, settings) to ensure content reflows without clipping when the device is set to 200%+ font size.
- Prefer `LayoutBuilder` with responsive breakpoints rather than hard-coded font sizes to keep cards and chips legible.

## Keyboard navigation support
- Wrap root navigable areas in `FocusTraversalGroup` and ensure widgets have a reachable `FocusNode`.
- Provide explicit `onKey` handlers for horizontal lists/carousels to support arrow key navigation and `enter` activation.
- Keep focus order predictable: use `FocusTraversalOrder` or `OrderedTraversalPolicy` when visual ordering does not match build order.

## Focus indicators
- Allow Flutter’s default focus highlights to render; avoid wrapping focusable widgets in `GestureDetector`/`InkWell` without `focusColor` or `focusNode`.
- For custom components, add a `Focus` widget plus `AnimatedContainer` (or `DecoratedBoxTransition`) to draw a visible outline that meets contrast requirements.
- Verify in light, dark, and high-contrast themes that the indicator remains visible against adjacent colors.

## Alternative text for images
- For poster/profile images that convey essential information, pass a `semanticLabel` (`Image.asset(..., semanticLabel: ...)`) or wrap the image in `Semantics`.
- Mark purely decorative visuals with `excludeFromSemantics: true` to reduce noise for screen reader users.
- Provide fallbacks when images fail to load (placeholder icon + readable text) so accessible names remain available.

## Landmark navigation
- Use `Semantics(container: true)` and `header: true` on section titles (`Text` in `Semantics`) to create logical navigation landmarks.
- For scaffold-level structure, set `Scaffold`’s `appBar` title to describe the route and call `ModalRoute.of(context)?.addLocalHistoryEntry` to ensure the screen name is announced on push.
- Give drawer/navigation rails `Semantics` roles so screen readers announce them as navigation regions.

## Descriptive button labels
- Replace generic copy (“View”, “More”) with context-specific text (“View Cast Details”) and mirror it in the semantic label.
- When using icon-only actions, add `Tooltip` plus `Semantics(label: ...)` to describe the action, including state (“Add to watchlist, currently off”).
- Ensure dialog actions differentiate confirm vs. dismiss actions for assistive tech users.

## ARIA-like properties (Flutter semantics roles)
- Expose control roles via semantics: `button`, `link`, `image`, `toggle`, `slider`, `progressbar`, etc., using `Semantics(button: true, ...)`.
- Set `liveRegion` (`assertiveness` in semantics) for toast/snackbar equivalents that should be announced immediately.
- Reflect loading states with `Semantics(value: 'Loading...')` or `progress: true` so screen readers track async operations.

## Color-blind friendly palettes
- Test palettes with simulators (e.g., Flutter DevTools color blindness overlay) to ensure information is not color-exclusive.
- Use redundant cues (icons, text labels, patterns) for status indicators such as genres, ratings, or availability badges.
- Avoid red/green and blue/yellow pairs without secondary differentiation; choose color scales that preserve contrast under deuteranopia/protanopia/tritanopia filters.

## QA spot checks
- Run automated accessibility tests (`flutter_accessibility`) where feasible, but always supplement with manual checks on both Android and iOS.
- Validate the checklist during regression cycles: screen readers, large fonts, high contrast, keyboard traversal, and color simulations should all be part of smoke tests.
- Document any deliberate deviations (e.g., custom gestures) with a mitigation plan or alternative affordance.
