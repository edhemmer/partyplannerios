import SwiftUI

struct PlanBuilderView: View {
    @Environment(EventStore.self) private var store

    var body: some View {
        @Bindable var store = store

        List {
            Section {
                Picker("Preset", selection: $store.event.preset) {
                    ForEach(EventPreset.allCases) { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                Stepper("Guests: \(store.event.guestCount)", value: $store.event.guestCount, in: 1...500)
                TextField("Age group", text: $store.event.ageGroup)
                DatePicker("Starts", selection: $store.event.startsAt)
                DatePicker("Ends", selection: $store.event.endsAt)
            } header: {
                Label("Event Frame", systemImage: "calendar.badge.plus")
            }

            Section {
                ForEach(store.setupQuestions) { question in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(question.prompt)
                            .font(.subheadline.weight(.semibold))
                        Text(question.options.joined(separator: " • "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Button {
                    store.regenerateSuggestedPlan()
                } label: {
                    Label("Generate Master Plan", systemImage: "wand.and.stars")
                }
                .disabled(!store.canEditMasterPlan)
            } header: {
                Label("Planning Intelligence", systemImage: "brain.head.profile")
            }

            Section {
                ForEach(store.event.supplies) { item in
                    HStack {
                        Image(systemName: item.category.icon)
                            .foregroundStyle(item.category.color)
                        VStack(alignment: .leading) {
                            Text(item.name)
                            Text("\(item.quantity.formatted()) \(item.unit) • \(item.category.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(store.event.userName(for: item.assignedUserID))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Label("Master Supply List", systemImage: "cart")
            }
        }
        .navigationTitle("Plan")
    }
}

#Preview {
    NavigationStack { PlanBuilderView() }
        .environment(EventStore(sampleEvent: .summerBirthday))
}
