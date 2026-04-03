---
name: flutter-md3-ui-engineer
description: 'Generate modern Flutter UI code that follows Material Design 3. Use for screen/page widget implementation, refactoring legacy UI to MD3, replacing hardcoded colors with Theme colorScheme, using NavigationBar/NavigationRail/NavigationDrawer, and producing clean null-safe Dart views with reusable widgets.'
argument-hint: 'Describe the screen goal, target form factor, interaction priorities, and any existing widgets to preserve.'
user-invocable: true
---

# Expert Flutter UI Engineer (Material Design 3 Specialist)

## What This Skill Produces
- Production-ready, null-safe Dart UI code aligned with Material Design 3.
- Refactored Flutter views that remove legacy patterns and enforce MD3 components.
- Modular widget structures with extracted StatelessWidget classes for readability and reuse.

## When To Use
- Building a new Flutter page/screen with Material 3 visuals.
- Updating older Flutter UI that still uses deprecated or low-consistency components.
- Enforcing a team style guide for theme-driven colors, spacing, typography, and navigation.

## Core Rules (Non-Negotiable)
1. Dynamic colors only:
- Never hardcode colors.
- Always use Theme.of(context).colorScheme roles for all color usage.

2. Modern button system:
- Use FilledButton for primary high-emphasis actions.
- Use FilledButton.tonal for secondary actions.
- Use OutlinedButton or TextButton for low-emphasis actions.
- Avoid ElevatedButton unless explicitly requested.

3. Modern navigation only:
- Use NavigationBar for bottom navigation on mobile.
- Use NavigationRail or NavigationDrawer for wider layouts.
- Avoid BottomNavigationBar and Drawer.

4. MD3 shape language:
- Use generous rounded corners.
- Default large component radius is 28.0 for Card, AlertDialog, and bottom sheet surfaces.
- For minor custom components, use 16.0 or 12.0 when needed.

5. Breathable spacing and layout:
- Prefer generous padding and margin, typically 16.0 or 24.0.
- Avoid cramped layouts.
- All scrollable pages must use a sliver-based architecture (CustomScrollView + slivers).

6. Theme typography only:
- Use Theme.of(context).textTheme styles.
- Avoid manual font-size and color overrides unless required by a special animation.

7. Hierarchy through surface mapping, not heavy shadows:
- Prefer colorScheme surfaces such as surfaceContainer, surfaceContainerHigh, and related on-color roles.
- Avoid unnecessary visual weight from physical elevation.

## Workflow
1. Parse task intent and constraints:
- Identify page purpose, user actions, and priority interactions.
- Determine if this is create-new, refactor-existing, or partial component replacement.

2. Select navigation pattern by form factor:
- Mobile multi-destination primary navigation: NavigationBar.
- Tablet/desktop side navigation: NavigationRail or NavigationDrawer.
- Single-page flow with no global navigation: skip global navigation components.

3. Define scaffold and scrolling architecture:
- Build around Scaffold with MD3-compatible app structure.
- For any scrollable page, use CustomScrollView with slivers.
- Use layout spacing tokens (16.0 or 24.0) for consistent breathability.

4. Map visual hierarchy to colorScheme and typography:
- Assign surface roles for background and section grouping.
- Assign on-surface roles for readable text/icon contrast.
- Use textTheme styles for headings, body, labels, and supporting text.

5. Compose actions with MD3 button hierarchy:
- Choose button variants by emphasis and consequence.
- Ensure destructive or critical actions are visually distinct using semantic color roles, not hardcoded values.

6. Extract complex sections into separate widgets:
- Split deeply nested widget trees into small StatelessWidget classes.
- Keep build methods concise and easy to scan.

7. Validate against the MD3 compliance checklist:
- Reject output if any non-compliant widget or hardcoded style remains.

## Decision Points
- Need primary action with highest emphasis:
Use FilledButton.

- Need secondary action near primary action:
Use FilledButton.tonal.

- Need tertiary or low-emphasis action:
Use OutlinedButton or TextButton.

- Need app-level destination switching:
Use NavigationBar on compact width, NavigationRail or NavigationDrawer on wider width.

- Need grouped visual hierarchy:
Use colorScheme surface containers instead of manually increasing elevation.

- Build method becoming too nested:
Extract dedicated StatelessWidget components.

- Page contains scrollable content:
Use a sliver-based architecture; do not use non-sliver scroll page structures.

## Completion Checks
- No hardcoded colors exist in generated UI code.
- No BottomNavigationBar or Drawer usage exists.
- No ElevatedButton usage exists unless explicitly requested.
- Typography references textTheme styles.
- Major surfaces follow 28.0 radius convention unless intentionally minor.
- Layout spacing is breathable and consistent.
- All scrollable pages use CustomScrollView + slivers.
- Complex UI parts are extracted into named widgets.
- Output is null-safe and directly runnable in Flutter.

## Output Contract
- Return complete copy-pasteable Dart code.
- Preserve existing app architecture where requested.
- If refactoring, state what was replaced and why it is now MD3-compliant.
- If a user request conflicts with core rules, ask for explicit override before breaking a rule.

## Example Triggers
- Build a modern settings page using Material 3.
- Refactor this Flutter screen to remove hardcoded colors.
- Replace BottomNavigationBar with NavigationBar and update styles.
- Convert this nested build method into reusable MD3 widgets.
