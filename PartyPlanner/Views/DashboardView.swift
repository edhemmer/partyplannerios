import SwiftUI
import MapKit

struct DashboardView: View {
    @Environment(EventStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                CommandActionRail()
                metrics
                liveTrust
                smartActions
                intelligence
                runOfShow
                priorityWork
                VenueMapView(venue: store.event.venue)
                updates
            }
            .padding()
        }
        .background(PartyTheme.frost)
        .navigationTitle("Party Command")
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            PartyTheme.commandGradient
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Label(store.event.preset.rawValue, systemImage: "sparkles")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(.white.opacity(0.22), in: Capsule())
                    Spacer()
                    Image(systemName: "party.popper.fill")
                        .font(.title2.weight(.bold))
                        .symbolEffect(.bounce, value: store.readinessScore)
                }
                .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 8) {
                    Text(store.event.title)
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text("\(store.eventTimingText) - \(store.event.guestCount) guests - \(store.event.ageGroup)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.82))
                }

                HStack(spacing: 10) {
                    Label(store.event.venue.name, systemImage: "mappin.and.ellipse")
                    Spacer()
                    Text(store.event.startsAt, style: .date)
                }
                .font(.callout.weight(.bold))
                .foregroundStyle(.white)

                ViewThatFits(in: .horizontal) {
                    HStack {
                        StatusPill(text: "\(store.readinessScore)% ready", color: readinessColor)
                        StatusPill(text: "\(store.trustScore)% trusted", color: trustColor)
                        StatusPill(text: store.canEditMasterPlan ? "Organizer" : "Helper", color: .blue)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            StatusPill(text: "\(store.readinessScore)% ready", color: readinessColor)
                            StatusPill(text: "\(store.trustScore)% trusted", color: trustColor)
                        }
                        StatusPill(text: store.canEditMasterPlan ? "Organizer" : "Helper", color: .blue)
                    }
                }
            }
            .padding(20)
        }
        .frame(minHeight: 250)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: PartyTheme.violet.opacity(0.28), radius: 24, x: 0, y: 14)
    }

    private var metrics: some View {
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricTile(title: "Open Work", value: "\(store.nextResponsibilities.count)", icon: "checklist", color: .green)
            MetricTile(title: "Confirmed", value: "\(store.confirmedHeadcount)", icon: "person.2.badge.gearshape", color: .orange)
            MetricTile(title: "Unpacked", value: "\(store.unpackedSupplyCount)", icon: "cart", color: .cyan)
            MetricTile(title: "Event Total", value: store.expenseSummary.eventTotal.currencyText, icon: "receipt", color: .pink)
        }
    }

    private var liveTrust: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Live Trust", icon: "shield.checkered", color: .green)
            HStack(spacing: 12) {
                MetricTile(title: "Sync", value: store.event.syncStatus.state.rawValue, icon: store.event.syncStatus.state.icon, color: store.event.syncStatus.state.color)
                MetricTile(title: "Trust Score", value: "\(store.trustScore)%", icon: "checkmark.shield", color: trustColor)
            }
            ForEach(store.reliabilitySignals.prefix(3)) { signal in
                ReliabilitySignalCard(signal: signal)
            }
            if !store.event.auditTrail.isEmpty {
                SectionHeader(title: "Recent Changes", icon: "clock.arrow.circlepath", color: .blue)
                ForEach(store.event.auditTrail.prefix(3)) { auditEvent in
                    AuditEventRow(event: auditEvent, actorName: store.event.userName(for: auditEvent.actorID))
                }
            }
        }
    }

    private var smartActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Next Best Actions", icon: "sparkles", color: .orange)
            if store.smartActions.isEmpty {
                PremiumEmptyState(title: "Everything looks calm", detail: "No urgent host actions are waiting right now.", icon: "checkmark.seal.fill", color: PartyTheme.leaf)
            } else {
                ForEach(store.smartActions.prefix(3)) { action in
                    SmartActionCard(action: action)
                }
            }
        }
    }

    private var intelligence: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Intelligence", icon: "brain.head.profile", color: .purple)
            ForEach(store.planningInsights.prefix(3)) { insight in
                InsightCard(insight: insight)
            }
        }
    }

    private var runOfShow: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Run of Show", icon: "clock.badge.checkmark", color: .indigo)
            ForEach(store.sortedTimeline.prefix(4)) { moment in
                TimelineMomentRow(moment: moment, ownerName: store.event.userName(for: moment.ownerID))
            }
        }
    }

    private var priorityWork: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Priority Work", icon: "bolt", color: .blue)
            if store.nextResponsibilities.isEmpty {
                PremiumEmptyState(title: "No open work", detail: "All responsibilities are marked done or ready.", icon: "checkmark.circle.fill", color: PartyTheme.leaf)
            } else {
                ForEach(store.nextResponsibilities.prefix(4)) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.kind.icon)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(item.kind.color.gradient, in: RoundedRectangle(cornerRadius: 9))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(PartyTheme.ink)
                            Text("\(store.event.userName(for: item.ownerID)) - \(item.status.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .premiumSurface(tint: item.kind.color)
                }
            }
        }
    }

    private var updates: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Live Updates", icon: "bell.badge", color: .pink)
            if store.event.updates.isEmpty {
                PremiumEmptyState(title: "No updates yet", detail: "Board posts and responsibility changes will appear here.", icon: "bell", color: PartyTheme.ember)
            } else {
                ForEach(store.event.updates.prefix(4)) { update in
                    Text(update.message)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(PartyTheme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .premiumSurface(tint: .pink)
                }
            }
        }
    }

    private var readinessColor: Color {
        if store.readinessScore >= 75 { return .green }
        if store.readinessScore >= 40 { return .orange }
        return .red
    }

    private var trustColor: Color {
        if store.trustScore >= 85 { return .green }
        if store.trustScore >= 65 { return .orange }
        return .red
    }
}

#Preview {
    NavigationStack { DashboardView() }
        .environment(EventStore(sampleEvent: .summerBirthday))
}
