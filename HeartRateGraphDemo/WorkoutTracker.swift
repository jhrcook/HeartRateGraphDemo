//
//  WorkoutTracker.swift
//  HeartRateGraphDemo
//
//  Created by Joshua on 11/1/20.
//

import Foundation



class WorkoutTracker: NSObject, ObservableObject {
    var data = [WorkoutTrackerDatum]()
    var numberOfExercises: Int {
        data.count
    }
    
    func addData(duration: Double, activeCalories: Double, heartRate: [Double]) {
        let newData = WorkoutTrackerDatum(duration: duration, activeCalories: activeCalories, heartRate: heartRate)
        data.append(newData)
    }
    
    override init() {
        self.data = WorkoutTracker.makeMockData()
        for d in data {
            print(d)
        }
    }
    
    static func makeMockData(numWorkouts: Int = 5) -> [WorkoutTrackerDatum] {
        var mockData = [WorkoutTrackerDatum]()
        for _ in 0..<numWorkouts {
            var HRReadings: [Double] = [20.0]
            let numHRReadings: Int = Int.random(in: 3...20)
            for _ in 1..<numHRReadings {
                let previousHR: Double = HRReadings.last!
                HRReadings.append(previousHR + Double.random(in: -5.0...5.0))
            }
            mockData.append(WorkoutTrackerDatum(duration: 5, activeCalories: 5, heartRate: HRReadings))
        }
        return mockData
    }
}


struct WorkoutTrackerDatum: Identifiable {
    let id = UUID()
    let duration: Double
    let activeCalories: Double
    let heartRate: [Double]
}

