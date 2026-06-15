import SwiftUI

struct PlanBuilderView: View {
    @Environment(EventStore.self) private var store

    var body: some View {
        @Bindable var store = store

        List {
            Section {
                ScreenIntroBanner(
                    title: "Build the party blueprint",
                    detail: "Frame the event, generate the master plan, then tune supplies, timing, headcount, and budget before people arrive.",
                    icon: "wand.and.stars",
                    color: PartyTheme.violet
                )
            }

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
                        Text(question.options.joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Button {
                    store.regenerateSuggestedPlan()
                } label: {
                    Label("Generate Master Plan", systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(PartyTheme.violet)
                .controlSize(.large)
                .disabled(!store.canEditMasterPlan)
            } header: {
                Label("Planning Intelligence", systemImage: "brain.head.profile")
            }

            Section {
                LinearMeter(
                    title: "Budget Used",
                    value: "\(store.expenseSummary.eventTotal.currencyText) of \(store.event.budget.targetTotal.currencyText)",
                    ratio: store.budgetUsedRatio,
                    color: store.budgetUsedRatio > 1 ? .red : .green
                )
                HStack {
                    Label("Confirmed Headcount", systemImage: "person.2")
                    Spacer()
                    Text("\(store.confirmedHeadcount) of \(store.event.guestCount)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Label("Timeline Moments", systemImage: "clock")
                    Spacer()
                    Text("\(store.event.timeline.count)")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Label("Party Blueprint", systemImage: "rectangle.3.group")
            }

            Section {
                ForEach(store.planningInsights) { insight in
                    InsightCard(insight: insight)
                }
            } header: {
                Label("Plan Review", systemImage: "checklist.checked")
            }

            Section {
                ForEach(store.event.supplies) { item in
                    HStack {
                        Image(systemName: item.category.icon)
                            .foregroundStyle(item.category.color)
                        VStack(alignment: .leading) {
                            Text(item.name)
                            Text("\(item.quantity.formatted()) \(item.unit) - \(item.category.rawValue)")
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

            Section {
                ForEach(store.sortedTimeline) { moment in
                    TimelineMomentRow(moment: moment, ownerName: store.event.userName(for: moment.ownerID))
                }
            } header: {
                Label("Run of Show", systemImage: "clock.badge.checkmark")
            }
        }
        .premiumListStyle()
        .listSectionSpacing(14)
        .navigationTitle("Plan")
    }
}

#Preview {
    NavigationStack { PlanBuilderView() }
        .environment(EventStore(sampleEvent: .summerBirthday))
}
