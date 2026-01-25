//
//  RewriteAssumptionEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editor view for rewriting limiting assumptions
struct RewriteAssumptionEditorView: View {
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
                        // Title
                        StyledTextField(
                            text: $entry.title,
                            placeholder: "Name this transformation...",
                            showUnderline: true,
                            isTitle: true
                        )

                        // Assumption pairs
                        AssumptionPairEditor(
                            oldItems: $entry.oldAssumptions,
                            newItems: $entry.newAssumptions
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
                        Image(systemName: JournalEntryType.rewriteAssumption.icon)
                            .foregroundStyle(JournalEntryType.rewriteAssumption.accentColor)
                        Text("Rewrite Assumption")
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
    RewriteAssumptionEditorView(entry: .rewriteAssumption()) {}
}
