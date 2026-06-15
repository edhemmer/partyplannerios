import SwiftUI

struct CrewView: View {
    @Environment(EventStore.self) private var store

    var body: some View {
        List {
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
                ForEach(store.event.users) { user in
                    contactRow(user)
                }
            } header: {
                Label("Guest & Helper Contacts", systemImage: "person.text.rectangle")
            }
        }
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

    private func contactRow(_ user: PartyUser) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(user.name)
                    .font(.headline)
                Spacer()
                StatusPill(text: user.role.rawValue.capitalized, color: roleColor(user.role))
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
}

#Preview {
    NavigationStack { CrewView() }
        .environment(EventStore(sampleEvent: .summerBirthday))
}
