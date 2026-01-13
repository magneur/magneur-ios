//
//  Exercise.swift
//  Magneur Fitness
//
//  Created by Andrei Istoc on 08.06.2022.
//

import Foundation
import HealthKit

public enum ExecutionType: Int, Codable {
    case setsReps
    case timedSets
    case timedExercise
    case distance
    case open
}

public struct Exercise: Identifiable, Hashable, Codable {
    public var id: String
    var name: String
    var description: String
    let sportCategory: SportCategory
    let sport: UInt
    let category: ExerciseCategory
    let executionType: ExecutionType
    var isCustom: Bool?
}

public enum SportCategory: String, Codable, CaseIterable {
    case mobility
    case weightlifting
    case fitness
    case cardio
    case sport
    case other
}

public enum ExerciseCategory: String, Codable, CaseIterable {
    case barbell
    case dumbbell
    case kettlebell
    case machine
    case other
    case bodyweight
    case resistanceBand
    case sport
    case duration
}




