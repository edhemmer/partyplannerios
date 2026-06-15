# Backend Plan

Supabase is the recommended backend for the first production version.

## Why Supabase Fits

- Auth for event owners, cohosts, helpers, and guests.
- Postgres for deterministic event data, expense math, assignments, meals, supplies, and notes.
- Row Level Security so users can only read/write what their event membership allows.
- Realtime subscriptions for updates when someone changes a responsibility, receipt, note, or supply.
- Storage buckets for receipt images and later event media.
- Edge Functions for controlled operations such as invite creation, push notification fanout, Google Calendar sync, and AI plan generation.
- Structured RSVP, budget, and run-of-show tables so planning intelligence can reason about headcount, timing, and spend.

## Setup Order

1. Create a Supabase project.
2. Run `supabase/schema.sql` in the SQL editor.
3. Create a private storage bucket named `receipts`.
4. Enable email auth first; add Sign in with Apple and Google later.
5. Add the iOS Supabase Swift SDK in Xcode using Swift Package Manager.
6. Store the Supabase URL and anon key in an app configuration file, not hard-coded in views.
7. Turn on Realtime only for the tables the app needs live: `event_updates`, `notes`, `responsibilities`, `expenses`, `supply_items`, `guest_invitations`, and `timeline_moments`.

## Recommended Edge Functions

- `create-event-invite`: creates a secure invite token and role.
- `accept-event-invite`: joins the authenticated user to an event.
- `generate-party-plan`: runs the planning intelligence and returns editable suggestions.
- `fanout-event-notification`: sends push notifications when scoped event data changes.
- `sync-calendar-event`: creates or updates calendar entries after user authorization.

## iOS Wiring Targets

- Replace the in-memory `EventStore` with a repository layer.
- Keep SwiftUI views talking to `EventStore`; let the store call repositories.
- Add optimistic updates for responsibilities, notes, and receipt uploads.
- Keep expense totals calculated client-side for instant UI, then verify with server-side views/functions later.

## Data Permission Rules

- Event owners and cohosts can manage the master event plan, venue, assignments, and expense allocation.
- Helpers can update responsibilities assigned to themselves.
- Members can add their own expenses and receipt metadata.
- Only owners/cohosts can assign expense splits to other users.
- Members can post public notes to their event board.
- Private messages are visible only to sender and recipients.
- Guests can see event details and public board content but cannot edit master planning data.
- Guests can update their own RSVP details, party size, and dietary notes.
- Owners/cohosts control event budget targets and the official run-of-show timeline.
