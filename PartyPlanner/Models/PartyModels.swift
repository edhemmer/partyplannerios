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

enum RSVPStatus: String, CaseIterable, Identifiable, Codable {
    case invited = "Invited"
    case yes = "Going"
    case maybe = "Maybe"
    case no = "Not Going"
    case noResponse = "No Response"

    var id: String { rawValue }
}

enum SmartActionKind: String, Codable {
    case invite
    case assign
    case buy
    case confirm
    case collect
    case communicate
    case timeline

    var icon: String {
        switch self {
        case .invite: "paperplane"
        case .assign: "person.crop.circle.badge.plus"
        case .buy: "cart.badge.plus"
        case .confirm: "checkmark.seal"
        case .collect: "receipt"
        case .communicate: "bubble.left.and.text.bubble.right"
        case .timeline: "clock.badge.checkmark"
        }
    }

    var color: Color {
        switch self {
        case .invite: .blue
        case .assign: .purple
        case .buy: .cyan
        case .confirm: .green
        case .collect: .pink
        case .communicate: .orange
        case .timeline: .indigo
        }
    }
}

enum SyncConnectionState: String, Codable {
    case live = "Live"
    case syncing = "Syncing"
    case offline = "Offline"
    case degraded = "Needs Attention"

    var icon: String {
        switch self {
        case .live: "checkmark.icloud"
        case .syncing: "arrow.triangle.2.circlepath.icloud"
        case .offline: "icloud.slash"
        case .degraded: "exclamationmark.icloud"
        }
    }

    var color: Color {
        switch self {
        case .live: .green
        case .syncing: .blue
        case .offline: .gray
        case .degraded: .orange
        }
    }
}

enum ReliabilityState: String, Codable {
    case verified = "Verified"
    case review = "Review"
    case warning = "Warning"

    var icon: String {
        switch self {
        case .verified: "checkmark.seal"
        case .review: "questionmark.diamond"
        case .warning: "exclamationmark.triangle"
        }
    }

    var color: Color {
        switch self {
        case .verified: .green
        case .review: .orange
        case .warning: .red
        }
    }
}

enum AuditAction: String, Codable {
    case createdPlan = "Created Plan"
    case regeneratedPlan = "Regenerated Plan"
    case updatedResponsibility = "Updated Responsibility"
    case addedExpense = "Added Expense"
    case postedNote = "Posted Note"
    case resolvedConflict = "Resolved Conflict"
    case synced = "Synced"
}

enum NoteVisibility: String, CaseIterable, Codable {
    case eventBoard
    case privateMessage
    case ownerOnly
}

enum InsightSeverity: String, Codable {
    case info
    case attention
    case urgent

    var title: String {
        switch self {
        case .info: "Good"
        case .attention: "Needs Review"
        case .urgent: "Act Now"
        }
    }

    var icon: String {
        switch self {
        case .info: "checkmark.seal"
        case .attention: "exclamationmark.triangle"
        case .urgent: "bolt.badge.clock"
        }
    }

    var color: Color {
        switch self {
        case .info: .green
        case .attention: .orange
        case .urgent: .red
        }
    }
}

struct PlanningInsight: Identifiable, Hashable {
    var id = UUID()
    var severity: InsightSeverity
    var title: String
    var detail: String
}

struct SmartAction: Identifiable, Hashable {
    var id = UUID()
    var kind: SmartActionKind
    var title: String
    var detail: String
    var priority: Int
}

struct SyncStatus: Hashable, Codable {
    var state: SyncConnectionState
    var lastSyncedAt: Date
    var pendingUploads: Int
    var pendingChanges: Int
    var conflictCount: Int
}

struct AuditEvent: Identifiable, Hashable, Codable {
    var id = UUID()
    var actorID: PartyUser.ID
    var action: AuditAction
    var target: String
    var detail: String
    var createdAt: Date
}

struct ReliabilitySignal: Identifiable, Hashable {
    var id = UUID()
    var state: ReliabilityState
    var title: String
    var detail: String
}

struct PartyUser: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var role: Role
    var phone: String
    var email: String
    var isAdult: Bool
}

extension PartyUser {
    static let unknown = PartyUser(name: "Event Member", role: .guest, phone: "", email: "", isAdult: true)
}

struct GuestInvitation: Identifiable, Hashable, Codable {
    var id = UUID()
    var userID: PartyUser.ID
    var status: RSVPStatus
    var partySize: Int
    var dietaryNotes: String
    var lastTouchedAt: Date
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

struct PartyBudget: Hashable, Codable {
    var targetTotal: Decimal
    var mealsTarget: Decimal
    var barTarget: Decimal
    var activitiesTarget: Decimal
    var venueTarget: Decimal
    var suppliesTarget: Decimal
}

struct TimelineMoment: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var startsAt: Date
    var ownerID: PartyUser.ID?
    var kind: ResponsibilityKind
    var notes: String
    var isCritical: Bool
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
    var invitations: [GuestInvitation]
    var budget: PartyBudget
    var timeline: [TimelineMoment]
    var syncStatus: SyncStatus
    var auditTrail: [AuditEvent]
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
