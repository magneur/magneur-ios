//
//  FitnessCalendarView.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import SwiftUI

/// Calendar view showing scheduled and completed workouts
struct FitnessCalendarView: View {
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var scheduledWorkouts: [WorkoutOccurrence] = []
    @State private var completedWorkouts: [CompletedWorkout] = []
    @State private var selectedWorkout: Workout?
    
    private let calendar = Calendar.current
    private let daysInWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Month navigation
                HStack {
                    Button {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    Text(monthYearString)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal)
                
                // Calendar grid
                VStack(spacing: 8) {
                    // Day headers
                    HStack {
                        ForEach(daysInWeek, id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.white.opacity(0.6))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // Calendar days
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(daysInMonth, id: \.self) { date in
                            if let date = date {
                                CalendarDayView(
                                    date: date,
                                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                    hasScheduledWorkout: hasScheduledWorkout(on: date),
                                    hasCompletedWorkout: hasCompletedWorkout(on: date)
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedDate = date
                                    }
                                }
                            } else {
                                Color.clear
                                    .frame(height: 40)
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial.opacity(0.3))
                )
                .padding(.horizontal)
                
                // Workouts for selected day
                VStack(alignment: .leading, spacing: 12) {
                    Text(selectedDateString)
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    let dayWorkouts = workoutsForSelectedDate
                    
                    if dayWorkouts.isEmpty {
                        Text("No workouts scheduled")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    } else {
                        ForEach(dayWorkouts, id: \.workout.id) { occurrence in
                            CalendarWorkoutRow(occurrence: occurrence)
                                .onTapGesture {
                                    selectedWorkout = occurrence.workout
                                }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial.opacity(0.3))
                )
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .onAppear {
            loadData()
        }
        .onChange(of: currentMonth) { _, _ in
            loadData()
        }
        .navigationDestination(item: $selectedWorkout) { workout in
            WorkoutDetailView(workout: workout)
        }
    }
    
    // MARK: - Computed Properties
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: selectedDate)
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var date = monthFirstWeek.start
        
        // Add nil for days before month start
        while date < monthInterval.start {
            days.append(nil)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        // Add actual days
        while date < monthInterval.end {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        // Pad to complete week
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private var workoutsForSelectedDate: [WorkoutOccurrence] {
        scheduledWorkouts.filter { occurrence in
            calendar.isDate(occurrence.date, inSameDayAs: selectedDate)
        }
    }
    
    // MARK: - Helpers
    
    private func hasScheduledWorkout(on date: Date) -> Bool {
        scheduledWorkouts.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func hasCompletedWorkout(on date: Date) -> Bool {
        completedWorkouts.contains { workout in
            guard let workoutDate = workout.startDate else { return false }
            return calendar.isDate(workoutDate, inSameDayAs: date)
        }
    }
    
    private func loadData() {
        // Load scheduled workouts for this month
        let workouts = WorkoutStore.shared.fetchWorkouts()
        var occurrences: [WorkoutOccurrence] = []
        
        for workout in workouts {
            occurrences.append(contentsOf: generateOccurrences(for: workout, in: currentMonth))
        }
        
        scheduledWorkouts = occurrences.sorted { $0.date < $1.date }
        
        // Load completed workouts
        completedWorkouts = WorkoutStore.shared.fetchCompletedWorkouts()
    }
    
    private func generateOccurrences(for workout: Workout, in month: Date) -> [WorkoutOccurrence] {
        guard let startDate = workout.startDate else { return [] }
        
        var occurrences: [WorkoutOccurrence] = []
        
        // Get month bounds
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else {
            return []
        }
        
        // If no recurrence, just check if start date is in this month
        if workout.recurrenceString == nil || workout.recurrenceString?.isEmpty == true {
            if startDate >= monthInterval.start && startDate < monthInterval.end {
                occurrences.append(WorkoutOccurrence(workout: workout, date: startDate))
            }
            return occurrences
        }
        
        // Parse the recurrence rule and generate occurrences
        if let recurrenceString = workout.recurrenceString,
           let rule = RecurrenceRule.parse(recurrenceString) {
            
            let generatedDates = RecurrenceGenerator.generateOccurrences(
                for: rule,
                startDate: startDate,
                inRange: monthInterval,
                calendar: calendar
            )
            
            for date in generatedDates {
                occurrences.append(WorkoutOccurrence(workout: workout, date: date))
            }
        }
        
        // Remove duplicates by date
        var seenDates = Set<DateComponents>()
        occurrences = occurrences.filter { occurrence in
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: occurrence.date)
            if seenDates.contains(components) {
                return false
            }
            seenDates.insert(components)
            return true
        }
        
        return occurrences
    }
}

// MARK: - Calendar Day View

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let hasScheduledWorkout: Bool
    let hasCompletedWorkout: Bool
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayNumber)
                .font(.system(size: 16, weight: isToday ? .bold : .regular))
                .foregroundStyle(isSelected ? .white : (isToday ? .orange : .white.opacity(0.9)))
            
            // Indicators
            HStack(spacing: 2) {
                if hasScheduledWorkout {
                    Circle()
                        .fill(.orange)
                        .frame(width: 6, height: 6)
                }
                if hasCompletedWorkout {
                    Circle()
                        .fill(.green)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(height: 6)
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? .white.opacity(0.2) : .clear)
        )
    }
}

// MARK: - Calendar Workout Row

struct CalendarWorkoutRow: View {
    let occurrence: WorkoutOccurrence
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: occurrence.workout.color ?? "#FF5722") ?? .orange)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(occurrence.workout.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                
                Text("\(occurrence.workout.exercises.count) exercises")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial.opacity(0.2))
        )
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color.orange.ignoresSafeArea()
            FitnessCalendarView()
        }
    }
}
