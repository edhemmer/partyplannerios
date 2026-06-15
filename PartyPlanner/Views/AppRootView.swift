import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case command = "Command"
    case plan = "Plan"
    case crew = "Crew"
    case money = "Money"
    case board = "Board"
    case support = "Support"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .command: "party.popper"
        case .plan: "wand.and.stars"
        case .crew: "person.3.sequence"
        case .money: "receipt"
        case .board: "bubble.left.and.bubble.right"
        case .support: "questionmark.circle"
        }
    }
}

struct AppRootView: View {
    @State private var selectedTab: AppTab = .command

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    content(for: tab)
                }
                .tabItem { Label(tab.rawValue, systemImage: tab.icon) }
                .tag(tab)
            }
        }
        .tint(.pink)
    }

    @ViewBuilder
    private func content(for tab: AppTab) -> some View {
        switch tab {
        case .command:
            DashboardView()
        case .plan:
            PlanBuilderView()
        case .crew:
            CrewView()
        case .money:
            ExpensesView()
        case .board:
            CommunicationView()
        case .support:
            SupportView()
        }
    }
}

#Preview {
    AppRootView()
        .environment(EventStore(sampleEvent: .summerBirthday))
}
