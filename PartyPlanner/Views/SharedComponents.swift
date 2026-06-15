import SwiftUI

struct MetricTile: View {
    var title: String
    var value: String
    var icon: String
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct InsightCard: View {
    var insight: PlanningInsight

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: insight.severity.icon)
                .font(.headline)
                .foregroundStyle(insight.severity.color)
                .frame(width: 32, height: 32)
                .background(insight.severity.color.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline.weight(.semibold))
                Text(insight.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct SmartActionCard: View {
    var action: SmartAction

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: action.kind.icon)
                .font(.headline)
                .foregroundStyle(action.kind.color)
                .frame(width: 36, height: 36)
                .background(action.kind.color.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 5) {
                Text(action.title)
                    .font(.subheadline.weight(.semibold))
                Text(action.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct TimelineMomentRow: View {
    var moment: TimelineMoment
    var ownerName: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 4) {
                Image(systemName: moment.kind.icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(moment.kind.color)
                    .frame(width: 30, height: 30)
                    .background(moment.kind.color.opacity(0.14), in: Circle())
                Rectangle()
                    .fill(moment.kind.color.opacity(0.25))
                    .frame(width: 2, height: 28)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(moment.startsAt, style: .time)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    if moment.isCritical {
                        StatusPill(text: "Critical", color: .orange)
                    }
                }
                Text(moment.title)
                    .font(.subheadline.weight(.semibold))
                Text("\(ownerName) - \(moment.notes)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct LinearMeter: View {
    var title: String
    var value: String
    var ratio: Double
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(value)
                    .font(.caption.weight(.semibold))
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.quaternary)
                    Capsule()
                        .fill(color)
                        .frame(width: proxy.size.width * min(max(ratio, 0), 1))
                }
            }
            .frame(height: 8)
        }
    }
}

struct StatusPill: View {
    var text: String
    var color: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.14), in: Capsule())
            .foregroundStyle(color)
    }
}

struct SectionHeader: View {
    var title: String
    var icon: String
    var color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .font(.headline)
            Spacer()
        }
    }
}

extension Decimal {
    var currencyText: String {
        let number = NSDecimalNumber(decimal: self)
        return number.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
}
