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

    static func generateTimeline(for event: PartyEvent) -> [TimelineMoment] {
        let calendar = Calendar.current
        func offset(hours: Int, minutes: Int = 0) -> Date {
            calendar.date(byAdding: DateComponents(hour: hours, minute: minutes), to: event.startsAt) ?? event.startsAt
        }

        return [
            TimelineMoment(title: "Setup crew arrives", startsAt: offset(hours: -3), ownerID: event.ownerID, kind: .setup, notes: "Open venue, unload supplies, mark staging zones.", isCritical: true),
            TimelineMoment(title: "Food prep starts", startsAt: offset(hours: -2), ownerID: event.meals.first?.ownerID, kind: .meal, notes: "Start prep, label allergens, confirm serving tools.", isCritical: true),
            TimelineMoment(title: "Bar and beverages iced", startsAt: offset(hours: -1), ownerID: event.responsibilities.first(where: { $0.kind == .bar })?.ownerID, kind: .bar, notes: "Separate alcohol, soft drinks, water, and kids beverages.", isCritical: true),
            TimelineMoment(title: "Guest arrival window", startsAt: event.startsAt, ownerID: event.ownerID, kind: .setup, notes: "Host greets, directions and parking questions handled.", isCritical: true),
            TimelineMoment(title: "Meal service", startsAt: offset(hours: 1), ownerID: event.meals.first?.ownerID, kind: .meal, notes: "Serve main meal and keep backup supplies visible.", isCritical: true),
            TimelineMoment(title: "Activities and music peak", startsAt: offset(hours: 2), ownerID: event.responsibilities.first(where: { $0.kind == .activities || $0.kind == .music })?.ownerID, kind: .activities, notes: "Run games, playlist, speeches, cake, or planned moments.", isCritical: false),
            TimelineMoment(title: "Breakdown begins", startsAt: Calendar.current.date(byAdding: .minute, value: -45, to: event.endsAt) ?? event.endsAt, ownerID: event.responsibilities.first(where: { $0.kind == .breakdown })?.ownerID, kind: .breakdown, notes: "Trash, leftovers, rental returns, venue reset.", isCritical: true)
        ]
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

    static func recommendedActions(for event: PartyEvent) -> [SmartAction] {
        var actions: [SmartAction] = []
        let unanswered = event.invitations.filter { $0.status == .noResponse || $0.status == .invited }
        let unassignedSupplies = event.supplies.filter { $0.assignedUserID == nil }
        let unassignedResponsibilities = event.responsibilities.filter { $0.ownerID == event.ownerID && $0.kind != .setup }
        let unpackedCriticalSupplies = event.supplies.filter { !$0.isPacked && [.bar, .meal, .setup, .breakdown].contains($0.category) }
        let missingReceipts = event.expenses.filter { $0.receiptImageName == nil }

        if !unanswered.isEmpty {
            actions.append(SmartAction(kind: .invite, title: "Nudge \(unanswered.count) guests", detail: "Send a friendly RSVP reminder so food, drinks, chairs, and share math stay accurate.", priority: 100))
        }

        if !unassignedResponsibilities.isEmpty {
            actions.append(SmartAction(kind: .assign, title: "Assign \(unassignedResponsibilities.count) owner-held jobs", detail: "Move work off the host before the event week gets noisy.", priority: 90))
        }

        if !unassignedSupplies.isEmpty {
            actions.append(SmartAction(kind: .buy, title: "Assign \(unassignedSupplies.count) supply items", detail: "Every item should have a buyer, packer, or staging owner.", priority: 80))
        }

        if !unpackedCriticalSupplies.isEmpty {
            actions.append(SmartAction(kind: .confirm, title: "Confirm critical supplies", detail: "\(unpackedCriticalSupplies.count) meal, bar, setup, or breakdown items are not packed yet.", priority: 70))
        }

        if !missingReceipts.isEmpty {
            actions.append(SmartAction(kind: .collect, title: "Collect \(missingReceipts.count) receipts", detail: "Receipt capture keeps out-of-pocket totals and reimbursements trustworthy.", priority: 60))
        }

        if event.timeline.isEmpty {
            actions.append(SmartAction(kind: .timeline, title: "Create run of show", detail: "Build the hour-by-hour event execution plan for helpers.", priority: 50))
        }

        if actions.isEmpty {
            actions.append(SmartAction(kind: .communicate, title: "Share a confidence update", detail: "The plan is in strong shape. Post the latest arrival, parking, and responsibility reminders.", priority: 10))
        }

        return actions.sorted { $0.priority > $1.priority }
    }
}
