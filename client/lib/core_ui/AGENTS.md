# Core UI rules (design system, themes, DS components, preview)

Applies to `lib/core_ui/**`.

## Purpose
`lib/core_ui` is the design system:
- Theme setup (light/dark)
- Color/typography/spacing tokens
- DS components (buttons/inputs/cards/etc.)
- A preview page demonstrating DS components

Core UI must remain independent from features.

## Allowed dependencies
- Must not depend on:
  - `lib/domain/**`
  - `lib/data/**`
  - `lib/presentation/**`
- May use minimal `lib/core/**` utilities if necessary (prefer keeping core_ui self-contained).

## Directory conventions (recommended)
- `lib/core_ui/theme/` — tokens, theme definitions, theme mode handling
- `lib/core_ui/components/` — DS components (organized by component type)
- `lib/core_ui/preview/` — Design system preview page(s)

## DS component conventions (mandatory)
- File naming: `ds_*.dart`
- Type naming: `DS*`
- Components must be reusable and configurable via parameters.
- Do not re-create Flutter primitives inconsistently; DS should standardize spacing, typography, colors, radii.

## Theme conventions (mandatory)
- Provide both light and dark themes.
- Theme must map tokens consistently.
- Any theme switching state must be implemented in core_ui/theme (no feature dependency).
- Theme usage in the app must prefer DS tokens and ThemeData, not hardcoded colors.

## Preview (mandatory)
- Keep a DS preview page that demonstrates:
  - typography styles
  - basic components (buttons/inputs/cards)
  - spacing/layout primitives where applicable
- Preview must not depend on feature code.

## Prohibited patterns
- No feature imports.
- No routing configuration here.
- No business logic.

## Output quality
core_ui is a product: consistent naming, consistent styling, minimal duplication, high reusability.
