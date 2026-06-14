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
}
