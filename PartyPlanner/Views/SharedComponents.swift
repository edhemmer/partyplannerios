import SwiftUI

struct MetricTile: View {
    var title: String
    var value: String
    var icon: String
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 8))
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(PartyTheme.ink)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .premiumSurface(tint: color)
    }
}

struct CommandActionRail: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                railButton(title: "Invite", icon: "paperplane.fill", color: PartyTheme.ember)
                railButton(title: "Assign", icon: "person.crop.circle.badge.plus", color: PartyTheme.violet)
                railButton(title: "Receipt", icon: "receipt.fill", color: PartyTheme.lagoon)
                railButton(title: "Update", icon: "megaphone.fill", color: PartyTheme.marigold)
            }
            .padding(.horizontal, 1)
            .padding(.vertical, 2)
        }
    }

    private func railButton(title: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 12))
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(PartyTheme.ink)
        }
        .frame(width: 78)
        .padding(.vertical, 10)
        .premiumSurface(tint: color)
    }
}

struct PremiumEmptyState: View {
    var title: String
    var detail: String
    var icon: String
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 10))
            Text(title)
                .font(.headline)
                .foregroundStyle(PartyTheme.ink)
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .premiumSurface(tint: color)
    }
}

struct ScreenIntroBanner: View {
    var title: String
    var detail: String
    var icon: String
    var color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(PartyTheme.ink)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .premiumSurface(tint: color, prominent: true)
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
        .premiumSurface(tint: insight.severity.color)
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
        .premiumSurface(tint: action.kind.color, prominent: true)
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
        .padding(12)
        .premiumSurface(tint: moment.kind.color)
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

struct ReliabilitySignalCard: View {
    var signal: ReliabilitySignal

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: signal.state.icon)
                .font(.headline)
                .foregroundStyle(signal.state.color)
                .frame(width: 34, height: 34)
                .background(signal.state.color.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 4) {
                Text(signal.title)
                    .font(.subheadline.weight(.semibold))
                Text(signal.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            StatusPill(text: signal.state.rawValue, color: signal.state.color)
        }
        .padding(12)
        .premiumSurface(tint: signal.state.color)
    }
}

struct AuditEventRow: View {
    var event: AuditEvent
    var actorName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(event.action.rawValue)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(event.createdAt, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text("\(actorName) - \(event.target)")
                .font(.caption.weight(.medium))
            Text(event.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .premiumSurface(tint: .blue)
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
            .background(color.gradient, in: Capsule())
            .foregroundStyle(.white)
    }
}

struct SectionHeader: View {
    var title: String
    var icon: String
    var color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 7))
            Text(title)
                .font(.headline)
                .foregroundStyle(PartyTheme.ink)
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
