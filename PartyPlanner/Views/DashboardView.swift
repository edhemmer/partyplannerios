import SwiftUI
import MapKit

struct DashboardView: View {
    @Environment(EventStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                metrics
                VenueMapView(venue: store.event.venue)
                timeline
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
            Text("\(store.event.guestCount) guests • \(store.event.ageGroup)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                Label(store.event.venue.name, systemImage: "mappin.and.ellipse")
                Spacer()
                Text(store.event.startsAt, style: .date)
            }
            .font(.callout.weight(.medium))
        }
        .padding()
        .background(LinearGradient(colors: [.pink.opacity(0.18), .orange.opacity(0.18), .cyan.opacity(0.14)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 8))
    }

    private var metrics: some View {
        let expense = ExpenseAllocator.summarize(event: store.event)
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricTile(title: "Responsibilities", value: "\(store.event.responsibilities.count)", icon: "checklist", color: .green)
            MetricTile(title: "Meals", value: "\(store.event.meals.count)", icon: "fork.knife", color: .orange)
            MetricTile(title: "Supply Items", value: "\(store.event.supplies.count)", icon: "cart", color: .cyan)
            MetricTile(title: "Event Total", value: expense.eventTotal.currencyText, icon: "receipt", color: .pink)
        }
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Next Up", icon: "clock", color: .blue)
            ForEach(store.event.responsibilities.sorted(by: { $0.dueDate < $1.dueDate }).prefix(4)) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.kind.icon)
                        .frame(width: 32, height: 32)
                        .background(item.kind.color.opacity(0.16), in: RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.subheadline.weight(.semibold))
                        Text("\(store.event.userName(for: item.ownerID)) • \(item.status.rawValue)")
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
}

#Preview {
    NavigationStack { DashboardView() }
        .environment(EventStore(sampleEvent: .summerBirthday))
}
