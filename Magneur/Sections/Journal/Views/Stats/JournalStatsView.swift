//
//  JournalStatsView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Statistics dashboard for journal entries
struct JournalStatsView: View {
    @State private var totalCount: Int = 0
    @State private var currentStreak: Int = 0
    @State private var typeCounts: [JournalEntryType: Int] = [:]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overview stats
                HStack(spacing: 16) {
                    StatCard(
                        title: "Total Entries",
                        value: "\(totalCount)",
                        icon: "book.fill",
                        color: .purple
                    )

                    StatCard(
                        title: "Current Streak",
                        value: "\(currentStreak)",
                        icon: "flame.fill",
                        color: .orange
                    )
                }

                // Entry type breakdown
                VStack(alignment: .leading, spacing: 16) {
                    Text("Entry Types")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal)

                    ForEach(JournalEntryType.allCases) { type in
                        TypeStatRow(
                            type: type,
                            count: typeCounts[type] ?? 0,
                            total: totalCount
                        )
                    }
                }
                .padding(.top, 8)
            }
            .padding()
            .padding(.bottom, 100)
        }
        .onAppear {
            loadStats()
        }
    }

    private func loadStats() {
        totalCount = JournalStore.shared.totalEntryCount()
        currentStreak = JournalStore.shared.currentStreak()

        for type in JournalEntryType.allCases {
            typeCounts[type] = JournalStore.shared.entryCount(forType: type)
        }
    }
}

/// Stat card for displaying a single statistic
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}

/// Row showing stats for a specific entry type
struct TypeStatRow: View {
    let type: JournalEntryType
    let count: Int
    let total: Int

    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: type.icon)
                    .foregroundStyle(type.accentColor)
                    .frame(width: 24)

                Text(type.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.white)

                Spacer()

                Text("\(count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.1))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(type.accentColor)
                        .frame(width: geometry.size.width * percentage, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
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

        JournalStatsView()
    }
}
