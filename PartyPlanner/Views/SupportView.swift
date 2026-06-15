import SwiftUI

struct SupportView: View {
    @State private var searchText = ""

    private var filteredTopics: [HelpTopic] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return HelpCenterContent.topics
        }
        return HelpCenterContent.topics.filter { topic in
            topic.title.localizedCaseInsensitiveContains(searchText)
            || topic.summary.localizedCaseInsensitiveContains(searchText)
            || topic.steps.contains { $0.localizedCaseInsensitiveContains(searchText) }
            || topic.relatedTerms.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private var filteredTerms: [HelpTerm] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return HelpCenterContent.terms
        }
        return HelpCenterContent.terms.filter { term in
            term.name.localizedCaseInsensitiveContains(searchText)
            || term.definition.localizedCaseInsensitiveContains(searchText)
            || term.example.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            Section {
                ForEach(HelpCenterContent.quickPrompts) { prompt in
                    supportPrompt(prompt)
                }
            } header: {
                Label("Training", systemImage: "graduationcap")
            }

            Section {
                ForEach(HelpCategory.allCases) { category in
                    let categoryTopics = filteredTopics.filter { $0.category == category }
                    if !categoryTopics.isEmpty {
                        DisclosureGroup {
                            ForEach(categoryTopics) { topic in
                                topicCard(topic)
                            }
                        } label: {
                            Label(category.rawValue, systemImage: category.icon)
                                .foregroundStyle(category.color)
                        }
                    }
                }
            } header: {
                Label("How To", systemImage: "questionmark.circle")
            }

            Section {
                ForEach(filteredTerms) { term in
                    definitionCard(term)
                }
            } header: {
                Label("Definitions", systemImage: "book.closed")
            }

            Section {
                supportPolicyRow(title: "When something changes", detail: "Post public updates for plan changes. Use private messages for one-person questions. Use owner-only notes for host coordination.")
                supportPolicyRow(title: "When expenses start", detail: "Add receipts immediately, pick the category, and let the owner confirm the split policy.")
                supportPolicyRow(title: "When the event day starts", detail: "Use Command first. It shows readiness, next actions, the run of show, and blocked work.")
            } header: {
                Label("Best Practices", systemImage: "lightbulb")
            }
        }
        .premiumListStyle()
        .listSectionSpacing(14)
        .navigationTitle("Support")
        .searchable(text: $searchText, prompt: "Search help, terms, or how-to")
    }

    private func supportPrompt(_ prompt: SupportPrompt) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: prompt.icon)
                .font(.headline)
                .foregroundStyle(prompt.color)
                .frame(width: 34, height: 34)
                .background(prompt.color.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 4) {
                Text(prompt.title)
                    .font(.headline)
                Text(prompt.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func topicCard(_ topic: HelpTopic) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(topic.title)
                .font(.headline)
            Text(topic.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(Array(topic.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .frame(width: 22, height: 22)
                        .background(topic.category.color.opacity(0.14), in: Circle())
                        .foregroundStyle(topic.category.color)
                    Text(step)
                        .font(.subheadline)
                }
            }
            if !topic.relatedTerms.isEmpty {
                Text(topic.relatedTerms.joined(separator: ", "))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }

    private func definitionCard(_ term: HelpTerm) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(term.name)
                .font(.headline)
            Text(term.definition)
                .font(.subheadline)
            Text("Example: \(term.example)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 5)
    }

    private func supportPolicyRow(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack { SupportView() }
}
