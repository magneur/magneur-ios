//
//  MindsetEntryCardView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Card view displaying a mindset journal entry in the list
struct MindsetEntryCardView: View {
    let entry: MindsetEntry
    var onTap: () -> Void = {}
    var onDelete: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with icon and type
                HStack {
                    Image(systemName: entry.entryType.icon)
                        .foregroundStyle(entry.entryType.accentColor)
                        .font(.title3)

                    Text(entry.displayTitle)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Spacer()

                    Text(entry.formattedTime)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                // Preview content
                Text(entry.previewText)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                // Date and type badge
                HStack {
                    Text(entry.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))

                    Spacer()

                    Text(entry.entryType.shortName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(entry.entryType.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(entry.entryType.accentColor.opacity(0.2))
                        .clipShape(Capsule())
                }
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
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.purple, .pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(spacing: 12) {
                MindsetEntryCardView(
                    entry: .regularJournal(title: "Today's Thoughts", content: "I had a great day today. I accomplished a lot and felt really productive. The morning started off slow but I picked up momentum...")
                )

                MindsetEntryCardView(
                    entry: .dailyBullet(bulletPoints: ["Completed my workout", "Finished the project", "Called mom"])
                )

                MindsetEntryCardView(
                    entry: .bigGoal(title: "Launch My App", outcomes: ["Build MVP", "Get 100 users", "Generate revenue"])
                )

                MindsetEntryCardView(
                    entry: .imaginalAct(title: "Success Celebration", sceneDescription: "I'm standing on stage receiving an award for my work...")
                )

                MindsetEntryCardView(
                    entry: .rewriteAssumption(title: "Confidence Shift", oldAssumptions: ["I'm not good enough"], newAssumptions: ["I am capable and worthy"])
                )
            }
            .padding()
        }
    }
}
