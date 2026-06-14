import SwiftUI

struct ExpensesView: View {
    @Environment(EventStore.self) private var store

    var body: some View {
        let summary = ExpenseAllocator.summarize(event: store.event)

        List {
            Section {
                MetricTile(title: "Total Party Expense", value: summary.eventTotal.currencyText, icon: "dollarsign.circle", color: .pink)
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
                        Text("\(expense.category.rawValue) • paid by \(store.event.userName(for: expense.paidByUserID)) • \(expense.splitPolicy.rawValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Label("Receipts", systemImage: "receipt")
            }
        }
        .navigationTitle("Money")
    }
}

#Preview {
    NavigationStack { ExpensesView() }
        .environment(EventStore(sampleEvent: .summerBirthday))
}
