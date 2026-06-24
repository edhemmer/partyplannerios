# Party Planner iOS

A native SwiftUI foundation for a professional party and event execution planner.

The app is designed around one core idea: the event owner frames the event, the app generates a deterministic operating plan, and invited helpers can update only their own responsibilities while everyone stays coordinated through updates, chat, notes, calendar, maps, notifications, supplies, meals, and expenses.

## Competitive Notes

Current tools tend to solve one slice well:

- Invite apps make invitations, RSVPs, reminders, and event pages fun.
- Shared calendar tools help groups coordinate time and polls.
- Wedding planning tools provide large checklists and vendor workflows.
- Task management tools handle checklist execution.
- Shared expense tools handle group expenses.
- Calendar platforms own the calendar layer.

This app combines the missing operational layer: owner-controlled event setup, AI-assisted supply and meal quantities, assigned responsibilities, controlled expense allocation, receipts, live updates, public/private notes, guest and helper contacts, venue/directions, and execution-day accountability.

## Product Pillars

- Owner-controlled master plan for venue, guest count, event type, responsibilities, and expense policy.
- Deterministic planning intelligence that proposes supplies, quantities, meals, amenities, setup, breakdown, and timeline tasks.
- Permission-aware collaboration so helpers edit only their responsibilities, receipts, notes, and private messages.
- Transparent expenses with event total, category totals, per-user out-of-pocket, and "your share".
- Native integrations for EventKit calendar, MapKit directions, UserNotifications, and future CarPlay-compatible navigation handoff.
- Beautiful SwiftUI interface with colorful section identity, clear icons, and fast operational scanning.

## Mobile Flow

The app is intentionally organized around how a host uses it on a phone:

1. `Command`: readiness score, priority work, venue, live updates, and planning intelligence.
2. `Plan`: event setup, AI-style questions, generated supplies, and plan review.
3. `Crew`: user contacts, roles, assigned responsibilities, and helper-owned checklists.
4. `Money`: receipts, totals, category summaries, and share math.
5. `More`: public/private board messages, support, training, definitions, and quality resources.

The goal is not to make users browse data. The app should always answer: what matters now, who owns it, what is missing, and what changed.

## Differentiators

- `Next Best Actions`: the host sees the highest leverage actions before anything else.
- `RSVP Confidence`: headcount is tied to food, drinks, seats, dietary notes, and cost planning.
- `Run of Show`: the event has an execution timeline, not just a date and a checklist.
- `Budget Health`: expenses are compared against category and event targets.
- `Permission-Aware Crew Work`: helpers update their assigned pieces without taking over the master plan.
- `Operational Intelligence`: the app flags missing owners, missing supplies, blocked work, missing receipts, and weak party sections.
- `Built-In Training`: searchable support explains roles, responsibilities, expenses, privacy, and event-day workflows.
- `Live Trust`: realtime sync, trust score, reliability signals, and audit history show whether the plan is current and accountable.

## Source Layout

- `PartyPlanner/PartyPlannerApp.swift` starts the app.
- `PartyPlanner/Models` contains event, user, meal, supply, task, note, and expense models.
- `PartyPlanner/Services` contains deterministic planning, expense allocation, permissions, updates, and integration adapters.
- `PartyPlanner/Views` contains the native SwiftUI app shell and feature screens.
- `docs/HELP_SUPPORT_STRATEGY.md` defines the help and training direction.
- `docs/MARKET_REVIEW.md` captures market gaps and product differentiation without naming competitors.
- `docs/PRODUCTION_TRUST_CORPUS.md` defines accuracy, reliability, and launch-stability expectations.
- `docs/RELEASE_READINESS.md` defines build, data, UX, and launch gates.
- `docs/WEB_COMPANION_REVIEW.md` reviews the related web prototype and identifies what should be ported or kept separate.
- `PartyPlanner/Fixtures` contains a realistic sample event for previews and local development.

## Implementation Status

This repository currently contains the first native SwiftUI implementation pass. It is ready to move into an Xcode iOS app target on macOS. Local compilation was not run here because this Windows workspace does not include Xcode or the iOS SDK.
