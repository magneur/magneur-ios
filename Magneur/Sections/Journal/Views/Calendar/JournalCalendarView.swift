//
//  JournalCalendarView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Calendar view showing journal entries by day
struct JournalCalendarView: View {
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    @State private var entryCounts: [Date: Int] = [:]
    @State private var selectedDayEntries: [MindsetEntry] = []
    @State private var selectedEntry: MindsetEntry?

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 0) {
            // Month navigation
            HStack {
                Button {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                        loadEntryCounts()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.white)
                }

                Spacer()

                Text(monthYearString(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                        loadEntryCounts()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }
            .padding()

            // Weekday headers
            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            entryCount: entryCounts[calendar.startOfDay(for: date)] ?? 0,
                            isToday: calendar.isDateInToday(date)
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedDate = date
                                loadSelectedDayEntries()
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
            .padding(.horizontal)

            // Selected day entries
            if !selectedDayEntries.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Entries for \(formattedDate(selectedDate))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal)
                        .padding(.top, 16)

                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(selectedDayEntries) { entry in
                                MindsetEntryCardView(entry: entry) {
                                    selectedEntry = entry
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Spacer()
                    Text("No entries for this day")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                }
            }
        }
        .sheet(item: $selectedEntry) { entry in
            entryEditor(for: entry)
        }
        .onAppear {
            loadEntryCounts()
            loadSelectedDayEntries()
        }
    }

    // MARK: - Helper Functions

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let firstWeekday = calendar.firstWeekday
        return Array(symbols[(firstWeekday - 1)...]) + Array(symbols[..<(firstWeekday - 1)])
    }

    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var days: [Date?] = []
        var currentDate = firstWeek.start

        // Add days from start of first week
        while currentDate < monthInterval.start {
            days.append(nil)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        // Add days of the month
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        // Fill remaining cells to complete the grid
        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func loadEntryCounts() {
        entryCounts = JournalStore.shared.entryCounts(for: currentMonth)
    }

    private func loadSelectedDayEntries() {
        selectedDayEntries = JournalStore.shared.fetchEntries(for: selectedDate)
    }

    @ViewBuilder
    private func entryEditor(for entry: MindsetEntry) -> some View {
        switch entry.entryType {
        case .regularJournal:
            RegularJournalEditorView(entry: entry) {
                loadEntryCounts()
                loadSelectedDayEntries()
            }
        case .dailyBullet:
            DailyBulletEditorView(entry: entry) {
                loadEntryCounts()
                loadSelectedDayEntries()
            }
        case .bigGoal:
            BigGoalEditorView(entry: entry) {
                loadEntryCounts()
                loadSelectedDayEntries()
            }
        case .imaginalAct:
            ImaginalActEditorView(entry: entry) {
                loadEntryCounts()
                loadSelectedDayEntries()
            }
        case .rewriteAssumption:
            RewriteAssumptionEditorView(entry: entry) {
                loadEntryCounts()
                loadSelectedDayEntries()
            }
        }
    }
}

/// Individual day cell in the calendar
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let entryCount: Int
    let isToday: Bool
    let action: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.body)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isSelected ? .white : (isToday ? .purple : .white.opacity(0.8)))

                if entryCount > 0 {
                    Circle()
                        .fill(.purple)
                        .frame(width: 6, height: 6)
                } else {
                    Color.clear
                        .frame(height: 6)
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(
                isSelected
                    ? Circle().fill(.purple.opacity(0.8))
                    : nil
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

        JournalCalendarView()
    }
}
