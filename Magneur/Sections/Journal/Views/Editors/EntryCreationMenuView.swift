//
//  EntryCreationMenuView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Sheet for selecting which type of entry to create
struct EntryCreationMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEditor: JournalEntryType?

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
                    VStack(spacing: 16) {
                        Text("What would you like to write?")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.top, 20)

                        ForEach(JournalEntryType.allCases) { type in
                            EntryTypeButton(type: type) {
                                selectedEditor = type
                            }
                        }
                    }
                    .padding()
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
                    Text("New Entry")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(item: $selectedEditor) { type in
                editorView(for: type)
            }
        }
    }

    @ViewBuilder
    private func editorView(for type: JournalEntryType) -> some View {
        switch type {
        case .regularJournal:
            RegularJournalEditorView(entry: .regularJournal()) {
                dismiss()
            }
        case .dailyBullet:
            DailyBulletEditorView(entry: .dailyBullet()) {
                dismiss()
            }
        case .bigGoal:
            BigGoalEditorView(entry: .bigGoal()) {
                dismiss()
            }
        case .imaginalAct:
            ImaginalActEditorView(entry: .imaginalAct()) {
                dismiss()
            }
        case .rewriteAssumption:
            RewriteAssumptionEditorView(entry: .rewriteAssumption()) {
                dismiss()
            }
        }
    }
}

/// Button for selecting an entry type
struct EntryTypeButton: View {
    let type: JournalEntryType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundStyle(type.accentColor)
                    .frame(width: 44, height: 44)
                    .background(type.accentColor.opacity(0.2))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(type.displayName)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(type.description)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(16)
            .background(.ultraThinMaterial.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    EntryCreationMenuView()
}
