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

    var trustScore: Int {
        let signals = reliabilitySignals
        guard !signals.isEmpty else { return 100 }
        let points = signals.reduce(0) { total, signal in
            switch signal.state {
            case .verified: total + 100
            case .review: total + 65
            case .warning: total + 25
            }
        }
        return points / signals.count
    }

    var reliabilitySignals: [ReliabilitySignal] {
        var signals: [ReliabilitySignal] = []
        let minutesSinceSync = Calendar.current.dateComponents([.minute], from: event.syncStatus.lastSyncedAt, to: .now).minute ?? 0
        let missingReceiptCount = event.expenses.filter { $0.receiptImageName == nil }.count
        let unassignedSupplyCount = event.supplies.filter { $0.assignedUserID == nil }.count
        let staleResponsibilityCount = event.responsibilities.filter { responsibility in
            responsibility.status != .done && responsibility.dueDate < .now
        }.count

        signals.append(ReliabilitySignal(
            state: event.syncStatus.state == .live ? .verified : .warning,
            title: "Realtime Sync",
            detail: event.syncStatus.state == .live ? "Event data is connected and ready for live updates." : "Updates may be delayed until sync is healthy."
        ))

        signals.append(ReliabilitySignal(
            state: minutesSinceSync < 5 ? .verified : .review,
            title: "Fresh Data",
            detail: "Last synced \(minutesSinceSync) minutes ago."
        ))

        signals.append(ReliabilitySignal(
            state: event.syncStatus.conflictCount == 0 ? .verified : .warning,
            title: "Conflicts",
            detail: event.syncStatus.conflictCount == 0 ? "No edit conflicts detected." : "\(event.syncStatus.conflictCount) edits need owner review."
        ))

        signals.append(ReliabilitySignal(
            state: missingReceiptCount == 0 ? .verified : .review,
            title: "Receipt Evidence",
            detail: missingReceiptCount == 0 ? "All expenses have receipt evidence." : "\(missingReceiptCount) expenses are missing receipt images."
        ))

        signals.append(ReliabilitySignal(
            state: unassignedSupplyCount == 0 ? .verified : .review,
            title: "Assignment Coverage",
            detail: unassignedSupplyCount == 0 ? "Every supply item has an owner." : "\(unassignedSupplyCount) supply items still need owners."
        ))

        signals.append(ReliabilitySignal(
            state: staleResponsibilityCount == 0 ? .verified : .warning,
            title: "Due Work",
            detail: staleResponsibilityCount == 0 ? "No overdue responsibilities." : "\(staleResponsibilityCount) responsibilities are overdue."
        ))

        return signals
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
        recordAudit(action: .regeneratedPlan, target: "Master Plan", detail: "Generated supplies, responsibilities, and timeline suggestions.")
    }

    func updateResponsibilityStatus(_ responsibility: Responsibility, status: WorkStatus) {
        guard canEdit(responsibility) else { return }
        guard let index = event.responsibilities.firstIndex(where: { $0.id == responsibility.id }) else { return }
        event.responsibilities[index].status = status
        publishUpdate("\(currentUser.name) marked \(responsibility.title) as \(status.rawValue).")
        recordAudit(action: .updatedResponsibility, target: responsibility.title, detail: "Status changed to \(status.rawValue).")
    }

    func addExpense(_ expense: Expense) {
        event.expenses.append(expense)
        publishUpdate("\(currentUser.name) added an expense receipt for \(expense.title).")
        recordAudit(action: .addedExpense, target: expense.title, detail: "Added \(expense.amount.currencyText) in \(expense.category.rawValue).")
    }

    func addNote(message: String, visibility: NoteVisibility, recipients: [PartyUser.ID] = []) {
        event.notes.insert(
            PartyNote(authorID: currentUserID, recipientIDs: recipients, visibility: visibility, message: message, createdAt: .now),
            at: 0
        )
        if visibility == .eventBoard {
            publishUpdate("\(currentUser.name) posted on the event board.")
        }
        recordAudit(action: .postedNote, target: "Board", detail: visibility == .eventBoard ? "Posted a public update." : "Posted a scoped note.")
    }

    func canEdit(_ responsibility: Responsibility) -> Bool {
        canEditMasterPlan || responsibility.ownerID == currentUserID
    }

    private func publishUpdate(_ message: String) {
        event.updates.insert(EventUpdate(actorID: currentUserID, message: message, createdAt: .now), at: 0)
        event.syncStatus.lastSyncedAt = .now
    }

    private func recordAudit(action: AuditAction, target: String, detail: String) {
        event.auditTrail.insert(
            AuditEvent(actorID: currentUserID, action: action, target: target, detail: detail, createdAt: .now),
            at: 0
        )
    }

    private func merge<T: Identifiable & Hashable>(existing: [T], suggestions: [T]) -> [T] {
        var result = existing
        for suggestion in suggestions where !result.contains(suggestion) {
            result.append(suggestion)
        }
        return result
    }
}
