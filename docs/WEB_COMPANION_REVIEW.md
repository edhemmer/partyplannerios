# Web Companion Review

Reviewed repo: `edhemmer/party-perfect-planner`

## Recommendation

The web prototype is worth keeping, but it should be treated as a companion planning surface and product-pattern source, not copied directly into the native iOS app.

The strongest path is:

1. Keep the native iOS app as the primary event execution app for notifications, mobile updates, maps, day-of flow, receipt capture, and on-the-go coordination.
2. Use the web app as the larger-screen planning console for organizers who want faster setup, editing, duplication, templates, guest/lodging layout, meal planning, and settlement review.
3. Move shared logic into a production backend contract so iOS and web calculate quantities, assignments, expenses, and status from the same source of truth.

## High-Value Ideas To Port

The web prototype includes several features that should influence the native roadmap:

- Event duplication and save-as-template flows for repeatable parties, annual trips, birthdays, and recurring family events.
- Travel group presets with recurring attendees and cook rules.
- A lodging model with rooms, occupants, room prices, and payer assignment.
- Per-adult, per-child, fixed-quantity, and buffered meal item scaling.
- A kitchen execution plan that estimates prep effort, cook effort, sheet pans, burners, oven batches, and timing notes.
- Shopping aggregation that merges the same ingredient across multiple meals and keeps one responsible buyer.
- Trip-wide staples for pantry, condiments, disposables, drinks, and snacks.
- A personal "My Day" surface that filters the event into one user's schedule, tasks, shopping, and money.
- Settlement suggestions with participant balances and payment handles.
- A repository layer that makes a future backend swap easier than tightly coupling UI to storage.

## Do Not Port As-Is

These parts should not be merged directly into the iOS foundation:

- LocalStorage persistence. The native app needs Supabase-backed storage, row-level security, realtime updates, and durable audit history.
- Mock receipt parsing. Receipt capture must be real OCR/AI-assisted extraction with human review before posting expenses.
- Mock in-memory notifications. Event updates must become durable notification rows plus push delivery.
- UI-only permissions. Authorization rules must be enforced in the backend, then mirrored in the UI for clarity.
- Web route structure. The native app should keep mobile-first navigation and only borrow the product ideas.
- Encoding artifacts in labels and comments. Several strings contain mojibake and must be cleaned before reusing copy or seed data.
- Current split math without hardening. All money allocation needs penny-perfect rounding, deterministic residual handling, and tests.

## Production Integration Roadmap

Phase 1: Align the models.

- Add room/lodging entities to the iOS data model and Supabase schema.
- Add meal item scaling fields: per-adult, per-child, fixed quantity, unit, category, and buffer.
- Add shopping contribution metadata so one line can point back to multiple meals.
- Add staple definitions as versioned data instead of hardcoded UI-only assumptions.
- Add event template and duplicate-event support.

Phase 2: Move shared intelligence server-side.

- Implement deterministic quantity generation for meals, staples, beverages, disposables, and setup supplies.
- Implement shopping aggregation from meal items plus staples.
- Implement expense allocation with penny-perfect residual distribution.
- Implement lodging shares and settlement suggestions from the same backend rules used by iOS and web.
- Record every generated or changed plan with source, inputs, version, and audit event.

Phase 3: Make the web app a true companion.

- Replace LocalStorage with the shared Supabase schema.
- Use the same auth identities and event roles as iOS.
- Add realtime subscriptions for event board, shopping, tasks, expenses, and meal changes.
- Keep web optimized for organizer-heavy work: fast table editing, bulk assignments, template setup, guest import, lodging layout, and expense review.
- Keep iOS optimized for execution: push notifications, camera receipts, maps, CarPlay-safe directions, quick task updates, chat, and day-of command view.

Phase 4: Harden release quality.

- Add tests for quantity math, shopping aggregation, split math, permissions, and notification fanout.
- Add seeded regression scenarios for birthdays, weddings, anniversaries, reunions, holiday meals, weekend lodging, and mixed adult/child groups.
- Add offline/conflict behavior for user-owned updates.
- Add backend RLS tests proving guests can edit only their own responsibilities, expenses, receipts, shopping items, notes, and assigned meal ingredients.

## Feature Fit With Native App

The native app already has the right high-level direction: event organizer control, assigned responsibilities, expense capture, board/private notes, supply lists, trust signals, and a mobile command center. The web prototype strengthens the plan in four areas:

- Better organizer setup speed through templates, duplication, presets, and bulk planning.
- Better food planning through per-person meal math and cross-meal shopping aggregation.
- Better lodging and settlement handling for trips and multi-day events.
- Better personal execution through a "my day" view that collapses the full plan into one person's responsibilities.

## Decision

Use it. Do not merge it wholesale.

The web prototype should become either a future companion web app or a reference implementation for the next iOS feature pass. Its domain ideas are valuable, but production stability requires shared backend rules, tested calculations, real auth, real notifications, real receipt capture, and schema alignment before it becomes part of the app users rely on.
