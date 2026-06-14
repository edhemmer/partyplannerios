# Xcode Setup

Use the Mac for native iOS build, simulator, signing, and integrations.

## Create the App Target

1. Open Xcode.
2. Choose `Clone Git Repository`.
3. Use `https://github.com/edhemmer/partyplannerios.git`.
4. Create a new iOS App project if Xcode does not detect one yet.
5. Set the product name to `PartyPlanner`.
6. Use SwiftUI and Swift.
7. Add the existing `PartyPlanner` source folder to the app target.
8. Set the minimum deployment target to iOS 17 for the current `@Observable` code.

## Capabilities to Add

- Push Notifications, when remote notifications are implemented.
- Background Modes for remote notification handling later.
- Associated Domains later for invite links.
- Sign in with Apple when authentication moves beyond email.

## Packages to Add Later

- Supabase Swift SDK.
- Google Sign-In, if Google Calendar uses Google auth directly.

## Native Frameworks Already Planned

- EventKit for calendar integration.
- MapKit for venue maps and directions.
- UserNotifications for local and push notification surfaces.
- CarPlay can be considered later, but it may require Apple entitlement approval and should be scoped to navigation/directions support rather than general event planning UI.

