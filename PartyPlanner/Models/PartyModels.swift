import Foundation
import SwiftUI

enum EventPreset: String, CaseIterable, Identifiable, Codable {
    case birthday = "Birthday"
    case wedding = "Wedding"
    case anniversary = "Anniversary"
    case graduation = "Graduation"
    case holiday = "Holiday"
    case reunion = "Reunion"
    case custom = "Custom"

    var id: String { rawValue }
}

enum Role: String, Codable, CaseIterable {
    case owner
    case cohost
    case helper
    case guest
}

enum ResponsibilityKind: String, CaseIterable, Identifiable, Codable {
    case setup = "Setup"
    case breakdown = "Breakdown"
    case meal = "Meal"
    case bar = "Bar"
    case decorations = "Decorations"
    case music = "Music / DJ"
    case activities = "Activities"
    case lodging = "Lodging"
    case transportation = "Transportation"
    case supplies = "Supplies"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .setup: "wrench.and.screwdriver"
        case .breakdown: "shippingbox"
        case .meal: "fork.knife"
        case .bar: "wineglass"
        case .decorations: "sparkles"
        case .music: "music.note.list"
        case .activities: "figure.socialdance"
        case .lodging: "bed.double"
        case .transportation: "car"
        case .supplies: "cart"
        }
    }

    var color: Color {
        switch self {
        case .setup: .teal
        case .breakdown: .gray
        case .meal: .orange
        case .bar: .pink
        case .decorations: .purple
        case .music: .indigo
        case .activities: .green
        case .lodging: .brown
        case .transportation: .blue
        case .supplies: .cyan
        }
    }
}

enum ExpenseCategory: String, CaseIterable, Identifiable, Codable {
    case meals = "Meals"
    case activities = "Activities"
    case lodgingVenue = "Lodging & Venue"
    case supplies = "Supplies"
    case bar = "Bar"
    case decorations = "Decorations"
    case music = "Music"
    case transportation = "Transportation"

    var id: String { rawValue }
}

enum SplitPolicy: String, CaseIterable, Identifiable, Codable {
    case equal = "Equal split"
    case adultsOnly = "Adults only"
    case assignedUsers = "Assigned users"
    case ownerPays = "Owner pays"

    var id: String { rawValue }
}

enum NoteVisibility: String, CaseIterable, Codable {
    case eventBoard
    case privateMessage
    case ownerOnly
}

struct PartyUser: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var role: Role
    var phone: String
    var email: String
    var isAdult: Bool
}

struct Venue: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var address: String
    var arrivalWindow: String
    var parkingNotes: String
    var latitude: Double?
    var longitude: Double?
}

struct MealPlan: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var ownerID: PartyUser.ID
    var servingTime: Date
    var guestCount: Int
    var ingredients: [SupplyItem]
    var equipment: [SupplyItem]
    var notes: String
    var estimatedCost: Decimal
}

struct SupplyItem: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var quantity: Double
    var unit: String
    var category: ResponsibilityKind
    var assignedUserID: PartyUser.ID?
    var isPacked: Bool
}

struct Responsibility: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var kind: ResponsibilityKind
    var ownerID: PartyUser.ID
    var dueDate: Date
    var checklist: [ChecklistItem]
    var status: WorkStatus
}

struct ChecklistItem: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var isDone: Bool
}

enum WorkStatus: String, CaseIterable, Codable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case blocked = "Blocked"
    case ready = "Ready"
    case done = "Done"
}

struct Expense: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var amount: Decimal
    var category: ExpenseCategory
    var paidByUserID: PartyUser.ID
    var splitPolicy: SplitPolicy
    var assignedShareUserIDs: [PartyUser.ID]
    var receiptImageName: String?
    var createdAt: Date
}

struct PartyNote: Identifiable, Hashable, Codable {
    var id = UUID()
    var authorID: PartyUser.ID
    var recipientIDs: [PartyUser.ID]
    var visibility: NoteVisibility
    var message: String
    var createdAt: Date
}

struct EventUpdate: Identifiable, Hashable, Codable {
    var id = UUID()
    var actorID: PartyUser.ID
    var message: String
    var createdAt: Date
}

struct PartyEvent: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var preset: EventPreset
    var ageGroup: String
    var guestCount: Int
    var startsAt: Date
    var endsAt: Date
    var ownerID: PartyUser.ID
    var venue: Venue
    var users: [PartyUser]
    var meals: [MealPlan]
    var supplies: [SupplyItem]
    var responsibilities: [Responsibility]
    var expenses: [Expense]
    var notes: [PartyNote]
    var updates: [EventUpdate]
    var splitPolicy: SplitPolicy
}

extension PartyEvent {
    var owner: PartyUser? { users.first { $0.id == ownerID } }

    func userName(for id: PartyUser.ID?) -> String {
        guard let id, let user = users.first(where: { $0.id == id }) else { return "Unassigned" }
        return user.name
    }
}
