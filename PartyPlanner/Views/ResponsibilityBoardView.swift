import SwiftUI

struct ResponsibilityBoardView: View {
    @Environment(EventStore.self) private var store

    var body: some View {
        List {
            ForEach(ResponsibilityKind.allCases) { kind in
                let items = store.event.responsibilities.filter { $0.kind == kind }
                if !items.isEmpty {
                    Section {
                        ForEach(items) { item in
                            responsibilityRow(item)
                        }
                    } header: {
                        Label(kind.rawValue, systemImage: kind.icon)
                            .foregroundStyle(kind.color)
                    }
                }
            }
        }
        .navigationTitle("Duties")
    }

    private func responsibilityRow(_ item: Responsibility) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                    Text("\(store.event.userName(for: item.ownerID)) • due \(item.dueDate, style: .date)")
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

            ForEach(item.checklist) { checklist in
                Label(checklist.title, systemImage: checklist.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.caption)
                    .foregroundStyle(checklist.isDone ? .green : .secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack { ResponsibilityBoardView() }
        .environment(EventStore(sampleEvent: .summerBirthday))
}
