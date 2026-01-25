//
//  BigGoalEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editor view for big goal entries
struct BigGoalEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var entry: MindsetEntry
    let onSave: () -> Void

    init(entry: MindsetEntry, onSave: @escaping () -> Void) {
        _entry = State(initialValue: entry)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: AppSection.journal.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Goal title
                        StyledTextField(
                            text: $entry.title,
                            placeholder: "What's your big goal?",
                            showUnderline: true,
                            isTitle: true
                        )

                        // Outcomes
                        BulletPointListEditor(
                            items: $entry.bulletPoints,
                            sectionTitle: "Desired Outcomes",
                            placeholder: "When this goal is achieved, I will..."
                        )
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }

                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: JournalEntryType.bigGoal.icon)
                            .foregroundStyle(JournalEntryType.bigGoal.accentColor)
                        Text("Big Goal")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .disabled(!entry.hasContent)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private func saveEntry() {
        entry.updatedAt = Date()
        JournalStore.shared.saveEntry(entry)
        onSave()
        dismiss()
    }
}

#Preview {
    BigGoalEditorView(entry: .bigGoal(title: "Launch my app", outcomes: [""])) {}
}
