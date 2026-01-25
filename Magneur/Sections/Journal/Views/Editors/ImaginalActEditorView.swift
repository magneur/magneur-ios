//
//  ImaginalActEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editor view for imaginal act entries (visualization scenes)
struct ImaginalActEditorView: View {
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
                        // Scene title
                        StyledTextField(
                            text: $entry.title,
                            placeholder: "Name your scene...",
                            showUnderline: true,
                            isTitle: true
                        )

                        // Scene description
                        VStack(alignment: .leading, spacing: 8) {
                            StyledSectionHeader(title: "Scene Description")
                            StyledTextArea(
                                text: $entry.sceneDescription,
                                placeholder: "Describe your imaginal scene in vivid detail. What do you see, hear, and feel? Make it as real as possible...",
                                minHeight: 200
                            )
                        }

                        // Reminder toggle (optional feature for Phase 5)
                        VStack(alignment: .leading, spacing: 12) {
                            StyledSectionHeader(title: "Bedtime Reminder")

                            Toggle(isOn: $entry.notificationsEnabled) {
                                Text("Enable bedtime reminder")
                                    .font(.body)
                                    .foregroundStyle(.white)
                            }
                            .tint(.purple)
                            .padding()
                            .background(.ultraThinMaterial.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            if entry.notificationsEnabled {
                                DatePicker(
                                    "Reminder Time",
                                    selection: Binding(
                                        get: { entry.reminderTime ?? Date() },
                                        set: { entry.reminderTime = $0 }
                                    ),
                                    displayedComponents: .hourAndMinute
                                )
                                .datePickerStyle(.compact)
                                .colorScheme(.dark)
                                .padding()
                                .background(.ultraThinMaterial.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
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
                        Image(systemName: JournalEntryType.imaginalAct.icon)
                            .foregroundStyle(JournalEntryType.imaginalAct.accentColor)
                        Text("Imaginal Act")
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
    ImaginalActEditorView(entry: .imaginalAct()) {}
}
