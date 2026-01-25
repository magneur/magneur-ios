//
//  EntryTypeFilterView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Horizontal filter chips for filtering entries by type
struct EntryTypeFilterView: View {
    @Binding var selectedType: JournalEntryType?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All entries chip
                FilterChip(
                    title: "All",
                    icon: "square.grid.2x2.fill",
                    isSelected: selectedType == nil,
                    color: .white
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedType = nil
                    }
                }

                // Type-specific chips
                ForEach(JournalEntryType.allCases) { type in
                    FilterChip(
                        title: type.shortName,
                        icon: type.icon,
                        isSelected: selectedType == type,
                        color: type.accentColor
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedType = type
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

/// Individual filter chip button
struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? AnyShapeStyle(color.opacity(0.8)) : AnyShapeStyle(.ultraThinMaterial.opacity(0.3))
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? color : .white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
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

        VStack {
            EntryTypeFilterView(selectedType: .constant(nil))
            Spacer()
        }
        .padding(.top, 20)
    }
}
