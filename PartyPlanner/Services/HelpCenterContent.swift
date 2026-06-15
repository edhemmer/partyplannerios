import Foundation
import SwiftUI

enum HelpCenterContent {
    static let quickPrompts: [SupportPrompt] = [
        SupportPrompt(title: "Start Here", detail: "Create the event frame, generate the plan, then invite helpers.", icon: "play.circle", color: .blue),
        SupportPrompt(title: "Owner Mode", detail: "Owners control venue, assignments, budget targets, and official timeline.", icon: "crown", color: .pink),
        SupportPrompt(title: "Helper Mode", detail: "Helpers update only their own work, receipts, notes, and RSVP details.", icon: "person.crop.circle.badge.checkmark", color: .green)
    ]

    static let terms: [HelpTerm] = [
        HelpTerm(name: "Command", definition: "The host dashboard that shows readiness, priority work, smart actions, venue, updates, and timing.", example: "Open Command the morning of the event to see what still needs attention."),
        HelpTerm(name: "Next Best Actions", definition: "A prioritized list of the most useful actions the app recommends based on current gaps.", example: "If 12 guests have not responded, the first action may be to send RSVP reminders."),
        HelpTerm(name: "Readiness Score", definition: "A simple planning-health score based on completed duties, packed supplies, owned meals, and event progress.", example: "A 72% score means the event is moving well but still has unresolved work."),
        HelpTerm(name: "Run of Show", definition: "The hour-by-hour execution timeline for setup, food, guest arrival, activities, and breakdown.", example: "Setup crew arrives at 11:00 AM, bar is iced at 1:00 PM, guests arrive at 2:00 PM."),
        HelpTerm(name: "Crew", definition: "The people involved in the event, including owner, cohosts, helpers, and guests.", example: "A helper assigned to bar can update bar tasks and receipts."),
        HelpTerm(name: "Responsibility", definition: "A job assigned to one person with due date, status, and checklist items.", example: "Nina owns Bar, soft drinks, and ice."),
        HelpTerm(name: "Supply Item", definition: "A thing that must be bought, brought, packed, staged, or confirmed.", example: "Cups, ice, serving utensils, chairs, trash bags."),
        HelpTerm(name: "RSVP Confidence", definition: "A planning view of who is going, maybe going, not going, or has not responded.", example: "The host can plan for 34 confirmed guests and follow up with 8 unknowns."),
        HelpTerm(name: "Budget Health", definition: "The comparison between actual expenses and the event budget target.", example: "The app shows $635 spent against an $1,800 target."),
        HelpTerm(name: "Split Policy", definition: "The rule that decides who shares an expense.", example: "Adults only, equal split, assigned users, or owner pays."),
        HelpTerm(name: "Trust Score", definition: "A quick signal for whether the event data is synced, complete, conflict-free, and backed by evidence.", example: "A 92% trust score means the plan is current and has no major data gaps."),
        HelpTerm(name: "Audit Trail", definition: "A history of important changes made to the event plan.", example: "Maya regenerated the plan, Andre updated dinner, Nina added a bar receipt."),
        HelpTerm(name: "Realtime Sync", definition: "The live connection that keeps event changes available to everyone.", example: "When a helper marks bar supplies ready, the owner sees it without refreshing."),
        HelpTerm(name: "Conflict", definition: "A situation where two edits need review before the app can decide which version is official.", example: "Two people edit the same meal quantity while one device is offline.")
    ]

    static let topics: [HelpTopic] = [
        HelpTopic(
            category: .gettingStarted,
            title: "Create a strong event plan",
            summary: "Frame the event once, then let the app generate a complete starting plan.",
            steps: [
                "Open Plan and choose the event preset.",
                "Enter guest count, age group, start time, end time, and venue.",
                "Answer the planning questions about food, drinks, expenses, and service style.",
                "Tap Generate Master Plan.",
                "Review supplies, run of show, assignments, and budget targets before inviting helpers."
            ],
            relatedTerms: ["Plan", "Run of Show", "Supply Item"]
        ),
        HelpTopic(
            category: .ownerGuide,
            title: "Invite helpers without losing control",
            summary: "Owners and cohosts control the master plan while helpers update their own pieces.",
            steps: [
                "Add each helper to Crew with contact information.",
                "Assign them responsibilities like meal, bar, setup, decorations, or breakdown.",
                "Review whether their tasks have checklist items and due dates.",
                "Post expectations on the Board.",
                "Use Command to watch updates and blocked work."
            ],
            relatedTerms: ["Crew", "Responsibility", "Command"]
        ),
        HelpTopic(
            category: .helperGuide,
            title: "Update your assigned work",
            summary: "Helpers should keep their own responsibilities accurate so the host does not chase everyone.",
            steps: [
                "Open Crew.",
                "Check My Work.",
                "Update the responsibility status when you buy, pack, prepare, or complete something.",
                "Add a note if something is blocked.",
                "Capture receipts in Money for out-of-pocket expenses."
            ],
            relatedTerms: ["Helper Mode", "Responsibility", "Money"]
        ),
        HelpTopic(
            category: .expenses,
            title: "Track receipts and split costs",
            summary: "Keep total event cost, category totals, and each person share clear.",
            steps: [
                "Open Money.",
                "Confirm the default split policy.",
                "Add each receipt as soon as someone pays.",
                "Choose the category: meals, bar, venue, supplies, activities, music, or transportation.",
                "The owner or cohost reviews assigned splits and budget health."
            ],
            relatedTerms: ["Budget Health", "Split Policy", "Expense"]
        ),
        HelpTopic(
            category: .definitions,
            title: "Understand roles and permissions",
            summary: "The app is designed so everyone can help without breaking the master plan.",
            steps: [
                "Owner controls venue, event frame, master plan, budget, and assignments.",
                "Cohost can help manage the master event.",
                "Helper updates assigned work, notes, receipts, and RSVP details.",
                "Guest can view event details and update RSVP information.",
                "Private messages and owner-only notes stay scoped to the right people."
            ],
            relatedTerms: ["Owner Mode", "Helper Mode", "Privacy"]
        ),
        HelpTopic(
            category: .troubleshooting,
            title: "Fix a messy or incomplete plan",
            summary: "Use the app intelligence to find missing owners, weak sections, and blocked work.",
            steps: [
                "Open Command and read Next Best Actions.",
                "Open Plan and review all intelligence cards.",
                "Assign unowned supplies and responsibilities.",
                "Check Crew for missing RSVPs or unclear party sizes.",
                "Post a Board update after major changes."
            ],
            relatedTerms: ["Next Best Actions", "Readiness Score", "RSVP Confidence"]
        ),
        HelpTopic(
            category: .troubleshooting,
            title: "Trust the live plan",
            summary: "Use Live Trust to verify that the event data is fresh, synced, and backed by receipts or assignments.",
            steps: [
                "Open Command.",
                "Review Live Trust and the trust score.",
                "Check whether realtime sync is Live or Needs Attention.",
                "Resolve any conflict, missing receipt, overdue work, or unassigned supply warnings.",
                "Review Recent Changes before making major event-day decisions."
            ],
            relatedTerms: ["Trust Score", "Realtime Sync", "Audit Trail", "Conflict"]
        ),
        HelpTopic(
            category: .privacy,
            title: "Know what others can edit",
            summary: "The app should be collaborative without becoming chaotic.",
            steps: [
                "Owners and cohosts manage the official event structure.",
                "Helpers edit their own assignments and receipts.",
                "Guests update RSVP and contact-related details.",
                "Private messages are visible only to sender and recipients.",
                "Owner-only notes are for host-side coordination."
            ],
            relatedTerms: ["Privacy", "Owner Mode", "Helper Mode"]
        )
    ]
}
