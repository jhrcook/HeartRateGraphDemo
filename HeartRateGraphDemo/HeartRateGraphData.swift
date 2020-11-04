//
//  HeartRateGraphData.swift
//  HeartRateGraphDemo
//
//  Created by Joshua on 11/4/20.
//

import Foundation

struct HeartRateGraphDatum {
    let x: Double
    let y: Double
    let groupIndex: Int
}

struct HeartRateGraphData {
    var data: [HeartRateGraphDatum]
    
    var minX: Double {
        return data.map { $0.x }.min()!
    }
    var minY: Double {
        return data.map { $0.y }.min()!
    }
    var maxX: Double {
        return data.map { $0.x }.max()!
    }
    var maxY: Double {
        return data.map { $0.y }.max()!
    }
    
    init(workoutTraker: WorkoutTracker) {
        self.data = HeartRateGraphData.workoutTrackerDataToGraphData(workoutTraker)
    }
    
    static func workoutTrackerDataToGraphData(_ workoutTracker: WorkoutTracker) -> [HeartRateGraphDatum] {
        var HRData = [HeartRateGraphDatum]()
        
        var xIdx: Double = 0.0
        for (dataIdx, data) in workoutTracker.data.enumerated() {
            for hr in data.heartRate {
                xIdx += 1.0
                HRData.append(HeartRateGraphDatum(x: xIdx, y: hr, groupIndex: dataIdx))
            }
        }
        
        return HRData
    }
    
    func convertedXData(toMin: Double, toMax: Double) -> [Double] {
        return data.map { convert(x: $0.x, toMin: toMin, toMax: toMax) }
    }
    
    func convertedYData(toMin: Double, toMax: Double) -> [Double] {
        return data.map { convert(y: $0.y, toMin: toMin, toMax: toMax) }
    }
    
    func convert(x: Double, toMin: Double, toMax: Double) -> Double {
        return x.rangeMap(inMin: self.minX, inMax: self.maxX, outMin: toMin, outMax: toMax)
    }
    
    func convert(y: Double, toMin: Double, toMax: Double) -> Double {
        return y.rangeMap(inMin: self.minY, inMax: self.maxY, outMin: toMin, outMax: toMax)
    }
}
