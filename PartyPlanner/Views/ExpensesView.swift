import SwiftUI

struct ExpensesView: View {
    @Environment(EventStore.self) private var store

    var body: some View {
        let summary = store.expenseSummary

        List {
            Section {
                ScreenIntroBanner(
                    title: "Keep money clean",
                    detail: "Track receipts, category totals, out-of-pocket spend, and share math without guessing later.",
                    icon: "receipt",
                    color: PartyTheme.ember
                )
            }

            Section {
                MetricTile(title: "Total Party Expense", value: summary.eventTotal.currencyText, icon: "dollarsign.circle", color: .pink)
                LinearMeter(
                    title: "Budget Used",
                    value: "\(summary.eventTotal.currencyText) of \(store.event.budget.targetTotal.currencyText)",
                    ratio: store.budgetUsedRatio,
                    color: store.budgetUsedRatio > 1 ? .red : .green
                )
                Picker("Default Split", selection: Binding(
                    get: { store.event.splitPolicy },
                    set: { if store.canEditMasterPlan { store.event.splitPolicy = $0 } }
                )) {
                    ForEach(SplitPolicy.allCases) { policy in
                        Text(policy.rawValue).tag(policy)
                    }
                }
                .disabled(!store.canEditMasterPlan)
            } header: {
                Label("Expense Control", systemImage: "slider.horizontal.3")
            }

            Section {
                ForEach(ExpenseCategory.allCases) { category in
                    HStack {
                        Text(category.rawValue)
                        Spacer()
                        Text(summary.categoryTotals[category, default: 0].currencyText)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Label("Category Totals", systemImage: "chart.pie")
            }

            Section {
                ForEach(store.event.users) { user in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(user.name)
                            Text("Paid \(summary.userOutOfPocket[user.id, default: 0].currencyText)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("Share \(summary.userShares[user.id, default: 0].currencyText)")
                            .font(.caption.weight(.semibold))
                    }
                }
            } header: {
                Label("Your Share Math", systemImage: "person.2")
            }

            Section {
                ForEach(store.event.expenses) { expense in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(expense.title)
                                .font(.headline)
                            Spacer()
                            Text(expense.amount.currencyText)
                        }
                        Text("\(expense.category.rawValue) - paid by \(store.event.userName(for: expense.paidByUserID)) - \(expense.splitPolicy.rawValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                if store.event.expenses.isEmpty {
                    PremiumEmptyState(title: "No receipts yet", detail: "Add receipts as people start spending so total cost and shares stay accurate.", icon: "receipt", color: PartyTheme.lagoon)
                }
            } header: {
                Label("Receipts", systemImage: "receipt")
            }
        }
        .premiumListStyle()
        .listSectionSpacing(14)
        .navigationTitle("Money")
    }
}

#Preview {
    NavigationStack { ExpensesView() }
        .environment(EventStore(sampleEvent: .summerBirthday))
}
