import Foundation
import Observation

@MainActor
@Observable
final class EventStore {
    var event: PartyEvent
    var currentUserID: PartyUser.ID
    var setupQuestions: [PlanningQuestion] = []

    init(sampleEvent: PartyEvent) {
        self.event = sampleEvent
        self.currentUserID = sampleEvent.ownerID
        self.setupQuestions = PlanningIntelligence.generatePlan(for: sampleEvent).questions
    }

    var currentUser: PartyUser {
        event.users.first { $0.id == currentUserID } ?? event.users[0]
    }

    var canEditMasterPlan: Bool {
        currentUser.role == .owner || currentUser.role == .cohost
    }

    var expenseSummary: ExpenseSummary {
        ExpenseAllocator.summarize(event: event)
    }

    var smartActions: [SmartAction] {
        PlanningIntelligence.recommendedActions(for: event)
    }

    var nextResponsibilities: [Responsibility] {
        event.responsibilities
            .filter { $0.status != .done }
            .sorted { $0.dueDate < $1.dueDate }
    }

    var myResponsibilities: [Responsibility] {
        event.responsibilities
            .filter { $0.ownerID == currentUserID }
            .sorted { $0.dueDate < $1.dueDate }
    }

    var planningInsights: [PlanningInsight] {
        PlanningIntelligence.generateInsights(for: event)
    }

    var readinessScore: Int {
        let total = max(event.responsibilities.count + event.supplies.count + event.meals.count, 1)
        let completedResponsibilities = event.responsibilities.filter { $0.status == .done || $0.status == .ready }.count
        let packedSupplies = event.supplies.filter(\.isPacked).count
        let ownedMeals = event.meals.filter { meal in
            event.users.contains { $0.id == meal.ownerID }
        }.count
        let raw = Double(completedResponsibilities + packedSupplies + ownedMeals) / Double(total)
        return min(100, max(0, Int((raw * 100).rounded())))
    }

    var rsvpSummary: [RSVPStatus: Int] {
        Dictionary(grouping: event.invitations, by: \.status)
            .mapValues { invitations in invitations.reduce(0) { $0 + max($1.partySize, 1) } }
    }

    var confirmedHeadcount: Int {
        event.invitations
            .filter { $0.status == .yes }
            .reduce(0) { $0 + max($1.partySize, 1) }
    }

    var budgetUsedRatio: Double {
        guard event.budget.targetTotal > 0 else { return 0 }
        let total = NSDecimalNumber(decimal: expenseSummary.eventTotal).doubleValue
        let target = NSDecimalNumber(decimal: event.budget.targetTotal).doubleValue
        return min(1.5, max(0, total / target))
    }

    var sortedTimeline: [TimelineMoment] {
        event.timeline.sorted { $0.startsAt < $1.startsAt }
    }

    func regenerateSuggestedPlan() {
        guard canEditMasterPlan else { return }
        let plan = PlanningIntelligence.generatePlan(for: event)
        event.supplies = merge(existing: event.supplies, suggestions: plan.supplies)
        event.responsibilities = merge(existing: event.responsibilities, suggestions: plan.responsibilities)
        if event.timeline.isEmpty {
            event.timeline = PlanningIntelligence.generateTimeline(for: event)
        }
        setupQuestions = plan.questions
        publishUpdate("Regenerated the master plan from event details.")
    }

    func updateResponsibilityStatus(_ responsibility: Responsibility, status: WorkStatus) {
        guard canEdit(responsibility) else { return }
        guard let index = event.responsibilities.firstIndex(where: { $0.id == responsibility.id }) else { return }
        event.responsibilities[index].status = status
        publishUpdate("\(currentUser.name) marked \(responsibility.title) as \(status.rawValue).")
    }

    func addExpense(_ expense: Expense) {
        event.expenses.append(expense)
        publishUpdate("\(currentUser.name) added an expense receipt for \(expense.title).")
    }

    func addNote(message: String, visibility: NoteVisibility, recipients: [PartyUser.ID] = []) {
        event.notes.insert(
            PartyNote(authorID: currentUserID, recipientIDs: recipients, visibility: visibility, message: message, createdAt: .now),
            at: 0
        )
        if visibility == .eventBoard {
            publishUpdate("\(currentUser.name) posted on the event board.")
        }
    }

    func canEdit(_ responsibility: Responsibility) -> Bool {
        canEditMasterPlan || responsibility.ownerID == currentUserID
    }

    private func publishUpdate(_ message: String) {
        event.updates.insert(EventUpdate(actorID: currentUserID, message: message, createdAt: .now), at: 0)
    }

    private func merge<T: Identifiable & Hashable>(existing: [T], suggestions: [T]) -> [T] {
        var result = existing
        for suggestion in suggestions where !result.contains(suggestion) {
            result.append(suggestion)
        }
        return result
    }
}
