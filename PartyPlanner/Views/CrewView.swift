import SwiftUI

struct CrewView: View {
    @Environment(EventStore.self) private var store

    var body: some View {
        List {
            Section {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    MetricTile(title: "Going", value: "\(store.rsvpSummary[.yes, default: 0])", icon: "checkmark.circle", color: .green)
                    MetricTile(title: "Maybe", value: "\(store.rsvpSummary[.maybe, default: 0])", icon: "questionmark.circle", color: .orange)
                    MetricTile(title: "No Response", value: "\(store.rsvpSummary[.noResponse, default: 0] + store.rsvpSummary[.invited, default: 0])", icon: "paperplane", color: .blue)
                    MetricTile(title: "Not Going", value: "\(store.rsvpSummary[.no, default: 0])", icon: "xmark.circle", color: .gray)
                }
            } header: {
                Label("RSVP Confidence", systemImage: "person.2.wave.2")
            }

            Section {
                ForEach(store.myResponsibilities) { item in
                    responsibilityRow(item, isMine: true)
                }
            } header: {
                Label("My Work", systemImage: "person.crop.circle.badge.checkmark")
            }

            ForEach(ResponsibilityKind.allCases) { kind in
                let items = store.event.responsibilities.filter { $0.kind == kind }
                if !items.isEmpty {
                    Section {
                        ForEach(items) { item in
                            responsibilityRow(item, isMine: item.ownerID == store.currentUserID)
                        }
                    } header: {
                        Label(kind.rawValue, systemImage: kind.icon)
                            .foregroundStyle(kind.color)
                    }
                }
            }

            Section {
                ForEach(store.event.invitations) { invitation in
                    if let user = store.event.users.first(where: { $0.id == invitation.userID }) {
                        contactRow(user, invitation: invitation)
                    }
                }
            } header: {
                Label("Guest & Helper Contacts", systemImage: "person.text.rectangle")
            }
        }
        .premiumListStyle()
        .listSectionSpacing(14)
        .navigationTitle("Crew")
    }

    private func responsibilityRow(_ item: Responsibility, isMine: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                    Text("\(store.event.userName(for: item.ownerID)) - due \(item.dueDate, style: .date)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Menu(item.status.rawValue) {
                    ForEach(WorkStatus.allCases, id: \.rawValue) { status in
                        Button(status.rawValue) {
                            store.updateResponsibilityStatus(item, status: status)
                        }
                    }
                }
                .disabled(!store.canEdit(item))
            }

            if isMine {
                StatusPill(text: "Assigned to you", color: .blue)
            }

            ForEach(item.checklist) { checklist in
                Label(checklist.title, systemImage: checklist.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.caption)
                    .foregroundStyle(checklist.isDone ? .green : .secondary)
            }
        }
        .padding(.vertical, 6)
    }

    private func contactRow(_ user: PartyUser, invitation: GuestInvitation) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(user.name)
                    .font(.headline)
                Spacer()
                StatusPill(text: user.role.rawValue.capitalized, color: roleColor(user.role))
            }
            HStack {
                StatusPill(text: invitation.status.rawValue, color: rsvpColor(invitation.status))
                Text("Party of \(invitation.partySize)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !invitation.dietaryNotes.isEmpty {
                    Text(invitation.dietaryNotes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Label(user.phone, systemImage: "phone")
                .font(.caption)
                .foregroundStyle(.secondary)
            Label(user.email, systemImage: "envelope")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func roleColor(_ role: Role) -> Color {
        switch role {
        case .owner: .pink
        case .cohost: .purple
        case .helper: .blue
        case .guest: .gray
        }
    }

    private func rsvpColor(_ status: RSVPStatus) -> Color {
        switch status {
        case .yes: .green
        case .maybe: .orange
        case .no: .gray
        case .invited, .noResponse: .blue
        }
    }
}

#Preview {
    NavigationStack { CrewView() }
        .environment(EventStore(sampleEvent: .summerBirthday))
}
