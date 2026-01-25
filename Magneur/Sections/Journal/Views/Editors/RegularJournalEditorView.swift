//
//  RegularJournalEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editor view for regular free-form journal entries
struct RegularJournalEditorView: View {
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
                        // Title field
                        StyledTextField(
                            text: $entry.title,
                            placeholder: "Entry title...",
                            showUnderline: true,
                            isTitle: true
                        )

                        // Content area
                        VStack(alignment: .leading, spacing: 8) {
                            StyledSectionHeader(title: "Your Thoughts")
                            StyledTextArea(
                                text: $entry.content,
                                placeholder: "Write your thoughts, reflections, or anything on your mind...",
                                minHeight: 200
                            )
                        }
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
                        Image(systemName: JournalEntryType.regularJournal.icon)
                            .foregroundStyle(JournalEntryType.regularJournal.accentColor)
                        Text("Journal Entry")
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
    RegularJournalEditorView(entry: .regularJournal()) {}
}
