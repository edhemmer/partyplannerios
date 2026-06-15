# UI Design Direction

Party Planner should feel premium, alive, and trustworthy. The interface should be fun enough for social planning but structured enough for serious event execution.

## Design Attributes

- Electric: confident color, energetic icons, and lively command surfaces.
- Premium: rich gradients, glass-like panels, careful spacing, and strong hierarchy.
- Mobile-first: key answers are visible without deep navigation.
- Trustworthy: sync, audit, receipt, assignment, and readiness signals are always clear.
- Practical: the UI never hides what the host needs to do next.

## Visual System

- Use `PartyTheme` colors instead of one-off random colors.
- Use `premiumSurface` for repeated cards and high-value content blocks.
- Use colorful icon containers to make sections scannable.
- Keep corner radii tight and consistent.
- Avoid generic gray-only cards unless content is intentionally low-priority.
- Keep the footer to five primary tabs on iPhone. Secondary tools belong behind `More`.

## Command Screen Standard

The Command screen is the premium first impression. It should show:

- Event identity and host role.
- Readiness score.
- Trust score.
- Live sync state.
- Next best actions.
- Run of show.
- Priority work.
- Venue and updates.

## Accessibility

- Do not rely on color alone for status.
- Pair every key status with text and an icon.
- Keep text sizes readable on compact phones.
- Avoid decorative elements that interfere with content.
