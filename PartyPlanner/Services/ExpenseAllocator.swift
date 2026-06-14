import Foundation

struct ExpenseSummary {
    var eventTotal: Decimal
    var categoryTotals: [ExpenseCategory: Decimal]
    var userOutOfPocket: [PartyUser.ID: Decimal]
    var userShares: [PartyUser.ID: Decimal]
    var balances: [PartyUser.ID: Decimal]
}

enum ExpenseAllocator {
    static func summarize(event: PartyEvent) -> ExpenseSummary {
        var categoryTotals: [ExpenseCategory: Decimal] = [:]
        var outOfPocket: [PartyUser.ID: Decimal] = [:]
        var shares: [PartyUser.ID: Decimal] = [:]

        for expense in event.expenses {
            categoryTotals[expense.category, default: 0] += expense.amount
            outOfPocket[expense.paidByUserID, default: 0] += expense.amount

            let participants = participants(for: expense, in: event)
            guard !participants.isEmpty else { continue }
            let perPerson = expense.amount / Decimal(participants.count)
            for id in participants {
                shares[id, default: 0] += perPerson
            }
        }

        var balances: [PartyUser.ID: Decimal] = [:]
        for user in event.users {
            balances[user.id] = outOfPocket[user.id, default: 0] - shares[user.id, default: 0]
        }

        return ExpenseSummary(
            eventTotal: event.expenses.reduce(0) { $0 + $1.amount },
            categoryTotals: categoryTotals,
            userOutOfPocket: outOfPocket,
            userShares: shares,
            balances: balances
        )
    }

    private static func participants(for expense: Expense, in event: PartyEvent) -> [PartyUser.ID] {
        switch expense.splitPolicy {
        case .equal:
            return event.users.map(\.id)
        case .adultsOnly:
            return event.users.filter(\.isAdult).map(\.id)
        case .assignedUsers:
            return expense.assignedShareUserIDs
        case .ownerPays:
            return [event.ownerID]
        }
    }
}
