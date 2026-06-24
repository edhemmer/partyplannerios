# Party Planner Web Companion

This is the production-oriented web companion shell for the native iOS Party Planner app.

It is intentionally built as a dependency-free app first so the design, domain boundaries, offline behavior, and Supabase contract can be reviewed before picking a full web framework. The UI can later move into React/Vite without changing the planning model.

## Role In The Product

- Web: organizer-heavy planning, bulk edits, templates, guest/lodging layout, meal math, shopping merge, budget review.
- iOS: day-of execution, push notifications, camera receipts, maps, offline/low-signal updates, helper updates, chat, and command view.
- Supabase: shared source of truth for events, members, roles, meals, supplies, expenses, notes, audit history, notification fanout, and sync state.

## Production Boundaries

- `src/domain.js` contains deterministic calculations that should eventually be mirrored by backend functions or shared test fixtures.
- `src/offlineStore.js` simulates the offline queue the iOS app also needs for low-signal event execution.
- `src/seed.js` provides a regression scenario with mixed adults/children, meals, lodging, supplies, expenses, responsibilities, and board updates.
- `sw.js` provides basic app-shell caching for web offline resilience.

## Supabase Wiring Plan

Replace local persistence with a small adapter that keeps the UI unchanged:

1. Auth session and profile lookup.
2. Event membership query with role.
3. Event snapshot load: event, venue, members, meals, meal items, supplies, tasks, rooms, expenses, notes.
4. Realtime subscriptions for owned responsibilities, shopping, expenses, notes, and event updates.
5. Mutation queue with retry, conflict detection, and audit row creation.
6. Storage bucket upload for receipt images with extracted line items requiring review.

The web companion should not bypass backend row-level security. UI permissions are only hints; Supabase policies must enforce ownership and organizer/cohost authority.

## Run Locally

Open `web/index.html` directly for static review, or serve the folder:

```sh
python -m http.server 5174 --directory web
```

Service worker caching only works when served over `http://localhost` or HTTPS.
