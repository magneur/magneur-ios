//
//  DailyBulletEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editor view for daily bullet journal entries
struct DailyBulletEditorView: View {
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
                        // Date display
                        Text(entry.formattedDate)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        // Bullet points
                        BulletPointListEditor(
                            items: $entry.bulletPoints,
                            sectionTitle: "Today's Reflections",
                            placeholder: "What's on your mind..."
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
                        Image(systemName: JournalEntryType.dailyBullet.icon)
                            .foregroundStyle(JournalEntryType.dailyBullet.accentColor)
                        Text("Daily Bullets")
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
    DailyBulletEditorView(entry: .dailyBullet(bulletPoints: ["First thought", ""])) {}
}
