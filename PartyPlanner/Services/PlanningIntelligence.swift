import Foundation

struct PlanningQuestion: Identifiable, Hashable {
    var id = UUID()
    var prompt: String
    var options: [String]
}

struct GeneratedPlan {
    var questions: [PlanningQuestion]
    var supplies: [SupplyItem]
    var responsibilities: [Responsibility]
}

enum PlanningIntelligence {
    static func generatePlan(for event: PartyEvent) -> GeneratedPlan {
        let people = max(event.guestCount, 1)
        let tables = Int(ceil(Double(people) / 8.0))
        let trashBags = max(3, Int(ceil(Double(people) / 12.0)))
        let icePounds = people * 2
        let plates = people * 2
        let cups = people * 3
        let napkins = people * 4

        let questions = [
            PlanningQuestion(prompt: "How should shared expenses be split?", options: SplitPolicy.allCases.map(\.rawValue)),
            PlanningQuestion(prompt: "Are children included in food and drink quantities?", options: ["Food only", "Food and soft drinks", "No children attending"]),
            PlanningQuestion(prompt: "What is the event service style?", options: ["Buffet", "Plated", "Cookout", "Cocktail / snacks"]),
            PlanningQuestion(prompt: "Should alcohol be tracked separately?", options: ["Yes", "No", "Only organizer can edit"])
        ]

        let supplies = [
            SupplyItem(name: "Dinner plates", quantity: Double(plates), unit: "count", category: .supplies, assignedUserID: nil, isPacked: false),
            SupplyItem(name: "Cups or glasses", quantity: Double(cups), unit: "count", category: .bar, assignedUserID: nil, isPacked: false),
            SupplyItem(name: "Napkins", quantity: Double(napkins), unit: "count", category: .supplies, assignedUserID: nil, isPacked: false),
            SupplyItem(name: "Tables", quantity: Double(tables), unit: "8-person", category: .setup, assignedUserID: nil, isPacked: false),
            SupplyItem(name: "Chairs", quantity: Double(people + 4), unit: "count", category: .setup, assignedUserID: nil, isPacked: false),
            SupplyItem(name: "Ice", quantity: Double(icePounds), unit: "lb", category: .bar, assignedUserID: nil, isPacked: false),
            SupplyItem(name: "Trash bags", quantity: Double(trashBags), unit: "large", category: .breakdown, assignedUserID: nil, isPacked: false),
            SupplyItem(name: "Serving utensils", quantity: Double(max(6, tables)), unit: "count", category: .meal, assignedUserID: nil, isPacked: false),
            SupplyItem(name: "Bluetooth speaker / DJ setup", quantity: 1, unit: "set", category: .music, assignedUserID: nil, isPacked: false),
            SupplyItem(name: "Decor kit", quantity: Double(max(1, tables / 2)), unit: "zones", category: .decorations, assignedUserID: nil, isPacked: false)
        ]

        let due = Calendar.current.date(byAdding: .day, value: -1, to: event.startsAt) ?? event.startsAt
        let responsibilities = [
            Responsibility(title: "Confirm venue, parking, and arrival flow", kind: .setup, ownerID: event.ownerID, dueDate: due, checklist: [
                ChecklistItem(title: "Confirm address and parking notes", isDone: false),
                ChecklistItem(title: "Add setup arrival time", isDone: false),
                ChecklistItem(title: "Share directions with helpers", isDone: false)
            ], status: .notStarted),
            Responsibility(title: "Build master food and beverage plan", kind: .meal, ownerID: event.ownerID, dueDate: due, checklist: [
                ChecklistItem(title: "Assign each meal owner", isDone: false),
                ChecklistItem(title: "Confirm ingredients and equipment", isDone: false),
                ChecklistItem(title: "Track allergy notes", isDone: false)
            ], status: .notStarted),
            Responsibility(title: "Create setup and breakdown crews", kind: .breakdown, ownerID: event.ownerID, dueDate: due, checklist: [
                ChecklistItem(title: "Assign setup crew", isDone: false),
                ChecklistItem(title: "Assign cleanup crew", isDone: false),
                ChecklistItem(title: "Confirm trash and leftover plan", isDone: false)
            ], status: .notStarted)
        ]

        return GeneratedPlan(questions: questions, supplies: supplies, responsibilities: responsibilities)
    }

    static func generateInsights(for event: PartyEvent) -> [PlanningInsight] {
        var insights: [PlanningInsight] = []
        let unassignedSupplies = event.supplies.filter { $0.assignedUserID == nil }
        let blockedResponsibilities = event.responsibilities.filter { $0.status == .blocked }
        let unownedMealCount = event.meals.filter { meal in
            event.users.contains(where: { $0.id == meal.ownerID }) == false
        }.count
        let hasBarPlan = event.supplies.contains { $0.category == .bar } || event.responsibilities.contains { $0.kind == .bar }
        let hasBreakdownCrew = event.responsibilities.contains { $0.kind == .breakdown }
        let totalEstimatedMeals = event.meals.reduce(Decimal(0)) { $0 + $1.estimatedCost }
        let totalExpenses = event.expenses.reduce(Decimal(0)) { $0 + $1.amount }

        if event.guestCount > 0 && event.supplies.isEmpty {
            insights.append(PlanningInsight(severity: .urgent, title: "No supply plan yet", detail: "Generate the master plan before inviting helpers so quantities are clear."))
        }

        if !unassignedSupplies.isEmpty {
            insights.append(PlanningInsight(severity: .attention, title: "\(unassignedSupplies.count) supply items unassigned", detail: "Assign owners for items that must be bought, packed, or staged."))
        }

        if !blockedResponsibilities.isEmpty {
            insights.append(PlanningInsight(severity: .urgent, title: "\(blockedResponsibilities.count) blocked responsibilities", detail: "Review blockers before the event timeline gets compressed."))
        }

        if unownedMealCount > 0 {
            insights.append(PlanningInsight(severity: .urgent, title: "Meal owner missing", detail: "Every meal needs one accountable person for ingredients, equipment, and timing."))
        }

        if !hasBarPlan {
            insights.append(PlanningInsight(severity: .attention, title: "Beverage plan not assigned", detail: "Add soft drinks, water, ice, alcohol rules, coolers, and serving supplies."))
        }

        if !hasBreakdownCrew {
            insights.append(PlanningInsight(severity: .attention, title: "Breakdown crew missing", detail: "Assign cleanup, trash, leftovers, rental returns, and venue reset tasks."))
        }

        if totalExpenses == 0 && totalEstimatedMeals > 0 {
            insights.append(PlanningInsight(severity: .info, title: "Expense tracking ready", detail: "Meal estimates exist. Add receipts as users start buying supplies."))
        }

        if insights.isEmpty {
            insights.append(PlanningInsight(severity: .info, title: "Plan is healthy", detail: "The event has owners, supplies, responsibilities, and expense tracking in motion."))
        }

        return insights
    }
}
