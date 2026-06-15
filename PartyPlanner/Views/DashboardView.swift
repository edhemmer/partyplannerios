import SwiftUI
import MapKit

struct DashboardView: View {
    @Environment(EventStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                metrics
                intelligence
                priorityWork
                VenueMapView(venue: store.event.venue)
                updates
            }
            .padding()
        }
        .navigationTitle("Party Command")
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(store.event.preset.rawValue, systemImage: "sparkles")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.pink)
            Text(store.event.title)
                .font(.largeTitle.bold())
                .lineLimit(2)
            Text("\(store.event.guestCount) guests - \(store.event.ageGroup)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 10) {
                Label(store.event.venue.name, systemImage: "mappin.and.ellipse")
                Spacer()
                Text(store.event.startsAt, style: .date)
            }
            .font(.callout.weight(.medium))
            HStack {
                StatusPill(text: "\(store.readinessScore)% ready", color: readinessColor)
                StatusPill(text: store.canEditMasterPlan ? "Organizer" : "Helper", color: .blue)
            }
        }
        .padding()
        .background(LinearGradient(colors: [.pink.opacity(0.18), .orange.opacity(0.18), .cyan.opacity(0.14)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 8))
    }

    private var metrics: some View {
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricTile(title: "Open Work", value: "\(store.nextResponsibilities.count)", icon: "checklist", color: .green)
            MetricTile(title: "Meals", value: "\(store.event.meals.count)", icon: "fork.knife", color: .orange)
            MetricTile(title: "Unpacked", value: "\(store.event.supplies.filter { !$0.isPacked }.count)", icon: "cart", color: .cyan)
            MetricTile(title: "Event Total", value: store.expenseSummary.eventTotal.currencyText, icon: "receipt", color: .pink)
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

    private var priorityWork: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Priority Work", icon: "bolt", color: .blue)
            ForEach(store.nextResponsibilities.prefix(4)) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.kind.icon)
                        .frame(width: 32, height: 32)
                        .background(item.kind.color.opacity(0.16), in: RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.subheadline.weight(.semibold))
                        Text("\(store.event.userName(for: item.ownerID)) - \(item.status.rawValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
        }
    }

    private var updates: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Live Updates", icon: "bell.badge", color: .pink)
            ForEach(store.event.updates.prefix(4)) { update in
                Text(update.message)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var readinessColor: Color {
        if store.readinessScore >= 75 { return .green }
        if store.readinessScore >= 40 { return .orange }
        return .red
    }
}

#Preview {
    NavigationStack { DashboardView() }
        .environment(EventStore(sampleEvent: .summerBirthday))
}
