# Release Readiness

Party Planner should not be considered production-ready until these gates are satisfied on a Mac with Xcode and a real backend test project.

## Build Gates

- Xcode project opens cleanly.
- iOS simulator build succeeds.
- SwiftUI previews render for Command, Plan, Crew, Money, Board, and Support.
- No force unwraps in production paths.
- No secrets in source control.

## Data Gates

- Supabase schema runs without errors.
- Row Level Security blocks unauthorized writes.
- Owner, cohost, helper, and guest roles are tested separately.
- Expense math matches the production trust corpus.
- Audit events are recorded for important changes.
- Realtime subscriptions recover after disconnect.

## UX Gates

- First-time owner can create an event without reading external docs.
- Helper can understand assigned work within 30 seconds.
- Host can identify missing RSVPs, missing receipts, unassigned supplies, and blocked work from Command.
- Support search can find key terms such as receipts, split policy, RSVP, trust score, and run of show.

## Launch Gates

- Privacy policy drafted.
- Terms/support contact drafted.
- App Store screenshots created from real simulator screens.
- Push notification wording reviewed.
- Calendar and location permission copy reviewed.
- Crash reporting and analytics plan selected.
