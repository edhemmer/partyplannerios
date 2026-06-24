# Web And iOS Shared Architecture

## Product Split

The native iOS app and web companion should feel like one product with two optimized surfaces.

- iOS is the event execution app: low-signal updates, push notifications, camera receipts, maps, day-of command view, helper checkoffs, chat, and quick edits.
- Web is the organizer planning console: bulk edits, templates, lodging layout, meal scaling, shopping aggregation, budget review, guest/contact cleanup, and pre-event setup.
- Supabase is the shared source of truth for auth, roles, event state, realtime updates, receipt storage, audit history, and permissions.

## Offline Strategy

iOS needs full offline-first behavior because setup, shopping, lodging, and venue areas can have weak signal.

The shared pattern should be:

1. Load an event snapshot for the authenticated member.
2. Persist the snapshot locally.
3. Write user actions to a local mutation queue first.
4. Optimistically update the UI.
5. Retry queued mutations when connectivity returns.
6. Mark conflicts when the backend rejects or supersedes a mutation.
7. Record successful mutations as audit events.

The web companion includes a lightweight version of this pattern in `web/src/offlineStore.js`. The native app should use the same concept with durable local storage rather than relying on a web cache.

## Shared Data Contract

The Supabase schema now includes production structures for:

- Event members and roles.
- Venue and budget.
- Responsibilities and checklist items.
- Meals with per-adult, per-child, fixed-quantity, buffer, category, and equipment/ingredient fields.
- Supply items and generated shopping lines.
- Shopping line source links back to meal items, supplies, or staples.
- Lodging and lodging rooms with payer and occupant support.
- Expenses, splits, and receipt paths.
- Event templates.
- Sync mutations.
- Notifications.
- Notes and event updates.
- Audit events.

## Permission Model

Backend RLS must be the authority.

- Owners and cohosts manage the master event plan.
- Helpers and guests can read event state when they are members.
- Helpers and guests can update only assigned responsibilities, assigned shopping items, owned meal ingredients, their own expenses, receipts, and notes.
- Expense split assignment stays organizer/cohost controlled.
- Templates are private to their owner.
- Notifications are readable only by their recipient.

The UI should mirror these permissions for clarity, but it must never be the only enforcement layer.

## Planning Logic

Deterministic planning logic should be implemented in one backend-tested contract and mirrored in clients only for instant feedback.

Required shared calculations:

- Meal quantities from adults, children, fixed amounts, units, and buffer percent.
- Staple quantities from event duration, headcount, and meal services.
- Shopping aggregation across meals, supplies, and staples.
- Lodging shares from rooms, occupants, payer, and room price.
- Expense split math with penny-perfect rounding.
- Trust score and readiness signals.
- Notification fanout when owned portions change.

## Web Companion Scope

The current `web` app is not a separate backend product. It is the organizer-facing companion shell that will later connect to the same Supabase project as iOS.

It currently provides:

- Multi-panel command dashboard.
- Meal scaling and ingredient math.
- Merged shopping list.
- Offline queue simulation.
- Receipt capture control.
- Venue directions handoff.
- Crew ownership inspector.
- Expense and settlement preview.
- Trust and sync status.
- Basic service-worker app shell caching.

## Next Build Step

The next implementation pass should replace the web shell's local store with a Supabase adapter while keeping the UI unchanged:

1. Auth session.
2. Profile and event membership query.
3. Event snapshot query.
4. Realtime subscriptions.
5. Mutation queue drain.
6. Receipt upload.
7. Audit event insert.
8. Notification insert or server-side fanout.
