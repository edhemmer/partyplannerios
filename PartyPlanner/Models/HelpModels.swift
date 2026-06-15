import Foundation
import SwiftUI

enum HelpCategory: String, CaseIterable, Identifiable {
    case gettingStarted = "Getting Started"
    case definitions = "Definitions"
    case ownerGuide = "Owner Guide"
    case helperGuide = "Helper Guide"
    case expenses = "Expenses"
    case troubleshooting = "Troubleshooting"
    case privacy = "Privacy"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .gettingStarted: "figure.wave"
        case .definitions: "book.closed"
        case .ownerGuide: "crown"
        case .helperGuide: "person.crop.circle.badge.checkmark"
        case .expenses: "receipt"
        case .troubleshooting: "wrench.and.screwdriver"
        case .privacy: "lock.shield"
        }
    }

    var color: Color {
        switch self {
        case .gettingStarted: .blue
        case .definitions: .purple
        case .ownerGuide: .pink
        case .helperGuide: .green
        case .expenses: .orange
        case .troubleshooting: .cyan
        case .privacy: .indigo
        }
    }
}

struct HelpTopic: Identifiable, Hashable {
    var id = UUID()
    var category: HelpCategory
    var title: String
    var summary: String
    var steps: [String]
    var relatedTerms: [String]
}

struct HelpTerm: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var definition: String
    var example: String
}

struct SupportPrompt: Identifiable {
    var id = UUID()
    var title: String
    var detail: String
    var icon: String
    var color: Color
}
