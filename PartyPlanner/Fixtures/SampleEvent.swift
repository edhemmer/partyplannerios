import Foundation

extension PartyEvent {
    static var summerBirthday: PartyEvent {
        let owner = PartyUser(name: "Maya Rivera", role: .owner, phone: "(555) 010-1100", email: "maya@example.com", isAdult: true)
        let chef = PartyUser(name: "Andre Cole", role: .helper, phone: "(555) 010-2200", email: "andre@example.com", isAdult: true)
        let bar = PartyUser(name: "Nina Patel", role: .helper, phone: "(555) 010-3300", email: "nina@example.com", isAdult: true)
        let guest = PartyUser(name: "Sam Lee", role: .guest, phone: "(555) 010-4400", email: "sam@example.com", isAdult: true)
        let start = Calendar.current.date(byAdding: .day, value: 21, to: .now) ?? .now
        let end = Calendar.current.date(byAdding: .hour, value: 5, to: start) ?? start

        var event = PartyEvent(
            title: "Summer 40th Birthday Weekend",
            preset: .birthday,
            ageGroup: "Adults and families",
            guestCount: 42,
            startsAt: start,
            endsAt: end,
            ownerID: owner.id,
            venue: Venue(name: "Lakeview Pavilion", address: "1200 Harbor Road, Austin, TX", arrivalWindow: "Helpers 11:00 AM, guests 2:00 PM", parkingNotes: "Use the east lot and keep the dock entrance clear.", latitude: 30.2672, longitude: -97.7431),
            users: [owner, chef, bar, guest],
            meals: [],
            supplies: [],
            responsibilities: [],
            expenses: [],
            notes: [],
            updates: [],
            splitPolicy: .adultsOnly
        )

        let plan = PlanningIntelligence.generatePlan(for: event)
        event.supplies = plan.supplies
        event.responsibilities = [
            Responsibility(title: "Grill dinner and sides", kind: .meal, ownerID: chef.id, dueDate: start, checklist: [
                ChecklistItem(title: "Buy proteins and vegetables", isDone: false),
                ChecklistItem(title: "Bring grill tools and thermometer", isDone: true),
                ChecklistItem(title: "Confirm serving trays", isDone: false)
            ], status: .inProgress),
            Responsibility(title: "Bar, soft drinks, and ice", kind: .bar, ownerID: bar.id, dueDate: start, checklist: [
                ChecklistItem(title: "Separate alcohol from kids drinks", isDone: false),
                ChecklistItem(title: "Bring coolers", isDone: true),
                ChecklistItem(title: "Track receipt", isDone: false)
            ], status: .inProgress)
        ] + plan.responsibilities

        event.meals = [
            MealPlan(title: "Grilled dinner", ownerID: chef.id, servingTime: start, guestCount: 42, ingredients: [
                SupplyItem(name: "Chicken thighs", quantity: 18, unit: "lb", category: .meal, assignedUserID: chef.id, isPacked: false),
                SupplyItem(name: "Vegetable skewers", quantity: 55, unit: "count", category: .meal, assignedUserID: chef.id, isPacked: false)
            ], equipment: [
                SupplyItem(name: "Grill tongs", quantity: 2, unit: "count", category: .meal, assignedUserID: chef.id, isPacked: true)
            ], notes: "Keep one tray vegetarian and label allergens.", estimatedCost: 310)
        ]

        event.expenses = [
            Expense(title: "Venue deposit", amount: 450, category: .lodgingVenue, paidByUserID: owner.id, splitPolicy: .ownerPays, assignedShareUserIDs: [], receiptImageName: nil, createdAt: .now),
            Expense(title: "Grill groceries", amount: 184.72, category: .meals, paidByUserID: chef.id, splitPolicy: .adultsOnly, assignedShareUserIDs: [], receiptImageName: nil, createdAt: .now)
        ]

        event.notes = [
            PartyNote(authorID: owner.id, recipientIDs: [], visibility: .eventBoard, message: "Please update your task status as soon as you buy or pack anything.", createdAt: .now)
        ]

        event.updates = [
            EventUpdate(actorID: owner.id, message: "Maya created the master party plan.", createdAt: .now)
        ]

        return event
    }
}
