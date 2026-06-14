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

    func regenerateSuggestedPlan() {
        guard canEditMasterPlan else { return }
        let plan = PlanningIntelligence.generatePlan(for: event)
        event.supplies = merge(existing: event.supplies, suggestions: plan.supplies)
        event.responsibilities = merge(existing: event.responsibilities, suggestions: plan.responsibilities)
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
