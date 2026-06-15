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
