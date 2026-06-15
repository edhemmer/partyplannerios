import SwiftUI

enum PartyTheme {
    static let ink = Color(red: 0.10, green: 0.11, blue: 0.16)
    static let ember = Color(red: 1.00, green: 0.31, blue: 0.42)
    static let marigold = Color(red: 1.00, green: 0.70, blue: 0.22)
    static let lagoon = Color(red: 0.00, green: 0.66, blue: 0.74)
    static let violet = Color(red: 0.45, green: 0.29, blue: 0.95)
    static let leaf = Color(red: 0.19, green: 0.70, blue: 0.42)
    static let frost = Color(red: 0.96, green: 0.97, blue: 1.00)

    static var commandGradient: LinearGradient {
        LinearGradient(
            colors: [
                ember.opacity(0.95),
                violet.opacity(0.92),
                lagoon.opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var warmGradient: LinearGradient {
        LinearGradient(
            colors: [marigold.opacity(0.95), ember.opacity(0.9)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var coolGradient: LinearGradient {
        LinearGradient(
            colors: [lagoon.opacity(0.92), violet.opacity(0.88)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct PremiumSurface: ViewModifier {
    var tint: Color = PartyTheme.violet
    var isProminent = false

    func body(content: Content) -> some View {
        content
            .background(
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.thinMaterial)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(tint.opacity(isProminent ? 0.15 : 0.07))
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(tint.opacity(isProminent ? 0.34 : 0.18), lineWidth: 1)
                }
            )
            .shadow(color: tint.opacity(isProminent ? 0.22 : 0.10), radius: isProminent ? 18 : 8, x: 0, y: isProminent ? 10 : 4)
    }
}

extension View {
    func premiumSurface(tint: Color = PartyTheme.violet, prominent: Bool = false) -> some View {
        modifier(PremiumSurface(tint: tint, isProminent: prominent))
    }

    func premiumListStyle() -> some View {
        scrollContentBackground(.hidden)
            .background(PartyTheme.frost)
    }
}
