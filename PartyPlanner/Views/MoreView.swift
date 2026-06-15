import SwiftUI

struct MoreView: View {
    var body: some View {
        List {
            Section {
                ScreenIntroBanner(
                    title: "More event tools",
                    detail: "Open the board, get support, and review the quality resources that keep the app production-ready.",
                    icon: "ellipsis.circle",
                    color: PartyTheme.violet
                )
            }

            Section {
                NavigationLink {
                    CommunicationView()
                } label: {
                    premiumMenuRow(
                        title: "Board",
                        detail: "Public updates, private messages, and owner-only notes.",
                        icon: "bubble.left.and.bubble.right",
                        color: PartyTheme.ember
                    )
                }

                NavigationLink {
                    SupportView()
                } label: {
                    premiumMenuRow(
                        title: "Support",
                        detail: "Training, definitions, how-to guides, and best practices.",
                        icon: "questionmark.circle",
                        color: PartyTheme.violet
                    )
                }
            } header: {
                Label("Tools", systemImage: "square.grid.2x2")
            }

            Section {
                premiumMenuRow(
                    title: "Release Readiness",
                    detail: "Build, data, UX, and launch gates are tracked in the project docs.",
                    icon: "checkmark.seal",
                    color: PartyTheme.leaf
                )
                premiumMenuRow(
                    title: "Production Trust",
                    detail: "Accuracy rules, expense math, roles, realtime, and audit expectations are documented.",
                    icon: "shield.checkered",
                    color: PartyTheme.lagoon
                )
            } header: {
                Label("Quality", systemImage: "sparkle.magnifyingglass")
            }
        }
        .premiumListStyle()
        .listSectionSpacing(14)
        .navigationTitle("More")
    }

    private func premiumMenuRow(title: String, detail: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(PartyTheme.ink)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack { MoreView() }
}
