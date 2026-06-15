# Production Trust Corpus

This corpus defines the behaviors Party Planner must satisfy to be accurate, trustworthy, realtime-ready, and production stable. It should be used for manual QA, automated tests, database policy checks, and AI planning validation.

## Accuracy Principles

- Never silently change owner-controlled event data.
- Never assign expenses to users unless the event owner or cohost approves the split.
- Never hide missing receipts, unassigned supplies, stale RSVPs, or overdue work.
- Always show who owns a responsibility.
- Always show who paid an expense and how it is split.
- Always preserve audit history for important changes.
- Always keep helper edits scoped to their own responsibilities, receipts, notes, and RSVP data.
- Always prefer deterministic calculations over vague generated output.

## Event Setup Corpus

| Scenario | Input | Expected Result |
| --- | --- | --- |
| Small birthday | 12 guests, birthday preset, home venue | Supplies include plates, cups, napkins, ice, trash bags, setup, meal, and breakdown work. |
| Large family event | 75 guests, mixed ages | Quantities scale with guest count and beverage/food assumptions stay visible for owner review. |
| Formal event | Wedding or anniversary preset | Run of show includes setup, guest arrival, meal service, activity/music moments, and breakdown. |
| Unknown age group | Blank or custom age group | App does not crash; setup questions ask clarifying food/drink questions. |
| No venue coordinates | Venue has address only | Map/directions show fallback behavior and venue text remains visible. |

## Responsibility Corpus

| Scenario | User Role | Action | Expected Result |
| --- | --- | --- | --- |
| Owner edits venue | Owner | Change venue details | Allowed and audited. |
| Cohost assigns meal | Cohost | Assign meal owner | Allowed and audited. |
| Helper updates own duty | Helper | Change status to Ready | Allowed, update is published, audit event is recorded. |
| Helper edits someone else's duty | Helper | Change another helper status | Blocked by app permissions and backend RLS. |
| Guest edits master plan | Guest | Change supply list | Blocked. |
| Overdue task exists | Any member | Open Command | Reliability signal warns about overdue work. |

## Expense Corpus

| Scenario | Input | Expected Result |
| --- | --- | --- |
| Equal split | $120 expense, 4 members | Each share is $30. |
| Adults only | $100 expense, 3 adults, 2 children | Each adult share is $33.33 or equivalent rounded display; children are excluded. |
| Owner pays | $450 venue deposit | Owner share is $450; other users owe $0. |
| Assigned users | $90 activity split across 3 selected users | Each selected user share is $30; unselected users owe $0. |
| Missing receipt | Expense has no receipt image | Reliability signal marks receipt evidence for review. |
| Negative expense | Amount below zero | Blocked by app validation and database constraint. |

## RSVP And Quantity Corpus

| Scenario | Input | Expected Result |
| --- | --- | --- |
| Guest confirms party size | RSVP yes, party size 4 | Confirmed headcount increases by 4. |
| Guest says maybe | RSVP maybe, party size 2 | RSVP confidence shows maybe count but confirmed headcount does not include it. |
| No responses remain | 8 invited or no response | Next Best Actions recommends RSVP nudge. |
| Dietary notes exist | Vegetarian or allergy note | Crew view displays dietary note beside invitation context. |

## Realtime And Trust Corpus

| Scenario | Sync State | Expected Result |
| --- | --- | --- |
| Live sync | Live, no pending changes | Trust score is high and realtime signal is verified. |
| Offline device | Offline | Command warns that updates may be delayed. |
| Pending uploads | Pending receipt upload count above zero | Trust score drops and support should explain pending evidence. |
| Conflict exists | Conflict count above zero | Trust score drops and owner is prompted to review conflict. |
| Recent sync | Last sync under 5 minutes | Fresh Data signal is verified. |
| Stale sync | Last sync over 5 minutes | Fresh Data moves to review. |

## Audit Corpus

| Scenario | Action | Expected Audit Event |
| --- | --- | --- |
| Generate master plan | Owner taps Generate Master Plan | `regenerated_plan` event with target `Master Plan`. |
| Update responsibility | Helper changes own status | `updated_responsibility` event with target responsibility title. |
| Add expense | Member adds receipt | `added_expense` event with amount and category detail. |
| Post board note | Member posts public note | `posted_note` event. |
| Resolve conflict | Owner resolves edit conflict | `resolved_conflict` event. |

## Support And Training Corpus

| Scenario | Expected Help Coverage |
| --- | --- |
| New owner asks how to start | Getting Started guide explains event frame, plan generation, review, and invites. |
| Helper asks what they can edit | Helper Guide and Definitions explain scoped permissions. |
| User does not understand split policy | Definitions explain equal, adults-only, assigned users, and owner-pays concepts. |
| Host is uncertain whether data is current | Trust the live plan guide explains Live Trust, sync, audit trail, and conflicts. |

## Production Stability Checklist

- App launches with sample data and no network connection.
- App handles empty event lists, no venue, no meals, no supplies, no expenses, and no notes.
- Every `ForEach` uses stable identities.
- Expensive derived calculations are centralized in store/services, not scattered through view bodies.
- Database foreign keys are indexed.
- RLS policies are enabled on every user-facing table.
- Receipt storage is private.
- Calendar and notification permissions are requested only at the point of need.
- No API keys or secrets are committed.
- App supports graceful offline messaging before realtime sync is connected.
- All role-based edit paths are validated in both app code and database policies.
