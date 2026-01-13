//
//  PoolWorkout.swift
//  Magneur Fitness
//
//  Created by Andrei Istoc on 02.12.2023.
//

import Foundation

class PoolWorkout {
    let workout: Workout
    var executions: Int = 0
    var displaySize: CGFloat {
        return max(min(80 - log(pow(Double(executions), 40)), 80), 30)
    }
    
    init(workout: Workout) {
        self.workout = workout
    }
}
