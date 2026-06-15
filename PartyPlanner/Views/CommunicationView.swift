import SwiftUI

struct CommunicationView: View {
    @Environment(EventStore.self) private var store
    @State private var draft = ""
    @State private var visibility: NoteVisibility = .eventBoard

    var body: some View {
        List {
            Section {
                ScreenIntroBanner(
                    title: "Keep everyone aligned",
                    detail: "Post public updates, send private messages, and keep owner-only notes out of the main party board.",
                    icon: "bubble.left.and.bubble.right",
                    color: PartyTheme.ember
                )
            }

            Section {
                Picker("Visibility", selection: $visibility) {
                    Text("Main Board").tag(NoteVisibility.eventBoard)
                    Text("Private").tag(NoteVisibility.privateMessage)
                    Text("Owner Only").tag(NoteVisibility.ownerOnly)
                }
                TextField("Write an update, note, or private message", text: $draft, axis: .vertical)
                    .lineLimit(3...6)
                Button {
                    store.addNote(message: draft, visibility: visibility)
                    draft = ""
                } label: {
                    Label("Post", systemImage: "paperplane.fill")
                }
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .buttonStyle(.borderedProminent)
                .tint(PartyTheme.ember)
            } header: {
                Label("Communicate", systemImage: "bubble.left.and.bubble.right")
            }

            Section {
                ForEach(store.event.notes) { note in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(store.event.userName(for: note.authorID))
                                .font(.caption.weight(.semibold))
                            Spacer()
                            Text(note.createdAt, style: .time)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Text(note.message)
                            .font(.body)
                        Text(label(for: note.visibility))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(PartyTheme.lagoon.opacity(0.08))
                    )
                }
            } header: {
                Label("Event Board", systemImage: "list.bullet.rectangle")
            }
        }
        .premiumListStyle()
        .listSectionSpacing(14)
        .navigationTitle("Board")
    }

    private func label(for visibility: NoteVisibility) -> String {
        switch visibility {
        case .eventBoard: "Public event board"
        case .privateMessage: "Private message"
        case .ownerOnly: "Owner-only note"
        }
    }
}

#Preview {
    NavigationStack { CommunicationView() }
        .environment(EventStore(sampleEvent: .summerBirthday))
}
